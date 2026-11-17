; Speech: the announcer's sample bank, the sentence queue, and the timer tick that plays the
; next sample. The first bytes finish the pad timer tick.

;-----------------------------------------------------------------------------
; PadTimerTickTail                                            09B2:0000  94 PC
; The last instructions of PadTimerTick, in the next paragraph.
;-----------------------------------------------------------------------------
PadTimerTickTail:                               ; end of PadTimerTick
        db 0xFD                                 ; last byte of the call to ReadHotKey in the segment before
        add sp, 0x2
        inc word [PadRepeatDelay]
.1:
        pop si
        retf

;-----------------------------------------------------------------------------
; SpeechTimerTick                                             09B2:000A  94 PC
; Timer slot: when the wait runs out, plays the next clip of the sentence on
; the other buffer.
;-----------------------------------------------------------------------------
SpeechTimerTick:
        enter 0x18, 0x0
        push si
        call 0x03A3:SsIsDs
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        jmp near .9
.1:
        cmp word [SpeechOn], 0x0
        jnz short .2
        jmp near .9
.2:
        les bx, [SentencePtr]
        cmp word [es:bx + 0x30], 0x0
        jz short .3
        dec word [es:bx + 0x30]
.3:
        les bx, [SentencePtr]
        cmp word [es:bx + 0x32], 0x0
        jnz short .4
        jmp near .9
.4:
        mov ax, [es:bx + 0x2a]
        or ax, [es:bx + 0x28]
        jz short .5
        sub word [es:bx + 0x28], 0x1
        sbb word [es:bx + 0x2a], 0x0
        pop si
        leave
        retf
        db 0x90
.5:
        mov ax, [es:bx + 0x2e]
        inc word [es:bx + 0x2e]
        mov [bp - 0x14], ax
        les bx, [SentencePtr]
        cmp [es:bx + 0x2c], ax
        jg short .6
        jmp near .8
.6:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        mov si, [SentencePtr]
        mov ax, [es:bx + si]
        mov [bp - 0xe], ax
        inc ax
        jnz short .7
        mov word [es:si + 0x32], 0x0
        pop si
        leave
        retf
.7:
        imul bx, [bp - 0xe], 0x24
        add bx, [SpeechBank]
        mov es, [SpeechBankSeg]
        mov [bp - 0x12], bx
        mov [bp - 0x10], es
        mov ax, [es:bx + 0xe]
        mov dx, [es:bx + 0x10]
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        mov ax, [es:bx + 0x16]
        mov dx, [es:bx + 0x18]
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov ax, [es:bx + 0x1e]
        mov dx, [es:bx + 0x20]
        les bx, [SentencePtr]
        mov [es:bx + 0x28], ax
        mov [es:bx + 0x2a], dx
        inc word [SpeechTickCount]
        and word [SpeechTickCount], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push word 0x2b11
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push word [bp - 0xa]
        push word [bp - 0xc]
        push 0x0
        push 0x0
        push 0x80
        push word [bp - 0x16]
        push word [bp - 0x18]
        push word [SpeechTickCount]
        mov al, [SpeechSampleBusy]
        push ax
        call 0x1844:DrvPlaySample
        add sp, 0x1c
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        add sp, 0x2
        pop si
        leave
        retf
.8:
        mov word [es:bx + 0x32], 0x0
        les bx, [SpeechBank]
        mov ax, [es:bx + 0x1210]
        les bx, [SentencePtr]
        mov [es:bx + 0x30], ax
.9:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ClearSpeechClip                                             09B2:013A  94 PC
; Zeroes one 24h-byte clip entry.
;-----------------------------------------------------------------------------
ClearSpeechClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        les bx, [bp + 0x6]
        mov byte [es:bx], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x10], ax
        mov [es:bx + 0xe], ax
        mov [es:bx + 0x14], ax
        mov [es:bx + 0x12], ax
        mov [es:bx + 0x18], ax
        mov [es:bx + 0x16], ax
        mov [es:bx + 0x20], ax
        mov [es:bx + 0x1e], ax
        mov [es:bx + 0x22], ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetSentence                                               09B2:0174  94 PC
; 20 empty clip slots, count, position, wait and playing cleared.
;-----------------------------------------------------------------------------
ResetSentence:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x0
        mov word [bp - 0x2], 0x0
        mov es, [SentenceSeg]
.1:
        mov bx, [bp - 0x2]
        shl bx, 1
        mov si, [SentencePtr]
        mov word [es:bx + si], 0xffff
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0x14
        jl short .1
        les bx, [SentencePtr]
        mov word [es:bx + 0x2c], 0x0
        les bx, [SentencePtr]
        mov word [es:bx + 0x2e], 0x0
        les bx, [SentencePtr]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x2a], ax
        mov [es:bx + 0x28], ax
        les bx, [SentencePtr]
        mov [es:bx + 0x30], ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; InitSpeechBank                                              09B2:01D8  94 PC
; Clears the 128 clips and reserves the speechbuf memory block.
;-----------------------------------------------------------------------------
InitSpeechBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        mov word [bp - 0x2], 0x0
.1:
        imul ax, [bp - 0x2], 0x24
        add ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        push dx
        push ax
        push cs
        call ClearSpeechClip
        add sp, 0x4
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0x80
        jl short .1
        mov ax, [bp + 0x6]
        mov dx, [bp + 0x8]
        sub ax, 0x1388
        sbb dx, 0x0
        les bx, [SpeechBank]
        mov [es:bx + 0x1208], ax
        mov [es:bx + 0x120a], dx
        push 0x80
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word str_Speechbuf
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        les bx, [SpeechBank]
        mov [es:bx + 0x1200], ax
        mov [es:bx + 0x1202], dx
        les bx, [SpeechBank]
        push word [es:bx + 0x1202]
        push word [es:bx + 0x1200]
        call 0x06E1:RawBase
        les bx, [SpeechBank]
        mov [es:bx + 0x1204], ax
        mov [es:bx + 0x1206], dx
        les bx, [SpeechBank]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x120e], ax
        mov [es:bx + 0x120c], ax
        les bx, [SpeechBank]
        mov [es:bx + 0x1212], ax
        les bx, [SpeechBank]
        mov [es:bx + 0x1210], ax
        les bx, [SpeechBank]
        mov [es:bx + 0x1214], ax
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ResetWantedSamples                                          09B2:0292  94 PC
; Clears the 20 wanted sample names and their total size.
;-----------------------------------------------------------------------------
ResetWantedSamples:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        mov word [bp - 0x2], 0x0
        mov es, [WantedListSeg]
.1:
        mov bx, [bp - 0x2]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        shl bx, 1
        db 0x03, 0xD8                           ; insn: add bx, ax
        shl bx, byte 0x2
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov si, [WantedList]
        mov byte [es:bx + si], 0x0
        inc word [bp - 0x2]
        cmp word [bp - 0x2], 0x14
        jl short .1
        les bx, [WantedList]
        mov word [es:bx + 0x10a], 0x0
        les bx, [WantedList]
        mov word [es:bx + 0x108], 0x0
        les bx, [WantedList]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x106], ax
        mov [es:bx + 0x104], ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SpeechInit                                                  09B2:02F0  94 PC
; Allocates Sentence, SpeechBank and SampleMemMan, the pause sample, the
; timer slot.
;-----------------------------------------------------------------------------
SpeechInit:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push cs
        call SpeechIsReady
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        jmp near .2
.1:
        mov al, [bp + 0x6]
        mov [SpeechSampleBusy], al
        mov word [SpeechTickCount], 0x0
        mov ax, [bp + 0xc]
        mov dx, [bp + 0xe]
        mov [MoveBlockOff], ax
        mov [MoveBlockSeg], dx
        mov ax, [bp + 0x10]
        mov dx, [bp + 0x12]
        mov [SpeechMemOff], ax
        mov [SpeechMemSeg], dx
        push cs
        call MakePauseSample
        push 0x0
        push 0x0
        push 0x34
        push word str_Sentence
        call 0x14DB:AllocRecData
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        mov [SentencePtr], ax
        mov [SentenceSeg], dx
        push cs
        call ResetSentence
        push 0x0
        push 0x0
        push word 0x122c
        push word str_SpeechBank
        call 0x14DB:AllocRecData
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        mov [SpeechBank], ax
        mov [SpeechBankSeg], dx
        push word [bp + 0xa]
        push word [bp + 0x8]
        push cs
        call InitSpeechBank
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        push 0x0
        push 0x0
        push word 0x10c
        push word str_SampleMemMan
        call 0x14DB:AllocRecData
        db 0x8B, 0xE5                           ; insn: mov sp, bp
        mov [WantedList], ax
        mov [WantedListSeg], dx
        push cs
        call ResetWantedSamples
        push word 0x9b2
        push strict word 0xa
        call 0x03A3:AllocSlot
        mov word [SpeechOn], 0x1
.2:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SpeechShutdown                                              09B2:039E  94 PC
; Frees the timer slot, the sound channel and the three blocks.
;-----------------------------------------------------------------------------
SpeechShutdown:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jz short .1
        push word 0x9b2
        push strict word 0xa
        call 0x03A3:FreeSlot
        add sp, 0x4
        mov al, [SpeechSampleBusy]
        push ax
        call 0x1844:DrvShutdown
        add sp, 0x2
        push word [SentenceSeg]
        push word [SentencePtr]
        call 0x06E1:FindUnlink
        add sp, 0x4
        les bx, [SpeechBank]
        push word [es:bx + 0x1202]
        push word [es:bx + 0x1200]
        call 0x06E1:UnlinkRec
        add sp, 0x4
        push word [SpeechBankSeg]
        push word [SpeechBank]
        call 0x06E1:FindUnlink
        add sp, 0x4
        push word [WantedListSeg]
        push word [WantedList]
        call 0x06E1:FindUnlink
        add sp, 0x4
        mov word [SpeechOn], 0x0
.1:
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SpeechIsReady                                               09B2:0414  94 PC
; Returns SpeechOn.
;-----------------------------------------------------------------------------
SpeechIsReady:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90
.1:
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; SpeechBusy                                                  09B2:042A  94 PC
; Playing flag, else the wait count.
;-----------------------------------------------------------------------------
SpeechBusy:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90
.1:
        les bx, [SentencePtr]
        cmp word [es:bx + 0x32], 0x0
        jz short .2
        mov ax, 0x1
        retf
        db 0x90
.2:
        mov ax, [es:bx + 0x30]
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SpeechIdle                                                  09B2:0452  94 PC
; Ready, not playing and no wait.
;-----------------------------------------------------------------------------
SpeechIdle:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90
.2:
        les bx, [SentencePtr]
        cmp word [es:bx + 0x32], 0x0
        jnz short .1
        cmp word [es:bx + 0x30], 0x0
        jnz short .1
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; StopSpeech                                                  09B2:047A  94 PC
; Clears playing and sets the wait from the bank.
;-----------------------------------------------------------------------------
StopSpeech:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        cmp word [SpeechOn], 0x0
        jz short .1
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x0
        les bx, [SentencePtr]
        mov ax, [es:bx + 0x28]
        les si, [SpeechBank]
        add ax, [es:si + 0x1210]
        mov es, [SentenceSeg]
        mov [es:bx + 0x30], ax
.1:
        pop si
        retf

;-----------------------------------------------------------------------------
; MakePauseSample                                             09B2:04AE  94 PC
; 256-byte silent sample in a memory block.
;-----------------------------------------------------------------------------
MakePauseSample:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x12
        call 0x0000:__chkstk
        push si
        push 0x80
        push 0x0
        push word 0x100
        push word str_Pause
        call 0x14DB:InsertRecWrap
        add sp, 0x8
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        push dx
        push ax
        call 0x06E1:RawBase
        add sp, 0x4
        mov [PauseSampleOff], ax
        mov [PauseSampleSeg], dx
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push word [PauseSampleSeg]
        push word [PauseSampleOff]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        mov word [bp - 0x12], 0x0
        mov es, [bp - 0xa]
.1:
        mov bx, [bp - 0xc]
        mov si, [bp - 0x12]
        mov byte [es:bx + si], 0x0
        inc word [bp - 0x12]
        cmp word [bp - 0x12], 0x100
        jl short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        add sp, 0x2
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; PlayPauseSample                                             09B2:0532  94 PC
; Queues the pause sample on both sound buffers.
;-----------------------------------------------------------------------------
PlayPauseSample:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push word 0x2b11
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push word 0x100
        push 0x0
        push 0x0
        push 0x80
        push word [PauseSampleSeg]
        push word [PauseSampleOff]
        push 0x0
        mov al, [SpeechSampleBusy]
        push ax
        call 0x1844:DrvPlaySample
        add sp, 0x1c
        push word 0x2b11
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push 0x0
        push word 0x100
        push 0x0
        push 0x0
        push 0x80
        push word [PauseSampleSeg]
        push word [PauseSampleOff]
        push 0x1
        mov al, [SpeechSampleBusy]
        push ax
        call 0x1844:DrvPlaySample
        add sp, 0x1c
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
.1:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SwapWordBytes                                               09B2:05B6  94 PC
; Swaps the two bytes of a word (big-endian file fields).
;-----------------------------------------------------------------------------
SwapWordBytes:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        mov ax, [bp + 0x6]
        mov [bp - 0x2], ax
        mov al, [bp - 0x1]
        mov [bp - 0x4], al
        mov al, [bp - 0x2]
        mov [bp - 0x1], al
        mov al, [bp - 0x4]
        mov [bp - 0x2], al
        mov ax, [bp - 0x2]
        leave
        retf

;-----------------------------------------------------------------------------
; ReadBe24                                                    09B2:05DE  94 PC
; Reads 3 bytes, big-endian, into a long.
;-----------------------------------------------------------------------------
ReadBe24:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
        mov byte [bp - 0x1], 0x0
        lea ax, [bp - 0x6]
        push ax
        push 0x1
        lea cx, [bp - 0x2]
        push ss
        push cx
        push word [bp + 0x6]
        call 0x0000:_dos_read
        add sp, 0xa
        lea ax, [bp - 0x6]
        push ax
        push 0x1
        lea cx, [bp - 0x3]
        push ss
        push cx
        push word [bp + 0x6]
        call 0x0000:_dos_read
        add sp, 0xa
        lea ax, [bp - 0x6]
        push ax
        push 0x1
        lea ax, [bp - 0x4]
        push ss
        push ax
        push word [bp + 0x6]
        call 0x0000:_dos_read
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        leave
        retf

;-----------------------------------------------------------------------------
; ReadCString                                                 09B2:0634  94 PC
; Reads bytes from a handle until a zero.
;-----------------------------------------------------------------------------
ReadCString:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6
        call 0x0000:__chkstk
.1:
        lea ax, [bp - 0x2]
        push ax
        push 0x1
        push word [bp + 0x8]
        push word [bp + 0x6]
        push word [bp + 0xa]
        call 0x0000:_dos_read
        add sp, 0xa
        les bx, [bp + 0x6]
        inc word [bp + 0x6]
        cmp byte [es:bx], 0x0
        jnz short .1
        leave
        retf

;-----------------------------------------------------------------------------
; OpenSpeechFile                                              09B2:0664  94 PC
; Opens a speech file, reads its clip count and each clip's offset, size and
; name.
;-----------------------------------------------------------------------------
OpenSpeechFile:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2e
        call 0x0000:__chkstk
        push si
        cmp word [SpeechOn], 0x0
        jnz short .1
        jmp near .12
.1:
        les bx, [SpeechBank]
        cmp word [es:bx + 0x1214], 0x0
        jz short .3
        lea ax, [bx + SpeechFileNames]
        push es
        push ax
        push ds
        push word [bp + 0x6]
        push cs
        call StrSameNoCaseFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .2
        jmp near .12
.2:
        les bx, [SpeechBank]
        push word [es:bx + 0x1216]
        call 0x0000:_dos_close
        add sp, 0x2
.3:
        lea ax, [bp - 0x22]
        push ax
        push 0x0
        push word [bp + 0x6]
        call 0x0000:_dos_open
        add sp, 0x6
        push 0xd
        push ds
        push word [bp + 0x6]
        mov ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        add ax, 0x1218
        push dx
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        mov ax, [bp - 0x22]
        les bx, [SpeechBank]
        mov [es:bx + 0x1216], ax
        mov ax, [bp + 0x8]
        les bx, [SpeechBank]
        mov [es:bx + 0x1210], ax
        les bx, [SpeechBank]
        mov word [es:bx + 0x1214], 0x1
        les bx, [SpeechBank]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + 0x120e], ax
        mov [es:bx + 0x120c], ax
        les bx, [SpeechBank]
        mov [es:bx + 0x1212], ax
        lea ax, [bp - 0x20]
        push ax
        push 0x2
        lea cx, [bp - 0x24]
        push ss
        push cx
        push word [bp - 0x22]
        call 0x0000:_dos_read
        add sp, 0xa
        push word [bp - 0x24]
        push cs
        call SwapWordBytes
        add sp, 0x2
        les bx, [SpeechBank]
        mov [es:bx + 0x1226], ax
        lea ax, [bp - 0x20]
        push ax
        push 0x2
        lea cx, [bp - 0x12]
        push ss
        push cx
        push word [bp - 0x22]
        call 0x0000:_dos_read
        add sp, 0xa
        push word [bp - 0x12]
        push cs
        call SwapWordBytes
        add sp, 0x2
        les bx, [SpeechBank]
        mov [es:bx + 0x1228], ax
        lea ax, [bp - 0x20]
        push ax
        push 0x2
        lea ax, [bp - 0x2]
        push ss
        push ax
        push word [bp - 0x22]
        call 0x0000:_dos_read
        add sp, 0xa
        push word [bp - 0x2]
        push cs
        call SwapWordBytes
        add sp, 0x2
        les bx, [SpeechBank]
        mov [es:bx + 0x122a], ax
        mov word [bp - 0x1e], 0x0
        jmp short .5
.4:
        imul si, ax, 0x24
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [es:bx + si + 0x10], ax
        mov [es:bx + si + 0xe], ax
        push word [bp - 0x22]
        push cs
        call ReadBe24
        add sp, 0x2
        les bx, [SpeechBank]
        mov [es:bx + si + 0x12], ax
        mov [es:bx + si + 0x14], dx
        push word [bp - 0x22]
        push cs
        call ReadBe24
        add sp, 0x2
        mov [bp - 0x1c], ax
        mov [bp - 0x1a], dx
        les bx, [SpeechBank]
        mov [es:bx + si + 0x1a], ax
        mov [es:bx + si + 0x1c], dx
        push word [bp - 0x22]
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, [SpeechBank]
        mov cx, [SpeechBankSeg]
        push cx
        push si
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push cs
        call ReadCString
        add sp, 0x6
        les bx, [SpeechBank]
        mov word [es:bx + si + 0x22], 0x0
        inc word [bp - 0x1e]
.5:
        mov ax, [bp - 0x1e]
        les bx, [SpeechBank]
        cmp [es:bx + 0x122a], ax
        jg short .4
        mov ax, [es:bx + 0x1210]
        mov [bp + 0x8], ax
        mov word [bp - 0x1e], 0x0
        jmp near .8
.6:
        imul si, ax, 0x24
        mov ax, [es:bx + si + 0x12]
        mov dx, [es:bx + si + 0x14]
        mov [bp - 0x18], ax
        mov [bp - 0x16], dx
        push 0x0
        add ax, strict word 0x1
        adc dx, 0x0
        push dx
        push ax
        push word [bp - 0x22]
        call 0x0000:_lseek
        add sp, 0x8
        lea ax, [bp - 0x20]
        push ax
        push 0x1
        lea ax, [bp - 0x26]
        push ss
        push ax
        push word [bp - 0x22]
        call 0x0000:_dos_read
        add sp, 0xa
        cmp byte [bp - 0x26], 0xfb
        jz short .7
        push 0xd
        add si, [SpeechBank]
        mov cx, [SpeechBankSeg]
        push cx
        push si
        lea ax, [bp - 0x10]
        push ss
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
.7:
        push 0x0
        mov ax, [bp - 0x18]
        mov dx, [bp - 0x16]
        add ax, strict word 0x6
        adc dx, 0x0
        push dx
        push ax
        push word [bp - 0x22]
        call 0x0000:_lseek
        add sp, 0x8
        lea ax, [bp - 0x20]
        push ax
        push 0x2
        lea ax, [bp - 0x14]
        push ss
        push ax
        push word [bp - 0x22]
        call 0x0000:_dos_read
        add sp, 0xa
        push word [bp - 0x14]
        push cs
        call SwapWordBytes
        add sp, 0x2
        sub ax, strict word 0x5
        mov [bp - 0x14], ax
        imul si, [bp - 0x1e], 0x24
        les bx, [SpeechBank]
        mov [es:bx + si + 0x16], ax
        mov word [es:bx + si + 0x18], 0x0
        mov ax, [bp - 0x14]
        db 0x2B, 0xD2                           ; insn: sub dx, dx
        mov [bp - 0x28], dx
        mov [bp - 0x2a], dx
        mov [bp - 0x2c], dx
        mov [bp - 0x2e], ax
        int 0x3b
        db 0x6E, 0xD2                           ; emulated fild qword [bp - 0x2e]
        int 0x38
        db 0x0E                                 ; emulated fmul qword [CentisPerSample]
        dw CentisPerSample
        call 0x0000:__aFftol
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [bp + 0x8]
        db 0x8B, 0xDA                           ; insn: mov bx, dx
        cwd
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        db 0x1B, 0xDA                           ; insn: sbb bx, dx
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        les bx, [SpeechBank]
        mov [es:bx + si + 0x1e], cx
        mov [es:bx + si + 0x20], ax
        inc word [bp - 0x1e]
.8:
        mov ax, [bp - 0x1e]
        les bx, [SpeechBank]
        cmp [es:bx + 0x122a], ax
        jng short .9
        jmp near .6
.9:
        mov ax, [es:bx + 0x122a]
        mov [bp - 0x1e], ax
        jmp short .11
        db 0x90
.10:
        imul ax, [bp - 0x1e], 0x24
        add ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        push dx
        push ax
        push cs
        call ClearSpeechClip
        add sp, 0x4
        inc word [bp - 0x1e]
.11:
        cmp word [bp - 0x1e], 0x80
        jl short .10
.12:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; ClipLength                                                  09B2:0942  94 PC
; Size of a clip, 0 for -1.
;-----------------------------------------------------------------------------
ClipLength:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        cmp word [bp + 0x6], -0x1
        jnz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        cwd
        pop si
        leave
        retf
        db 0x90
.1:
        imul si, [bp + 0x6], 0x24
        les bx, [SpeechBank]
        mov ax, [es:bx + si + 0x16]
        mov dx, [es:bx + si + 0x18]
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadClipData                                                09B2:096E  94 PC
; Reads one clip from the file into memory and undoes its delta coding.
;-----------------------------------------------------------------------------
LoadClipData:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x20
        call 0x0000:__chkstk
        push si
        imul bx, [bp + 0x6], 0x24
        add bx, [SpeechBank]
        mov es, [SpeechBankSeg]
        mov ax, [es:bx + 0x1a]
        mov [bp - 0x16], ax
        mov si, [SpeechBank]
        mov cx, [es:si + 0x1216]
        mov [bp - 0x1c], cx
        mov cx, [es:bx + 0x12]
        mov dx, [es:bx + 0x14]
        mov [bp - 0x14], cx
        mov [bp - 0x12], dx
        mov ax, [es:bx + 0x16]
        mov dx, [es:bx + 0x18]
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        push word [bp + 0xa]
        push word [bp + 0x8]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        sub ax, [bp - 0x16]
        add ax, [bp - 0xc]
        add ax, 0x1388
        mov [bp - 0x10], ax
        mov [bp - 0xe], dx
        push 0x0
        push word [bp - 0x12]
        push word [bp - 0x14]
        push word [bp - 0x1c]
        call 0x0000:_lseek
        add sp, 0x8
        lea ax, [bp - 0x1e]
        push ax
        push word [bp - 0x16]
        push word [bp - 0xe]
        push word [bp - 0x10]
        push word [bp - 0x1c]
        call 0x0000:_dos_read
        add sp, 0xa
        push 0x0
        push word [bp - 0x16]
        push word [bp - 0x2]
        push word [bp - 0x4]
        push word [bp - 0xe]
        push word [bp - 0x10]
        call 0x0838:LoadReport
        add sp, 0xc
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        mov byte [bp - 0x20], 0x0
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x18], ax
        mov [bp - 0x1a], ax
        jmp short .2
.1:
        add word [bp - 0x1a], 0x1
        adc word [bp - 0x18], 0x0
.2:
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        sub ax, strict word 0x5
        sbb dx, 0x0
        cmp dx, [bp - 0x18]
        jl short .4
        jg short .3
        cmp ax, [bp - 0x1a]
        jna short .4
.3:
        mov bx, [bp - 0x1a]
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        add bx, [bp - 0x4]
        mov es, [bp - 0x2]
        mov cl, [es:bx + 0x5]
        add cl, [bp - 0x20]
        mov [es:bx], cl
        les bx, [bp - 0x4]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov al, [es:bx + si + 0x5]
        add [bp - 0x20], al
        jmp short .1
        db 0x90
.4:
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        sub ax, strict word 0x5
        sbb dx, 0x0
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; LoadClipToBank                                              09B2:0A84  94 PC
; Puts a clip after the previous one in the bank and marks it loaded.
;-----------------------------------------------------------------------------
LoadClipToBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        push si
        cmp word [bp + 0x6], 0x0
        jnz short .1
        les bx, [SpeechBank]
        mov ax, [es:bx + 0x1204]
        mov dx, [es:bx + 0x1206]
        jmp short .2
.1:
        imul bx, [bp + 0x6], 0x24
        add bx, [SpeechBank]
        mov es, [SpeechBankSeg]
        mov ax, [es:bx - 0x16]
        mov dx, [es:bx - 0x14]
        add ax, [es:bx - 0xe]
        adc dx, [es:bx - 0xc]
.2:
        imul si, [bp + 0x6], 0x24
        mov bx, [SpeechBank]
        mov [es:bx + si + 0xe], ax
        mov [es:bx + si + 0x10], dx
        push dx
        push ax
        push word [bp + 0x6]
        push cs
        call LoadClipData
        add sp, 0x6
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        les bx, [SpeechBank]
        mov word [es:bx + si + 0x22], 0x1
        mov ax, [bp - 0x4]
        mov dx, [bp - 0x2]
        les bx, [SpeechBank]
        add [es:bx + 0x120c], ax
        adc [es:bx + 0x120e], dx
        les bx, [SpeechBank]
        inc word [es:bx + 0x1212]
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; StrSameNoCaseFar                                            09B2:0B0E  94 PC
; Compares two far strings ignoring case (xor and DFh).
;-----------------------------------------------------------------------------
StrSameNoCaseFar:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
.1:
        les bx, [bp + 0x6]
        cmp byte [es:bx], 0x0
        jnz short .2
        les bx, [bp + 0xa]
        cmp byte [es:bx], 0x0
        jz short .3
.2:
        les bx, [bp + 0xa]
        inc word [bp + 0xa]
        mov al, [es:bx]
        les bx, [bp + 0x6]
        inc word [bp + 0x6]
        xor al, [es:bx]
        test al, 0xdf
        jz short .1
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.3:
        mov ax, 0x1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; FindFreeClip                                                09B2:0B4C  94 PC
; First clip slot from the index that is not loaded.
;-----------------------------------------------------------------------------
FindFreeClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        mov ax, [bp + 0x6]
        mov [bp - 0x2], ax
        jmp short .2
.1:
        inc word [bp - 0x2]
.2:
        cmp word [bp - 0x2], 0x80
        jnl short .3
        imul si, [bp - 0x2], 0x24
        les bx, [SpeechBank]
        cmp word [es:bx + si + 0x22], 0x0
        jnz short .1
        mov ax, [bp - 0x2]
        pop si
        leave
        retf
        db 0x90
.3:
        mov ax, 0xffff
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; FindLoadedClip                                              09B2:0B86  94 PC
; First loaded clip slot from the index.
;-----------------------------------------------------------------------------
FindLoadedClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        mov ax, [bp + 0x6]
        mov [bp - 0x2], ax
        jmp short .2
.1:
        inc word [bp - 0x2]
.2:
        cmp word [bp - 0x2], 0x80
        jnl short .3
        imul si, [bp - 0x2], 0x24
        les bx, [SpeechBank]
        cmp word [es:bx + si + 0x22], 0x1
        jnz short .1
        mov ax, [bp - 0x2]
        pop si
        leave
        retf
        db 0x90
.3:
        mov ax, 0xffff
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; FindClipByName                                              09B2:0BC0  94 PC
; Clip index of a name, or -1.
;-----------------------------------------------------------------------------
FindClipByName:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        mov word [bp - 0x2], 0x0
        jmp short .2
.1:
        inc word [bp - 0x2]
.2:
        cmp word [bp - 0x2], 0x80
        jnl short .3
        imul ax, [bp - 0x2], 0x24
        add ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        push dx
        push ax
        push ds
        push word [bp + 0x6]
        push cs
        call StrSameNoCaseFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov ax, [bp - 0x2]
        leave
        retf
.3:
        mov ax, 0xffff
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; ClipIsLoaded                                                09B2:0C04  94 PC
; Clip state is 1.
;-----------------------------------------------------------------------------
ClipIsLoaded:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push si
        imul si, [bp + 0x6], 0x24
        les bx, [SpeechBank]
        cmp word [es:bx + si + 0x22], 0x1
        jnz short .1
        mov ax, 0x1
        pop si
        leave
        retf
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SampleIsWanted                                              09B2:0C2A  94 PC
; Name is in the wanted list.
;-----------------------------------------------------------------------------
SampleIsWanted:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        mov word [bp - 0x2], 0x0
        jmp short .2
.1:
        inc word [bp - 0x2]
.2:
        mov ax, [bp - 0x2]
        les bx, [WantedList]
        cmp [es:bx + 0x108], ax
        jng short .3
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        db 0x03, 0xD8                           ; insn: add bx, ax
        push es
        push bx
        push word [bp + 0x8]
        push word [bp + 0x6]
        push cs
        call StrSameNoCaseFar
        add sp, 0x8
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        mov ax, 0x1
        leave
        retf
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf

;-----------------------------------------------------------------------------
; WantSample                                                  09B2:0C76  94 PC
; Adds a name to the wanted list and its size to the total.
;-----------------------------------------------------------------------------
WantSample:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push ds
        push word [bp + 0x6]
        push cs
        call SampleIsWanted
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .2
        les bx, [WantedList]
        mov ax, [es:bx + 0x108]
        inc word [es:bx + 0x108]
        push 0xd
        push ds
        push word [bp + 0x6]
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        shl ax, 1
        db 0x03, 0xC1                           ; insn: add ax, cx
        shl ax, byte 0x2
        db 0x03, 0xC1                           ; insn: add ax, cx
        add ax, [WantedList]
        mov dx, [WantedListSeg]
        push dx
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        push word [bp + 0x6]
        push cs
        call FindClipByName
        add sp, 0x2
        mov [bp - 0x4], ax
        inc ax
        jz short .1
        push word [bp - 0x4]
        push cs
        call ClipIsLoaded
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        push word [bp - 0x4]
        push cs
        call ClipLength
        les bx, [WantedList]
        add [es:bx + 0x104], ax
        adc [es:bx + 0x106], dx
.1:
        les bx, [WantedList]
        inc word [es:bx + 0x10a]
.2:
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; DropUnwantedClip                                            09B2:0D00  94 PC
; From the last slot, unloads a loaded clip nobody wants.
;-----------------------------------------------------------------------------
DropUnwantedClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        push si
        mov word [bp - 0x2], 0x7f
        jmp short .2
        db 0x90
.1:
        dec word [bp - 0x2]
.2:
        cmp word [bp - 0x2], 0x0
        jl short .3
        imul bx, [bp - 0x2], 0x24
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        add bx, [SpeechBank]
        mov es, [SpeechBankSeg]
        cmp word [es:bx + 0x22], 0x1
        jnz short .1
        push es
        push bx
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push cs
        call SampleIsWanted
        add sp, 0x4
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jnz short .1
        les bx, [SpeechBank]
        mov [es:bx + si + 0x22], ax
        les bx, [SpeechBank]
        mov ax, [es:bx + si + 0x16]
        mov dx, [es:bx + si + 0x18]
        sub [es:bx + 0x120c], ax
        sbb [es:bx + 0x120e], dx
        mov ax, 0x1
        pop si
        leave
        retf
        db 0x90
.3:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MoveMemBlock                                                09B2:0D6C  94 PC
; Copies between two mapped memory addresses through the copy buffer.
;-----------------------------------------------------------------------------
MoveMemBlock:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
.1:
        mov ax, [bp + 0x10]
        or ax, [bp + 0xe]
        jnz short .2
        jmp near .5
.2:
        mov ax, [SpeechMemOff]
        mov dx, [SpeechMemSeg]
        cmp [bp + 0x10], dx
        jc short .3
        ja short .4
        cmp [bp + 0xe], ax
        ja short .4
.3:
        mov ax, [bp + 0xe]
        mov dx, [bp + 0x10]
.4:
        mov [bp - 0x8], ax
        mov [bp - 0x6], dx
        push word [bp + 0xc]
        push word [bp + 0xa]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push word [bp - 0x8]
        push dx
        push ax
        push word [MoveBlockSeg]
        push word [MoveBlockOff]
        call 0x0000:_fmemmove
        add sp, 0xa
        push word [bp + 0x8]
        push word [bp + 0x6]
        call 0x03A3:EmsMapFrame
        add sp, 0x4
        push word [bp - 0x8]
        push word [MoveBlockSeg]
        push word [MoveBlockOff]
        push dx
        push ax
        call 0x0000:_fmemmove
        add sp, 0xa
        mov ax, [bp - 0x8]
        mov dx, [bp - 0x6]
        add [bp + 0xa], ax
        adc [bp + 0xc], dx
        add [bp + 0x6], ax
        adc [bp + 0x8], dx
        sub [bp + 0xe], ax
        sbb [bp + 0x10], dx
        jmp near .1
.5:
        leave
        retf

;-----------------------------------------------------------------------------
; MoveClip                                                    09B2:0E04  94 PC
; Moves a clip into a lower free slot and its bytes after the previous clip.
;-----------------------------------------------------------------------------
MoveClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x30
        call 0x0000:__chkstk
        push di
        push si
        imul si, [bp + 0x8], 0x24
        les bx, [SpeechBank]
        mov ax, [es:bx + si + 0xe]
        mov dx, [es:bx + si + 0x10]
        mov [bp - 0x2c], ax
        mov [bp - 0x2a], dx
        cmp word [bp + 0x6], 0x0
        jnz short .1
        mov ax, [es:bx + 0x1204]
        mov dx, [es:bx + 0x1206]
        jmp short .2
        db 0x90
.1:
        imul bx, [bp + 0x6], 0x24
        add bx, [SpeechBank]
        mov ax, [es:bx - 0x16]
        mov dx, [es:bx - 0x14]
        add ax, [es:bx - 0xe]
        adc dx, [es:bx - 0xc]
.2:
        mov [bp - 0x30], ax
        mov [bp - 0x2e], dx
        imul si, [bp + 0x8], 0x24
        mov bx, [SpeechBank]
        mov ax, [es:bx + si + 0x16]
        mov dx, [es:bx + si + 0x18]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        push dx
        push ax
        push word [bp - 0x2a]
        push word [bp - 0x2c]
        push word [bp - 0x2e]
        push word [bp - 0x30]
        push cs
        call MoveMemBlock
        add sp, 0xc
        imul ax, [bp + 0x6], 0x24
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        push cx
        push si
        push ds
        lea di, [bp - 0x28]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push ss
        pop es
        mov ds, dx
        mov cx, 0x12
        rep movsw
        pop ds
        pop si
        pop cx
        db 0x8B, 0xC6                           ; insn: mov ax, si
        add si, [SpeechBank]
        mov dx, [SpeechBankSeg]
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        les di, [SpeechBank]
        push cx
        push di
        push es
        push ds
        lea di, [bx + di]
        mov ds, dx
        mov cx, 0x12
        rep movsw
        pop ds
        pop es
        pop di
        pop cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        les si, [SpeechBank]
        push cx
        lea di, [bx + si]
        lea si, [bp - 0x28]
        mov cx, 0x12
        rep movsw
        pop cx
        mov bx, [SpeechBank]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov cx, [bp - 0x30]
        mov dx, [bp - 0x2e]
        mov [es:bx + si + 0xe], cx
        mov [es:bx + si + 0x10], dx
        les bx, [SpeechBank]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        mov word [es:bx + si + 0x22], 0x0
        pop si
        pop di
        leave
        retf

;-----------------------------------------------------------------------------
; CompactSpeechBank                                           09B2:0EFC  94 PC
; Moves loaded clips down into the free slots.
;-----------------------------------------------------------------------------
CompactSpeechBank:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4
        call 0x0000:__chkstk
        push 0x0
        push cs
        call FindFreeClip
        add sp, 0x2
        mov [bp - 0x4], ax
        inc ax
        jz short .3
        push word [bp - 0x4]
        jmp short .2
        db 0x90
.1:
        push word [bp - 0x2]
        push word [bp - 0x4]
        push cs
        call MoveClip
        add sp, 0x4
        push word [bp - 0x4]
        push cs
        call FindFreeClip
        add sp, 0x2
        mov [bp - 0x4], ax
        push ax
.2:
        push cs
        call FindLoadedClip
        add sp, 0x2
        mov [bp - 0x2], ax
.3:
        cmp word [bp - 0x2], -0x1
        jnz short .1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; MakeRoomForWanted                                           09B2:0F4A  94 PC
; Drops unwanted clips until the wanted total fits.
;-----------------------------------------------------------------------------
MakeRoomForWanted:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xc
        call 0x0000:__chkstk
        push si
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0xc], ax
        mov [bp - 0x6], ax
        les bx, [SpeechBank]
        mov ax, [es:bx + 0x1208]
        mov dx, [es:bx + 0x120a]
        mov [bp - 0x4], ax
        mov [bp - 0x2], dx
        les si, [WantedList]
        mov cx, [es:si + 0x104]
        mov bx, [es:si + 0x106]
        les si, [SpeechBank]
        add cx, [es:si + 0x120c]
        adc bx, [es:si + 0x120e]
        db 0x3B, 0xDA                           ; insn: cmp bx, dx
        jc short .4
        ja short .1
        db 0x3B, 0xC8                           ; insn: cmp cx, ax
        jna short .4
.1:
        push cs
        call DropUnwantedClip
        les bx, [WantedList]
        mov ax, [es:bx + 0x104]
        mov dx, [es:bx + 0x106]
        les bx, [SpeechBank]
        add ax, [es:bx + 0x120c]
        adc dx, [es:bx + 0x120e]
        cmp dx, [bp - 0x2]
        ja short .3
        jc short .2
        cmp ax, [bp - 0x4]
        jnc short .3
.2:
        mov word [bp - 0x6], 0x1
.3:
        cmp word [bp - 0x6], 0x0
        jnz short .4
        inc word [bp - 0xc]
        cmp word [bp - 0xc], 0x80
        jl short .1
.4:
        pop si
        leave
        retf

;-----------------------------------------------------------------------------
; PrepareSpeechBank                                           09B2:0FDC  94 PC
; MakeRoomForWanted then CompactSpeechBank.
;-----------------------------------------------------------------------------
PrepareSpeechBank:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        push cs
        call MakeRoomForWanted
        push cs
        call CompactSpeechBank
        retf

;-----------------------------------------------------------------------------
; NumberSampleNames                                           09B2:0FEC  94 PC
; Names of the tens and ones clips of a number (zero..ninety-nine).
;-----------------------------------------------------------------------------
NumberSampleNames:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x6], ax
        mov [bp - 0x8], ax
        mov cx, 0x64
        mov ax, [bp + 0x6]
        cwd
        idiv cx
        mov [bp + 0x6], dx
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        mov cx, 0xa
        cwd
        idiv cx
        mov [bp - 0x2], ax
        mov ax, [bp + 0x6]
        cwd
        idiv cx
        mov [bp - 0x4], dx
        cmp word [bp - 0x2], 0x0
        jnz short .2
        db 0x0B, 0xD2                           ; insn: or dx, dx
        jnz short .2
        push word 0x342f                        ; segment of the number words far data
        push strict word 0x1
        push ds
        push word [bp + 0x8]
        call 0x0000:_fstrcpy
        add sp, 0x8
        push word 0x342f                        ; segment of the number words far data
        push strict word 0x0
.1:
        mov ax, [bp + 0x8]
        add ax, strict word 0xd
        push ds
        push ax
        call 0x0000:_fstrcpy
        add sp, 0x8
        leave
        retf
        db 0x90
.2:
        mov ax, [bp - 0x2]
        mov [bp - 0x6], ax
        dec ax
        jnz short .3
        mov [bp - 0x8], cx
.3:
        mov es, [NumberWordsSeg]
        mov bx, [bp - 0x6]
        shl bx, byte 0x2
        push word [es:bx + 0xba]
        push word [es:bx + 0xb8]
        push ds
        push word [bp + 0x8]
        call 0x0000:_fstrcpy
        add sp, 0x8
        mov es, [NumberWordsSeg]
        mov ax, [bp - 0x4]
        add [bp - 0x8], ax
        mov bx, [bp - 0x8]
        shl bx, byte 0x2
        push word [es:bx + 0xe2]
        push word [es:bx + 0xe0]
        jmp short .1

;-----------------------------------------------------------------------------
; GameLengthSampleName                                        09B2:109C  94 PC
; Sample for the period length (game mis., 2, 5 or 10 minutes, off).
;-----------------------------------------------------------------------------
GameLengthSampleName:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        mov ax, [bp + 0x6]
        jmp short .6
        db 0x90
.1:
        push str_Off
        push str_2minsS
        jmp short .5
.2:
        push str_Off_2
        push str_5minsS
        jmp short .5
.3:
        push str_Off_3
        push str_10minsS
        jmp short .5
.4:
        push str_Off_4
        push str_GamemisS
.5:
        push word [bp + 0x8]
        call 0x0000:_sprintf
        add sp, 0x6
        leave
        retf
        db 0x90
.6:
        inc ax
        jz short .4
        sub ax, strict word 0x3
        jz short .1
        sub ax, strict word 0x3
        jz short .2
        sub ax, strict word 0x5
        jz short .3
        leave
        retf

;-----------------------------------------------------------------------------
; DivisionSampleName                                          09B2:10EC  94 PC
; Sample for a division or conference (Adams, Patrick, Norris, Smythe,
; Campbell, Wales, Stanley).
;-----------------------------------------------------------------------------
DivisionSampleName:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2
        call 0x0000:__chkstk
        mov word [bp - 0x2], 0x0
        mov ax, [bp + 0x8]
        jmp short .9
        db 0x90
.1:
        push str_SmytheBar
.2:
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0x4
        mov word [bp - 0x2], 0x2
        jmp short DivisionSampleNameJumpTable.1
        db 0x90
.3:
        push str_NorrisBar
        jmp short .2
        db 0x90
.4:
        push str_AdamsBar
        jmp short .2
        db 0x90
.5:
        push str_PatrickBar
        jmp short .2
        db 0x90
.6:
        push str_CampbellBar
.7:
        push word [bp + 0x6]
        call 0x0000:_sprintf
        add sp, 0x4
        mov word [bp - 0x2], 0x1
        jmp short DivisionSampleNameJumpTable.1
        db 0x90
.8:
        push str_WalesBar
        jmp short .7
        db 0x90
.9:
        dec ax
        cmp ax, strict word 0xb
        ja short DivisionSampleNameJumpTable.1
        shl ax, 1
        xchg ax, bx
        jmp [cs:bx + DivisionSampleNameJumpTable]
DivisionSampleNameJumpTable:                    ; word; used by DivisionSampleName
        dw DivisionSampleName.1
        dw DivisionSampleName.3
        dw DivisionSampleName.6
        dw DivisionSampleName.4
        dw .1
        dw .1
        dw .1
        dw DivisionSampleName.5
        dw .1
        dw .1
        dw .1
        dw DivisionSampleName.8
.1:
        test byte [bp + 0x8], 0x3
        jz short .2
        test byte [bp + 0x8], 0xc
        jz short .2
        mov word [bp - 0x2], 0x0
        push str_StanleyBar
        push word [bp + 0x6]
        call 0x0000:_sprintf
.2:
        mov ax, [bp - 0x2]
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; QueueClip                                                   09B2:118E  94 PC
; Appends a clip to the sentence, loading it into the bank when needed.
;-----------------------------------------------------------------------------
QueueClip:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x2a
        call 0x0000:__chkstk
        push di
        push si
        les bx, [SentencePtr]
        mov ax, [es:bx + 0x2c]
        inc word [es:bx + 0x2c]
        mov [bp - 0x4], ax
        push word [bp + 0x6]
        push cs
        call FindClipByName
        add sp, 0x2
        mov [bp - 0x2a], ax
        inc ax
        jnz short .2
.1:
        les bx, [SentencePtr]
        dec word [es:bx + 0x2c]
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        pop si
        pop di
        leave
        retf
.2:
        push word [bp - 0x2a]
        push cs
        call ClipIsLoaded
        add sp, 0x2
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .4
        mov ax, [bp - 0x2a]
.3:
        mov bx, [bp - 0x4]
        shl bx, 1
        les si, [SentencePtr]
        mov [es:bx + si], ax
        mov ax, 0x1
        pop si
        pop di
        leave
        retf
.4:
        push 0x0
        push cs
        call FindFreeClip
        add sp, 0x2
        mov [bp - 0x2], ax
        inc ax
        jz short .1
        imul ax, [bp - 0x2], 0x24
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        add ax, [SpeechBank]
        mov dx, [SpeechBankSeg]
        push cx
        push ds
        lea di, [bp - 0x28]
        db 0x8B, 0xF0                           ; insn: mov si, ax
        push ss
        pop es
        mov ds, dx
        mov cx, 0x12
        rep movsw
        pop ds
        pop cx
        db 0x8B, 0xD9                           ; insn: mov bx, cx
        les si, [SpeechBank]
        imul ax, [bp - 0x2a], 0x24
        db 0x03, 0xF0                           ; insn: add si, ax
        mov dx, es
        mov di, [SpeechBank]
        push cx
        push ds
        lea di, [bx + di]
        mov ds, dx
        mov cx, 0x12
        rep movsw
        pop ds
        pop cx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov si, [SpeechBank]
        push cx
        lea di, [bx + si]
        lea si, [bp - 0x28]
        mov cx, 0x12
        rep movsw
        pop cx
        mov bx, [SpeechBank]
        db 0x8B, 0xF1                           ; insn: mov si, cx
        mov ax, [es:bx + si + 0x16]
        mov dx, [es:bx + si + 0x18]
        add ax, [es:bx + 0x120c]
        adc dx, [es:bx + 0x120e]
        cmp dx, [es:bx + 0x120a]
        jc short .6
        jna short .5
        jmp near .1
.5:
        cmp ax, [es:bx + 0x1208]
        jna short .6
        jmp near .1
.6:
        push word [bp - 0x2]
        push cs
        call LoadClipToBank
        add sp, 0x2
        mov ax, [bp - 0x2]
        jmp near .3

;-----------------------------------------------------------------------------
; SayEaNhlIntro                                               09B2:128A  94 PC
; Ea_nhl.int.
;-----------------------------------------------------------------------------
SayEaNhlIntro:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_EaNhlInt
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_EaNhlInt_2
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayGoodnight                                                09B2:12EC  94 PC
; Goodnite.int, imrbarr.int.
;-----------------------------------------------------------------------------
SayGoodnight:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_ImrbarrInt
        push cs
        call WantSample
        add sp, 0x2
        push str_GoodniteInt
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_ImrbarrInt
        push cs
        call QueueClip
        add sp, 0x2
        push str_GoodniteInt
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayLineups                                                  09B2:1362  94 PC
; Lineups.int.
;-----------------------------------------------------------------------------
SayLineups:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_LineupsInt
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_LineupsInt
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayElseAroundNhl                                            09B2:13C4  94 PC
; Elsenhl.int.
;-----------------------------------------------------------------------------
SayElseAroundNhl:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_ElsenhlInt
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_ElsenhlInt_2
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayHighlightMatchup                                         09B2:1426  94 PC
; Takeynow, highlite, gamebtwn, home and away teams.
;-----------------------------------------------------------------------------
SayHighlightMatchup:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x32
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Rnk
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x16]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Awa
        push word [bp + 0x8]
        push str_SS
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Hom
        push word [bp + 0xa]
        push str_SS
        lea ax, [bp - 0x32]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_TakeynowBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_HighliteBar
        push cs
        call WantSample
        add sp, 0x2
        push str_GamebtwnBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_AndBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_TakeynowBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_HighliteBar
        push cs
        call QueueClip
        add sp, 0x2
        push str_GamebtwnBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_AndBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SayPlayoffResult                                            09B2:1546  94 PC
; Havewon, division/conf/semi/final, game number, overtime.
;-----------------------------------------------------------------------------
SayPlayoffResult:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x4e
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Awa_2
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x16]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x30]
        push ax
        push word [bp + 0x8]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bar
        lea ax, [bp - 0x23]
        push ax
        push str_SS
        lea ax, [bp - 0x40]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push word [bp + 0xa]
        lea ax, [bp - 0x4e]
        push ax
        push cs
        call DivisionSampleName
        add sp, 0x4
        mov [bp - 0x32], ax
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        cmp word [bp + 0xe], 0x0
        jz short .3
        push str_OvertimeBar
        push cs
        call WantSample
        add sp, 0x2
.3:
        lea ax, [bp - 0x16]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_HavewonBar
        push cs
        call WantSample
        add sp, 0x2
        push str_GamenumBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x40]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x4e]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp - 0x32], 0x1
        jnz short .4
        push str_ConfBar
        jmp short .5
.4:
        cmp word [bp - 0x32], 0x2
        jnz short .6
        push str_DivisionBar
.5:
        push cs
        call WantSample
        add sp, 0x2
.6:
        cmp word [bp + 0xc], 0x1
        jnz short .7
        push str_SemiBar
        push cs
        call WantSample
        add sp, 0x2
        jmp short .8
.7:
        cmp word [bp + 0xc], 0x2
        jnz short .9
.8:
        push str_FinalBar
        push cs
        call WantSample
        add sp, 0x2
.9:
        push cs
        call PrepareSpeechBank
        cmp word [bp + 0xe], 0x0
        jz short .10
        push str_OvertimeBar
        push cs
        call QueueClip
        add sp, 0x2
.10:
        lea ax, [bp - 0x16]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_HavewonBar
        push cs
        call QueueClip
        add sp, 0x2
        push str_GamenumBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x40]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x4e]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp - 0x32], 0x1
        jnz short .11
        push str_ConfBar
        jmp short .12
.11:
        cmp word [bp - 0x32], 0x2
        jnz short .13
        push str_DivisionBar
.12:
        push cs
        call QueueClip
        add sp, 0x2
.13:
        cmp word [bp + 0xc], 0x1
        jnz short .14
        push str_SemiBar
        push cs
        call QueueClip
        add sp, 0x2
        jmp short .15
.14:
        cmp word [bp + 0xc], 0x2
        jnz short .16
.15:
        push str_FinalBar
        push cs
        call QueueClip
        add sp, 0x2
.16:
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayPeriodSummary                                            09B2:16E2  94 PC
; Period, ot, scoring, thegame, theot.
;-----------------------------------------------------------------------------
SayPeriodSummary:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x26
        call 0x0000:__chkstk
        mov word [bp - 0x26], 0x0
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push 0xd
        mov es, [NumberWordsSeg]
        mov bx, [bp + 0x6]
        shl bx, byte 0x2
        push word [es:bx + 0x160]
        push word [es:bx + 0x15e]
        lea ax, [bp - 0x16]
        push ss
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        push str_Bar_2
        lea ax, [bp - 0x16]
        push ax
        push str_SS
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_ScoringBar
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0xa], 0x0
        jz short .3
        push str_ThegameBar
        jmp short .7
.3:
        lea ax, [bp - 0x24]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0x8], 0x0
        jz short .6
        cmp word [bp + 0x6], 0x0
        jz short .4
        push str_OtBar
        jmp short .5
.4:
        push str_TheotBar
.5:
        push cs
        call WantSample
        add sp, 0x2
.6:
        push str_PeriodBar
.7:
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_ScoringBar
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0xa], 0x0
        jz short .8
        push str_ThegameBar
        jmp short .12
        db 0x90
.8:
        lea ax, [bp - 0x24]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0x8], 0x0
        jz short .11
        cmp word [bp + 0x6], 0x0
        jz short .9
        push str_OtBar
        jmp short .10
.9:
        push str_TheotBar
.10:
        push cs
        call QueueClip
        add sp, 0x2
.11:
        push str_PeriodBar
.12:
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayTonightsGame                                             09B2:17FA  94 PC
; Easports, tonight, gamebtwn, the two teams.
;-----------------------------------------------------------------------------
SayTonightsGame:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x32
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Rnk_2
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x16]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Awa_3
        push word [bp + 0x8]
        push str_SS
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Hom_2
        push word [bp + 0xa]
        push str_SS
        lea ax, [bp - 0x32]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_TonightBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_EasportsBar
        push cs
        call WantSample
        add sp, 0x2
        push str_GamebtwnBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_AndBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_TonightBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_EasportsBar
        push cs
        call QueueClip
        add sp, 0x2
        push str_GamebtwnBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_AndBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SayTonightsPlayoffGame                                      09B2:191A  94 PC
; Easports, tonight, between, division/conf/final, game number.
;-----------------------------------------------------------------------------
SayTonightsPlayoffGame:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x6a
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Rnk_3
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x16]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Awa_4
        push word [bp + 0x8]
        push str_SS
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Hom_3
        push word [bp + 0xa]
        push str_SS
        lea ax, [bp - 0x4c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x3e]
        push ax
        push word [bp + 0xc]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bar_3
        lea ax, [bp - 0x31]
        push ax
        push str_SS
        lea ax, [bp - 0x5c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push word [bp + 0xe]
        lea ax, [bp - 0x6a]
        push ax
        push cs
        call DivisionSampleName
        add sp, 0x4
        mov [bp - 0x4e], ax
        push cs
        call ResetSentence
        push cs
        call ResetWantedSamples
        push str_TonightBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_EasportsBar
        push cs
        call WantSample
        add sp, 0x2
        push str_GamenumBar
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x5c]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x6a]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp - 0x4e], 0x1
        jnz short .3
        push str_ConfBar
        jmp short .4
.3:
        cmp word [bp - 0x4e], 0x2
        jnz short .5
        push str_DivisionBar
.4:
        push cs
        call WantSample
        add sp, 0x2
.5:
        cmp word [bp + 0x10], 0x1
        jnz short .6
        push str_SemiBar
        push cs
        call WantSample
        add sp, 0x2
        jmp short .7
.6:
        cmp word [bp + 0x10], 0x2
        jnz short .8
.7:
        push str_FinalBar
        push cs
        call WantSample
        add sp, 0x2
.8:
        push str_BetweenBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_AndBar
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x4c]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_TonightBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x16]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_EasportsBar
        push cs
        call QueueClip
        add sp, 0x2
        push str_GamenumBar
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x5c]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x6a]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp - 0x4e], 0x1
        jnz short .9
        push str_ConfBar
        jmp short .10
.9:
        cmp word [bp - 0x4e], 0x2
        jnz short .11
        push str_DivisionBar
.10:
        push cs
        call QueueClip
        add sp, 0x2
.11:
        cmp word [bp + 0x10], 0x1
        jnz short .12
        push str_SemiBar
        push cs
        call QueueClip
        add sp, 0x2
        jmp short .13
.12:
        cmp word [bp + 0x10], 0x2
        jnz short .14
.13:
        push str_FinalBar
        push cs
        call QueueClip
        add sp, 0x2
.14:
        push str_BetweenBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_AndBar
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x4c]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayPenalty                                                  09B2:1B3C  94 PC
; Penalty.msc, number, at minute/second, off.
;-----------------------------------------------------------------------------
SayPenalty:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0xa0
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x16]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Cty
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x6a]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x84]
        push ax
        push word [bp + 0x8]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru
        lea ax, [bp - 0x84]
        push ax
        push str_SS
        lea cx, [bp - 0x92]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_2
        lea ax, [bp - 0x77]
        push ax
        push str_SS
        lea cx, [bp - 0xa0]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x32]
        push ax
        push word [bp + 0xa]
        push cs
        call GameLengthSampleName
        add sp, 0x4
        push str_Off_5
        push word [bp + 0xc]
        push str_SS
        lea ax, [bp - 0x40]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x84]
        push ax
        push word [bp + 0xe]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_3
        lea ax, [bp - 0x84]
        push ax
        push str_SS
        lea cx, [bp - 0x4e]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_4
        lea ax, [bp - 0x77]
        push ax
        push str_SS
        lea cx, [bp - 0x5c]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x84]
        push ax
        push word [bp + 0x10]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_5
        lea ax, [bp - 0x84]
        push ax
        push str_SS
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_6
        lea ax, [bp - 0x77]
        push ax
        push str_SS
        lea ax, [bp - 0x24]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        lea ax, [bp - 0x6a]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_PenaltyMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x92]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0xa0]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x40]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0x12], 0x0
        jz short .8
        push str_AtMsc
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0xe], 0x0
        jz short .5
        lea ax, [bp - 0x4e]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x5c]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0xe], 0x1
        jnz short .3
        push str_MinuteMsc
        jmp short .4
        db 0x90, 0x90
.3:
        push str_MinutesMsc
.4:
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0x10], 0x0
        jz short .5
        push str_AndMsc
        push cs
        call WantSample
        add sp, 0x2
.5:
        cmp word [bp + 0x10], 0x0
        jz short .8
        lea ax, [bp - 0xe]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0x10], 0x1
        jnz short .6
        push str_SecondMsc
        jmp short .7
        db 0x90
.6:
        push str_SecondsMsc
.7:
        push cs
        call WantSample
        add sp, 0x2
.8:
        push cs
        call PrepareSpeechBank
        lea ax, [bp - 0x6a]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_PenaltyMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x92]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0xa0]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x32]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x40]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0x12], 0x0
        jz short .14
        push str_AtMsc
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0xe], 0x0
        jz short .11
        lea ax, [bp - 0x4e]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x5c]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0xe], 0x1
        jnz short .9
        push str_MinuteMsc
        jmp short .10
        db 0x90, 0x90
.9:
        push str_MinutesMsc
.10:
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0x10], 0x0
        jz short .11
        push str_AndMsc
        push cs
        call QueueClip
        add sp, 0x2
.11:
        cmp word [bp + 0x10], 0x0
        jz short .14
        lea ax, [bp - 0xe]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x24]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0x10], 0x1
        jnz short .12
        push str_SecondMsc
        jmp short .13
        db 0x90
.12:
        push str_SecondsMsc
.13:
        push cs
        call QueueClip
        add sp, 0x2
.14:
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x16]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayPlayerFrom                                               09B2:1E44  94 PC
; Number, from/fromthe, team city, tonight.msc.
;-----------------------------------------------------------------------------
SayPlayerFrom:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x72
        call 0x0000:__chkstk
        mov word [bp - 0x20], 0x0
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
        db 0x90
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        mov [bp - 0x1c], ax
        mov [bp - 0x1e], ax
        push 0x3
        push word [bp + 0x6]
        lea ax, [bp - 0x1e]
        push ax
        call 0x0000:_strncpy
        add sp, 0x6
        mov ax, [bp - 0x1e]
        mov dx, [bp - 0x1c]
        mov [bp - 0xc], ax
        mov [bp - 0xa], dx
        cmp ax, 0x594e
        jnz short .3
        cmp dx, 0x49
        jz short .6
.3:
        cmp ax, 0x594e
        jnz short .4
        cmp dx, 0x52
        jz short .6
.4:
        cmp ax, 0x5341
        jnz short .5
        cmp dx, 0x43
        jz short .6
.5:
        cmp ax, 0x5341
        jnz short .7
        cmp dx, 0x57
        jnz short .7
.6:
        mov word [bp - 0x20], 0x1
.7:
        push str_Cty_2
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x2e]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push 0xd
        mov es, [NumberWordsSeg]
        mov bx, [bp + 0x8]
        shl bx, byte 0x2
        push word [es:bx + 0x16c]
        push word [es:bx + 0x16a]
        lea ax, [bp - 0x1a]
        push ss
        push ax
        call 0x03A3:CopyStrNFar
        add sp, 0xa
        push str_Msc
        lea ax, [bp - 0x1a]
        push ax
        push str_SS
        lea ax, [bp - 0x56]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x48]
        push ax
        push word [bp + 0xa]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_7
        lea ax, [bp - 0x48]
        push ax
        push str_SS
        lea ax, [bp - 0x64]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_8
        lea ax, [bp - 0x3b]
        push ax
        push str_SS
        lea ax, [bp - 0x72]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        push str_TonightMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x56]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp - 0x20], 0x0
        jz short .8
        push str_FromtheMsc
        jmp short .9
.8:
        push str_FromMsc
.9:
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x2e]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x64]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x72]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_TonightMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x56]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp - 0x20], 0x0
        jz short .10
        push str_FromtheMsc
        jmp short .11
        db 0x90
.10:
        push str_FromMsc
.11:
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x2e]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x64]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x72]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf
        db 0x90

;-----------------------------------------------------------------------------
; SayGoal                                                     09B2:2032  94 PC
; Goals.msc, by, number, assisted, and.
;-----------------------------------------------------------------------------
SayGoal:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x84
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x32]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push str_Cty_3
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0x40]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x5a]
        push ax
        push word [bp + 0xa]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_9
        lea ax, [bp - 0x5a]
        push ax
        push str_SS
        lea cx, [bp - 0x68]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_10
        lea ax, [bp - 0x4d]
        push ax
        push str_SS
        lea cx, [bp - 0x76]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x5a]
        push ax
        push word [bp + 0xc]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_11
        lea ax, [bp - 0x5a]
        push ax
        push str_SS
        lea cx, [bp - 0x84]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_12
        lea ax, [bp - 0x4d]
        push ax
        push str_SS
        lea cx, [bp - 0xe]
        push cx
        call 0x0000:_sprintf
        add sp, 0x8
        lea ax, [bp - 0x5a]
        push ax
        push word [bp + 0xe]
        push cs
        call NumberSampleNames
        add sp, 0x4
        push str_Bru_13
        lea ax, [bp - 0x5a]
        push ax
        push str_SS
        lea ax, [bp - 0x1c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Bru_14
        lea ax, [bp - 0x4d]
        push ax
        push str_SS
        lea ax, [bp - 0x2a]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        lea ax, [bp - 0x40]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_GoalsMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_ByMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x68]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x76]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        cmp word [bp + 0x8], 0x0
        jng short .3
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        push str_AssistedMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_ByMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x84]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0xe]
        push ax
        push cs
        call WantSample
        add sp, 0x2
.3:
        cmp word [bp + 0x8], 0x1
        jng short .4
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        push str_AndMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x1c]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x2a]
        push ax
        push cs
        call WantSample
        add sp, 0x2
.4:
        push cs
        call PrepareSpeechBank
        lea ax, [bp - 0x40]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_GoalsMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_ByMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x68]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x76]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        cmp word [bp + 0x8], 0x0
        jng short .5
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        push str_AssistedMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_ByMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x84]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0xe]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
.5:
        cmp word [bp + 0x8], 0x1
        jng short .6
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        push str_AndMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x1c]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x2a]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
.6:
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x32]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; SayOneMinuteLeft                                            09B2:22C0  94 PC
; Onemin.msc.
;-----------------------------------------------------------------------------
SayOneMinuteLeft:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x8
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsSaveMap
        add sp, 0x2
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        push str_OneminMsc
        push cs
        call WantSample
        add sp, 0x2
        push cs
        call PrepareSpeechBank
        push str_OneminMsc
        push cs
        call QueueClip
        add sp, 0x2
        les bx, [SentencePtr]
        mov word [es:bx + 0x32], 0x1
        lea ax, [bp - 0x8]
        push ax
        call 0x03A3:EmsRestoreMap
        mov ax, 0x1
        leave
        retf

;-----------------------------------------------------------------------------
; OpenStudioSpeech                                            09B2:2322  94 PC
; Opens xrbarr2.viv.
;-----------------------------------------------------------------------------
OpenStudioSpeech:
        db 0x33, 0xC0                           ; insn: xor ax, ax
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        retf
        db 0x90
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        push 0x0
        push str_Xrbarr2Viv
        push cs
        call OpenSpeechFile
        add sp, 0x4
        mov ax, 0x1
        retf

;-----------------------------------------------------------------------------
; OpenPlayByPlaySpeech                                        09B2:2354  94 PC
; Opens xbruce2.viv and wants its penalty and goal clips.
;-----------------------------------------------------------------------------
OpenPlayByPlaySpeech:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        mov ax, 0x1c
        call 0x0000:__chkstk
        cmp word [SpeechOn], 0x0
        jnz short .2
.1:
        db 0x2B, 0xC0                           ; insn: sub ax, ax
        leave
        retf
.2:
        push cs
        call SpeechIdle
        db 0x0B, 0xC0                           ; insn: or ax, ax
        jz short .1
        push cs
        call ResetWantedSamples
        push cs
        call ResetSentence
        push 0x1a
        push str_Xbruce2Viv
        push cs
        call OpenSpeechFile
        add sp, 0x4
        push str_Cty_4
        push word [bp + 0x6]
        push str_SS
        lea ax, [bp - 0xe]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_Cty_5
        push word [bp + 0x8]
        push str_SS
        lea ax, [bp - 0x1c]
        push ax
        call 0x0000:_sprintf
        add sp, 0x8
        push str_OneminMsc
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0xe]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        lea ax, [bp - 0x1c]
        push ax
        push cs
        call WantSample
        add sp, 0x2
        push str_GoalsMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_PenaltyMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_NumberMsc
        push cs
        call WantSample
        add sp, 0x2
        push word 0x540
        push cs
        call WantSample
        add sp, 0x2
        push str_2minsOff
        push cs
        call WantSample
        add sp, 0x2
        push str_AssistedMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_ByMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_AtMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_MinutesMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_AndMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_SecondsMsc
        push cs
        call WantSample
        add sp, 0x2
        push str_OneminMsc
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0xe]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        lea ax, [bp - 0x1c]
        push ax
        push cs
        call QueueClip
        add sp, 0x2
        push str_GoalsMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_PenaltyMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_NumberMsc
        push cs
        call QueueClip
        add sp, 0x2
        push word 0x540
        push cs
        call QueueClip
        add sp, 0x2
        push str_2minsOff
        push cs
        call QueueClip
        add sp, 0x2
        push str_AssistedMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_ByMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_AtMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_MinutesMsc
        push cs
        call QueueClip
        add sp, 0x2
        push str_AndMsc
        push cs
        call QueueClip
        db 0x83
