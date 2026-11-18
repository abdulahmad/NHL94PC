; Resident RTLink/Plus overlay manager, and the thunk that calls each overlaid routine. DOS enters at
; __astart, which saves the PSP, sets this manager up, and jumps to the Microsoft C startup. The file-name
; slots and the thunks follow the manager in the same segment.
%include "lib/rtlink/ovl_entries.inc"

; MscStartup is in the C runtime; the Rtl routines are in the RTLink runtime.
SectionStride	equ	18
FileSlotSize	equ	0x80

; Overlay-manager messages. Each eov code is its own string and the
; sentence follows the terminating null. The print helper substitutes
; xxxx with the number it was given.
Messages:                                       ; start of the message pointers below
MsgPtrClose:                                    ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; ReportFileError
        dw MsgCloseQuote
MsgPtrCannot:                                   ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; OpenOverlayFile
        dw MsgEov0001
MsgPtrOpen:                                     ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; OpenOverlayFile
        dw MsgEov0002
MsgPtrRead:                                     ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgEov0003
MsgPtrCommit:                                   ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgEov0007
MsgPtrIntersect:                                ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgIntersectLead
MsgPtrIntersect2:                               ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgIntersect2Lead
MsgPtrCorrupt:                                  ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; CheckThunkList
        dw MsgEov0009
MsgPtrVector:                                   ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; CheckThunkList
        dw MsgVectorAt
MsgPtrAfter:                                    ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgEov0010
MsgPtrAfterH:                                   ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadSection
        dw MsgAfterLead
MsgPtrOverflow:                                 ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; LoadFromThunk
        dw MsgEov0004
MsgPtrUnderflow:                                ; RTLink overlay-manager message (eovxxxx strings); used by
                                                ; PopReloadFrame
        dw MsgEov0005
MsgCloseQuote:                                  ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrClose
        db '"', 13, 10
        db 0
MsgEov0001:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrCannot
        db 'eov0001: '
        db 0
MsgCannotFind:                                  ; text that follows the eov code string before it
        db 'Cannot find overlay file "'
        db 0
MsgEov0002:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrOpen
        db 'eov0002: '
        db 0
MsgOpenError:                                   ; text that follows the eov code string before it
        db 'Open error on overlay file "'
        db 0
MsgEov0003:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrRead
        db 'eov0003: '
        db 0
MsgReadError:                                   ; text that follows the eov code string before it
        db 'Read error on overlay file "'
        db 0
MsgEov0007:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrCommit
        db 'eov0007: '
        db 0
MsgCommit:                                      ; text that follows the eov code string before it
        db 'Commit error - section '
MsgIntersectLead:                               ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrIntersect
        times 4 db 0
MsgIntersect:                                   ; text that follows the eov code string before it
        db 'H intersects committed section '
MsgIntersect2Lead:                              ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrIntersect2
        times 4 db 0
MsgIntersect2:                                  ; text that follows the eov code string before it
        db 'H', 13, 10
        db 0
MsgEov0009:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrCorrupt
        db 'eov0009: '
        db 0
MsgVector:                                      ; text that follows the eov code string before it
        db 'Vector at '
MsgVectorAt:                                    ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrVector
        db 'xxxx:xxxx is corrupted.', 13, 10
        db 0
MsgEov0010:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrAfter
        db 'eov0010: '
        db 0
MsgLoadAfter:                                   ; text that follows the eov code string before it
        db 'Attempt to load section '
MsgAfterLead:                                   ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrAfterH
        times 4 db 0
MsgAfterH:                                      ; text that follows the eov code string before it
        db 'H after $$RTL_TERMINATE.', 13, 10
        db 0
MsgEov0004:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrOverflow
        db 'eov0004: '
        db 0
MsgOverflow:                                    ; text that follows the eov code string before it
        db 'Overlay Manager Internal Reload Stack Overflow', 13, 10
        db '      -- use RELOAD to increase size', 13, 10
        db 0
MsgEov0005:                                     ; RTLink overlay-manager message (eovxxxx strings); in
                                                ; MsgPtrUnderflow
        db 'eov0005: '
        db 0
MsgUnderflow:                                   ; text that follows the eov code string before it
        db 'Overlay Manager Internal Reload Stack Underflow.', 13, 10
        times 7 db 0

;-----------------------------------------------------------------------------
; NotifySectionLoaded                                        1B35:01F0  RTLink
; Far stub called once a section has been marked resident. Returns immediately.
;-----------------------------------------------------------------------------
NotifySectionLoaded:
        nop
        retf

;-----------------------------------------------------------------------------
; ReleaseSection                                             1B35:01F2  RTLink
; Far. SI is the section record and AX is preserved in CX. Returns carry if the section is pinned.
;
; Otherwise clears the resident flag, optionally calls RtlSectionHook, and if ManagerFlags asks for it fills
; the section's memory with 8E8E. Carry clear means the section was released.
;-----------------------------------------------------------------------------
ReleaseSection:
        test byte [si+7], 0x10
        jne .t3
        push ax
        push bx
        push cx
        push dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        test byte [ProbeOn], 0xFF
        je .t1
        test byte [si+7], 0xC
        je .t1
        push es
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        mov es, [si]
        mov cx, [si+8]
        call 0x1DE4:RtlSectionHook              ; section hook
        pop es
.t1:
        and byte [si+7], 0xFD
        test word [ManagerFlags], 0x100         ; audit: poison memory on release
        jne .t4
.t2:
        clc
        pop dx
        pop cx
        pop bx
        pop ax
        retf
.t3:
        stc
        retf
.t4:
        push di
        push es
        mov ax, [si]
        mov cx, [si+8]
.t5:
        push ax
        push cx
        mov dx, 0x1000
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jae .t6
        db 0x8B, 0xD1                           ; insn: mov dx, cx
.t6:
        mov es, ax
        db 0x33, 0xFF                           ; insn: xor di, di
        mov ax, 0x8E8E                          ; fill pattern
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        shl cx, 1
        shl cx, 1
        shl cx, 1
        rep stosw
        pop cx
        pop ax
        db 0x03, 0xC2                           ; insn: add ax, dx
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jne .t5
        pop di
        pop es
        jmp .t2

;-----------------------------------------------------------------------------
; LoadSection                                                1B35:025C  RTLink
; Far. AX is a section index, or -1 to do nothing. Loads that section when it is not already resident, applies
; the overlay relocations, and returns the record's chain value in AX.
;-----------------------------------------------------------------------------
LoadSection:
        cmp ax, 0xFFFF
        jne .t1
        retf
.t1:
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push bp
        push ds
        push es
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        cld
        mov cx, 0x1B35
        mov ds, cx
        call SectionRecord
        mov [CurrentSection], bx
        test word [bx+8], 0xFFFF
        je .t2
        test byte [bx+7], 2
        je .t5
.t2:
        clc
        jmp .t29
.t3:
        mov ax, cs                              ; eov0007, sections intersect
        mov ds, ax
        mov dx, [MsgPtrIntersect]
        mov cx, [bx+0xE]
        call 0x1DE4:RtlWriteHex
        mov dx, [MsgPtrIntersect2]
        mov cx, [si+0xE]
        call 0x1DE4:RtlWriteHex
        mov ax, 7
        mov cx, 3
        mov bx, [MsgPtrCommit]
        jmp ReportOverlayError
.t4:
        mov bx, [CurrentSection]                ; eov0010, load after terminate
        mov ax, cs
        mov ds, ax
        mov dx, [MsgPtrAfterH]
        mov cx, [bx+0xE]
        call 0x1DE4:RtlWriteHex
        mov ax, 0xA
        mov cx, 0
        mov bx, [MsgPtrAfter]
        jmp ReportOverlayError
.t5:
        test byte [OverlaysEnded], 1            ; OverlaysEnded
        jne .t4
        push ax
        mov bx, [CurrentSection]
        mov cx, [SectionCount]
        mov si, SectionTable
.t6:
        test byte [si+7], 2
        je .t8
        mov ax, [si]
        sub ax, [bx]
        jb .t7
        cmp ax, [bx+8]
        jmp .t8
.t7:
        neg ax
        cmp ax, [si+8]
.t8:
        jae .t9
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        sub ax, [SectionCount]
        neg ax
        push cs
        call ReleaseSection
        jae .t9
        jmp .t3
.t9:
        add si, SectionStride
        loop .t6
        pop ax
        test byte [ProbeOn], 0xFF
        je .t10
        test byte [bx+7], 0xC
        je .t10
        push es
        mov es, [bx]
        call 0x1DE4:RtlSectionHook
        pop es
        jb .t10
        jmp .t28
.t10:
        mov si, [bx+2]
        test byte [bx+7], 8
        je .t11
        mov si, [si]
.t11:
        call OpenOverlayFile
        mov dx, [bx+0xA]
        add dx, 3
        shr dx, 1
        shr dx, 1
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov cl, [bx+6]
        add dx, [bx+4]
        adc cx, 0
        db 0x8B, 0xFA                           ; insn: mov di, dx
        mov ax, 0xF
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        db 0x23, 0xC2                           ; insn: and ax, dx
        db 0x0B, 0xC8                           ; insn: or cx, ax
        db 0x33, 0xD0                           ; insn: xor dx, ax
        mov ax, [bx+2]
        test byte [bx+7], 8
        je .t12
        push di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [di]
        pop di
.t12:
        inc ax
        cmp ax, [ExeFileName]
        jne .t13
        push es
        push di
        les di, [ExeDataOff]
        add dx, [es:di]
        adc cx, [es:di+2]
        pop di
        pop es
.t13:
        mov bx, [FileHandle]
        mov ax, 0x4200                          ; DOS seek from the start
        int 0x21
        push ds
        db 0x8B, 0xC3                           ; insn: mov ax, bx
        mov bx, [CurrentSection]
        mov cx, [bx+0x10]
        mov ds, [bx]
        test byte [cs:bx+7], 0x20
        jne .t16
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        dec di
        and di, 0x7F
        inc di
        sub di, 0x1000
        neg di
.t14:
        jcxz .t18
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        db 0x3B, 0xC7                           ; insn: cmp ax, di
        jbe .t15
        db 0x8B, 0xC7                           ; insn: mov ax, di
.t15:
        push ax
        push cx
        mov cl, 4
        shl ax, cl
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov ah, 0x3F                            ; DOS read
        int 0x21
        jb .t17
        pop cx
        pop ax
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        mov dx, ds
        db 0x03, 0xD0                           ; insn: add dx, ax
        mov ds, dx
        mov di, 0xF80
        jmp .t14
.t16:
        push ax
        push word [cs:bx+8]
        push ds
        call 0:0                                ; other read path; far call stored as zeros
        pop ds
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je .t19
.t17:
        mov cx, 0x13F
        mov bx, [cs:MsgPtrRead]
        jmp ReportFileError
.t18:
        mov ax, ds
        pop ds
        mov bx, [CurrentSection]
        mov dx, [bx+8]
        sub dx, [bx+0x10]
        db 0x03, 0xD0                           ; insn: add dx, ax
        call ZeroParagraphs
.t19:
        mov bx, [CurrentSection]
        mov dx, [bx+4]
        mov cl, [bx+6]
        db 0x32, 0xED                           ; insn: xor ch, ch
        mov ax, 0xF
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        shl cx, 1
        rol dx, 1
        db 0x23, 0xC2                           ; insn: and ax, dx
        db 0x0B, 0xC8                           ; insn: or cx, ax
        db 0x33, 0xD0                           ; insn: xor dx, ax
        mov ax, [bx+2]
        test byte [bx+7], 8
        je .t20
        push di
        db 0x8B, 0xF8                           ; insn: mov di, ax
        mov ax, [di]
        pop di
.t20:
        inc ax
        cmp ax, [ExeFileName]
        jne .t21
        push es
        push di
        les di, [ExeDataOff]
        add dx, [es:di]
        adc cx, [es:di+2]
        pop di
        pop es
.t21:
        mov si, [bx+0xA]
        mov bx, [FileHandle]
        mov ax, 0x4200                          ; DOS seek to the relocation table
        int 0x21
.t22:
        db 0x8B, 0xCE                           ; insn: mov cx, si
        jcxz .t28
        cmp cx, 0x58
        jbe .t23
        mov cx, 0x58
.t23:
        db 0x2B, 0xF1                           ; insn: sub si, cx
        push si
        push cx
        shl cx, 1
        shl cx, 1
        mov dx, FixupBuffer
        mov ah, 0x3F                            ; DOS read relocation words
        int 0x21
        jae .t24
        jmp .t17
.t24:
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        je .t25
        jmp .t17
.t25:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov dx, [EntryEs]
        add dx, 0x10                            ; PSP + 10h is the load segment
        pop cx
.t26:
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        add ax, [si+2]
        jb .t27
        mov es, ax
        mov di, [si]
        add [es:di], dx                         ; apply one overlay relocation
.t27:
        add si, 4
        loop .t26
        pop si
        jmp .t22
.t28:
        mov bx, [CurrentSection]
        or byte [bx+7], 2
        clc
        push cs
        call NotifySectionLoaded
.t29:
        mov bx, [CurrentSection]
        mov ax, [bx+0xC]
        pop es
        pop ds
        pop bp
        pop si
        pop di
        pop dx
        pop cx
        jb .t30
        test byte [cs:ChainLoads], 0xFF
        je .t30
        cmp ax, 0xFFFF
        je .t30
        push cs
        call LoadSection
.t30:
        pop bx
        pop ax
        popf
        retf

;-----------------------------------------------------------------------------
; OpenOverlayFile                                            1B35:04E4  RTLink
; Near. SI points at a file slot (the byte in front of the name).
; Opens the overlay, or the EXE, and stores the DOS handle in FileHandle.
;-----------------------------------------------------------------------------
OpenOverlayFile:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push ds
        push es
        inc si
        cmp word [OpenFileName], 0
        je .t2
        mov ax, [FileHandle]
        cmp si, [OpenFileName]
        jne .t1
        jmp .t12
.t1:
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        mov ah, 0x3E                            ; DOS close
        int 0x21
.t2:
        mov [OpenFileName], si
        test byte [si-1], 1
        je .t4
        db 0x8B, 0xD6                           ; insn: mov dx, si
        mov al, [OpenMode]
        mov ah, 0x3D                            ; DOS open
        int 0x21
        jb .t3
        mov [FileHandle], ax
        jmp .t12
.t3:
        mov cx, 0x13D
        mov bx, [MsgPtrOpen]
        jmp ReportFileError
.t4:
        test word [ManagerFlags], 0x80          ; bit 7: do not treat .EXE specially
        jne .t7
        db 0x8B, 0xFE                           ; insn: mov di, si
        mov ax, ds
        mov es, ax
        mov cx, FileSlotSize
        db 0x32, 0xC0                           ; insn: xor al, al
        repne scasb
        mov ax, [es:di-3]
        or ax, 0x2020                           ; lowercase two letters
        cmp ax, 0x6578                          ; last two letters "xe"
        jne .t7
        mov ax, [es:di-5]
        or ah, 0x20
        cmp ax, 0x652E                          ; ".e" of the extension
        jne .t7
        mov ax, [cs:OpenFileName]
        mov [cs:ExeFileName], ax
        mov ax, [EntryEs]
        call 0x1DE4:RtlExePath                  ; path of this EXE from the PSP
        jb .t7
        cmp bx, 0xFFFF
        je .t5
        mov al, [cs:OpenMode]
        mov ah, 0x3D                            ; DOS open
        int 0x21
        jae .t10
        jmp .t7
.t5:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov ax, 0x1B35
        mov es, ax
        mov di, [es:OpenFileName]
.t6:
        lodsb
        stosb
        db 0x0A, 0xC0                           ; insn: or al, al
        jne .t6
.t7:
        mov ax, 0x1B35
        mov ds, ax
        mov si, SearchOrder
        mov es, ax
        mov di, [OpenFileName]
        mov bx, FixupBuffer
        add bx, 0xF
        mov cl, 4
        shr bx, cl
        db 0x03, 0xC3                           ; insn: add ax, bx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, [EntryEs]
        mov bl, [OpenMode]
        call 0x1DE4:RtlFindFile                 ; search for the overlay file
        jae .t8
        mov ax, 1
        mov cx, 1
        mov bx, [MsgPtrCannot]
        jmp ReportFileError
.t8:
        je .t9
        mov dx, [cs:OpenFileName]
        mov [cs:ExeFileName], dx
.t9:
        mov ds, cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
.t10:
        db 0x8B, 0xF2                           ; insn: mov si, dx
        mov bx, 0x1B35
        mov es, bx
        mov [es:FileHandle], ax
        mov di, [es:OpenFileName]
        or byte [es:di-1], 1
.t11:
        lodsb
        stosb
        db 0x0A, 0xC0                           ; insn: or al, al
        jne .t11
.t12:
        pop es
        pop ds
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret

;-----------------------------------------------------------------------------
; LoadFromThunk                                              1B35:05F8  RTLink
; Near. Every overlay thunk calls here. The return address is the thunk's far jump, and the word after that
; jump is the section index.
;
; Pushes a reload frame, loads the section, and rewrites the caller's far return so it comes back through
; OverlayReturnGate.
;-----------------------------------------------------------------------------
LoadFromThunk:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push ds
        pushf
        mov dx, 0x1B35
        mov ds, dx
        test word [ManagerFlags], 0x100         ; audit thunks on entry
        je .t1
        call CheckThunkList
.t1:
        mov bx, [bp+2]
        mov ax, [bx+5]
        push ax
        mov si, [ReloadBase]
        mov ax, [ReloadSp]
        db 0x03, 0xF0                           ; insn: add si, ax
        add ax, 6
        mov [ReloadSp], ax
        cmp ax, [ReloadLimit]
        jb .t2
        mov ax, 2
        mov cx, 2
        mov bx, [MsgPtrOverflow]
        jmp ReportOverlayError                  ; eov0004, reload stack overflow
.t2:
        pop cx
        mov ds, [ReloadSeg]
        mov [si], cx
        test word [cs:ManagerFlags], 1          ; bit 0: keep the caller's CS on the frame
        jne .t3
        mov ax, 0x1B35
        jmp .t4
.t3:
        mov ax, [bp+6]
        mov word [bp+6], 0x1B35
.t4:
        mov [si+4], ax
        mov ax, [bp+4]
        mov [si+2], ax
        mov word [bp+4], OverlayReturnGate
        mov ax, cs
        mov ds, ax
        db 0x8B, 0xC1                           ; insn: mov ax, cx
        push cs
        call LoadSection
        popf
        pop ds
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop bp
        ret

;-----------------------------------------------------------------------------
; SectionRecord                                              1B35:067B  RTLink
; Near. AX is a section index. Returns BX pointing at that record.
;-----------------------------------------------------------------------------
SectionRecord:
        push ax
        push dx
        mov bx, SectionStride
        mul bx
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        add bx, SectionTable
        pop dx
        pop ax
        ret

;-----------------------------------------------------------------------------
; ZeroParagraphs                                             1B35:068B  RTLink
; Near. Zeros memory from segment AX up to, but not including, segment DX.
;-----------------------------------------------------------------------------
ZeroParagraphs:
        db 0x3B, 0xC2                           ; insn: cmp ax, dx
        je .t3
        push ax
        push cx
        push dx
        push di
        push es
        db 0x2B, 0xD0                           ; insn: sub dx, ax
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        mov es, ax
.t1:
        push cx
        mov dx, 0x1000
        db 0x3B, 0xCA                           ; insn: cmp cx, dx
        jae .t2
        db 0x8B, 0xD1                           ; insn: mov dx, cx
.t2:
        db 0x8B, 0xCA                           ; insn: mov cx, dx
        shl cx, 1
        shl cx, 1
        shl cx, 1
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x8B, 0xF8                           ; insn: mov di, ax
        rep stosw
        mov ax, es
        db 0x03, 0xC2                           ; insn: add ax, dx
        mov es, ax
        pop cx
        db 0x2B, 0xCA                           ; insn: sub cx, dx
        jne .t1
        pop es
        pop di
        pop dx
        pop cx
        pop ax
.t3:
        ret

;-----------------------------------------------------------------------------
; MeasureThunkList                                           1B35:06C3  RTLink
; Near. The file slots sit just before the thunks. Remembers the first thunk
; and the first byte after the last well-formed thunk.
;-----------------------------------------------------------------------------
MeasureThunkList:
        push es
        push ds
        push di
        push si
        push cx
        mov di, cs
        mov ds, di
        mov es, di
        db 0x33, 0xFF                           ; insn: xor di, di
        mov si, SectionTable
        mov cx, [SectionCount]
.t1:
        cmp di, [si+2]
        ja .t2
        mov di, [si+2]
.t2:
        loop .t1
        add di, FileSlotSize
        mov [ThunkListStart], di
        db 0x8B, 0xF7                           ; insn: mov si, di
.t3:
        call IsOverlayThunk
        jae .t3
        mov [ThunkListEnd], si
        pop cx
        pop si
        pop di
        pop ds
        pop es
        ret

;-----------------------------------------------------------------------------
; CheckThunkList                                             1B35:06FA  RTLink
; Near. Walks the thunks MeasureThunkList recorded. Fatal eov0009 if the
; list no longer ends at the recorded byte.
;-----------------------------------------------------------------------------
CheckThunkList:
        push ds
        push si
        mov si, cs
        mov ds, si
        mov si, [ThunkListStart]
.t1:
        call IsOverlayThunk
        jae .t1
        cmp si, [ThunkListEnd]
        jne .t2
        pop si
        pop ds
        ret
.t2:
        mov cx, ds
        mov ax, [EntryEs]
        db 0x2B, 0xC8                           ; insn: sub cx, ax
        sub cx, 0x10
        mov dx, [MsgPtrVector]
        call 0x1DE4:RtlWriteHex                 ; eov0009, vector corrupted
        db 0x8B, 0xCE                           ; insn: mov cx, si
        mov dx, [MsgPtrVector]
        add dx, 5
        call 0x1DE4:RtlWriteHex
        mov ax, 0x12
        mov cx, 3
        mov bx, [MsgPtrCorrupt]
        jmp ReportOverlayError                  ; eov0009

;-----------------------------------------------------------------------------
; IsOverlayThunk                                             1B35:0740  RTLink
; Near. SI points at a candidate thunk. Carry clear (and SI moved past it) when it is a near call to
; LoadFromThunk, a far jump, and a section index below SectionCount. Carry set leaves SI where it was.
;-----------------------------------------------------------------------------
IsOverlayThunk:
        push ax
        push si
        lodsb
        cmp al, 0xE8
        jne .t1
        lodsw
        db 0x03, 0xC6                           ; insn: add ax, si
        cmp ax, LoadFromThunk                   ; the near call must land on LoadFromThunk
        jne .t1
        lodsb
        cmp al, 0xEA
        jne .t1
        add si, 4
        lodsw
        cmp ax, [SectionCount]
        jae .t1
        add sp, 2
        pop ax
        clc
        ret
.t1:
        pop si
        pop ax
        stc
        ret

; Filled in by MeasureThunkList when the audit flag is on.
ThunkListStart:                                 ; RTLink overlay manager data; used by MeasureThunkList,
                                                ; CheckThunkList
        dw 0
ThunkListEnd:                                   ; RTLink overlay manager data; used by MeasureThunkList,
                                                ; CheckThunkList
        dw 0

;-----------------------------------------------------------------------------
; LoadSectionAl                                              1B35:076C  RTLink
; Far entry published through LoadEntryPtr. AL is a 1-based section number.
;-----------------------------------------------------------------------------
LoadSectionAl:
        db 0x32, 0xE4                           ; insn: xor ah, ah
        dec ax
        jmp LoadSection

;-----------------------------------------------------------------------------
; OverlayReturn                                              1B35:0772  RTLink
; Far hook written over a vector the program returns through. If the return frame belongs to a thunk, joins
; ReloadUnwind. Otherwise jumps through the vector that was there before.
;-----------------------------------------------------------------------------
OverlayReturn:
        pushf
        push ax
        cmp word [ss:bx+2], OverlayReturnGate
        jne .t1
        mov ax, cs
        cmp [ss:bx+4], ax
        jne .t1
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push si
        push ds
        mov si, [cs:ReloadSp]
        add si, [cs:ReloadBase]
        mov ds, [cs:ReloadSeg]
        mov ax, [si-6]
        inc ax
        lds si, [cs:ReturnBytePtr]
        mov [si], al
        mov ax, [bp+2]
        mov [bp-2], ax
        mov ax, [bp+4]
        mov [bp+2], ax
        mov ax, PassToSavedHook
        mov [bp+4], ax
        lea bp, [bx-4]
        jmp ReloadUnwind
.t1:
        pop ax
        popf

PassToSavedHook:
        jmp far [cs:SavedHook]

;-----------------------------------------------------------------------------
; OverlayReturnGate                                          1B35:07C4  RTLink
; Far address planted as an overlay routine's return: pop one reload frame,
; then return far to the real caller.
;-----------------------------------------------------------------------------
OverlayReturnGate:
        call PopReloadFrame
        retf

;-----------------------------------------------------------------------------
; PopReloadFrame                                             1B35:07C8  RTLink
; Near. Pops one reload frame and reloads the section that was underneath.
; Fatal eov0005 if the reload stack underflows.
;-----------------------------------------------------------------------------
PopReloadFrame:
        pushf
        sub sp, 4
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ax
        push bx
        push cx
        push si
        push ds
        mov ax, [bp+6]
        mov [bp+2], ax
        mov ax, [bp+8]
        mov [bp+4], ax

; Shared tail of OverlayReturn and PopReloadFrame.
ReloadUnwind:
        mov ax, 0x1B35
        mov ds, ax
        mov si, [ReloadSp]
        sub si, 6
        jb .t2
        mov [ReloadSp], si
        add si, [ReloadBase]
        mov ds, [ReloadSeg]
        mov ax, [si+2]
        mov [bp+6], ax
        mov ax, [si+4]
        mov [bp+8], ax
        test word [cs:ReloadSp], 0xFFFF
        je .t1
        sub si, 6
        mov ax, [si]
        push cs
        pop ds
        push cs
        call LoadSection
.t1:
        pop ds
        pop si
        pop cx
        pop bx
        pop ax
        pop bp
        popf
        ret
.t2:
        mov ax, 3
        mov cx, 2
        mov bx, [MsgPtrUnderflow]
        jmp ReportOverlayError                  ; eov0005, reload stack underflow

;-----------------------------------------------------------------------------
; __astart                                                   1B35:082F  RTLink
; DOS enters here (e_ip). ES and DS are the PSP. Saves them, initialises the
; overlay manager, and jumps to the Microsoft C startup.
;-----------------------------------------------------------------------------
__astart:
        mov [cs:EntryEs], es
        mov [cs:EntryDs], ds
        mov bx, 0x1B35
        mov ds, bx
        push ds
        call InitOverlay
        pop ds
        mov bx, [InitStackSeg]
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je .t1
        mov cx, ss
        db 0x8B, 0xD4                           ; insn: mov dx, sp
        cli
        mov ss, bx
        mov sp, 0x200                           ; temporary stack for init
        sti
.t1:
        push bx
        push cx
        push dx
        push ds
        call PrepareSections
        pop ds
        pop dx
        pop cx
        pop bx
        db 0x0B, 0xDB                           ; insn: or bx, bx
        je .t2
        cli
        mov ss, cx
        db 0x8B, 0xE2                           ; insn: mov sp, dx
        sti
.t2:
        mov es, [EntryEs]
        mov ds, [EntryDs]
        jmp 0:MscStartup                        ; Microsoft C startup

;-----------------------------------------------------------------------------
; InitOverlay                                                1B35:0878  RTLink
; Near, from __astart. Records the PSP terminate vector, registers EndOverlays,
; and places the reload stack after the section table.
;-----------------------------------------------------------------------------
InitOverlay:
        pushf
        cld
        mov es, [cs:EntryEs]
        call 0x1DE4:RtlSaveVectors              ; remember the PSP terminate vector
        mov al, 1
        mov dx, EndOverlays
        call 0x1DE4:RtlSetHandler               ; register EndOverlays
        mov ax, [SectionCount]
        call SectionRecord
        mov [SectionEnd], bx
        mov ax, [ReloadPad]
        db 0x8B, 0xD8                           ; insn: mov bx, ax
        shl bx, 1
        shl bx, 1
        shl bx, 1
        shl bx, 1
        shl bx, 1
        add bx, [cs:SectionEnd]
        mov word [ReloadSp], 0
        mov [ReloadBase], bx
        mov ax, [ReloadStackBytes]
        db 0x03, 0xD8                           ; insn: add bx, ax
        mov [ReloadLimit], ax
        push ds
        mov ax, cs
        mov es, ax
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov ds, ax
        db 0x8B, 0xD0                           ; insn: mov dx, ax
        mov ax, [cs:SectionCount]
        mov cx, [cs:EntryEs]
        call 0x1DE4:RtlSectionHook
        pop ds
        jae .t1
        test word [ReloadPad], 0xFFFF
        je .t2
.t1:
        mov byte [ProbeOn], 0xFF
.t2:
        popf
        ret

;-----------------------------------------------------------------------------
; PrepareSections                                            1B35:08E9  RTLink
; Near, from __astart. Checks the DOS version, optionally audits thunks, records the section memory span,
; preloads sections, and installs OverlayReturn and LoadSectionAl.
;-----------------------------------------------------------------------------
PrepareSections:
        pushf
        cld
        mov ax, 0x3000                          ; DOS version
        int 0x21
        cmp al, 3
        jb .t1
        mov byte [OpenMode], 0xA0               ; DOS 3+ open mode: read, deny-write
.t1:
        test word [ManagerFlags], 0x100         ; audit the thunk list once
        je .t2
        call MeasureThunkList
.t2:
        test word [ManagerFlags], 2             ; bit 1: zero the span the sections occupy
        jne .t3
        mov ax, [MemLowOut]
        or ax, [MemLowOut+2]
        or ax, [MemHighOut]
        or ax, [MemHighOut+2]
        je .t7
.t3:
        mov cx, [SectionCount]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov bx, SectionTable
        mov ax, 0xFFFF
        db 0x33, 0xD2                           ; insn: xor dx, dx
.t4:
        push cx
        mov cx, [bx]
        db 0x0B, 0xC9                           ; insn: or cx, cx
        je .t6
        db 0x3B, 0xC1                           ; insn: cmp ax, cx
        jbe .t5
        db 0x8B, 0xC1                           ; insn: mov ax, cx
.t5:
        add cx, [bx+8]
        db 0x3B, 0xD1                           ; insn: cmp dx, cx
        jae .t6
        db 0x8B, 0xD1                           ; insn: mov dx, cx
.t6:
        pop cx
        add bx, SectionStride
        loop .t4
        mov [MemLow], ax
        mov [MemHigh], dx
        test word [ManagerFlags], 2
        je .t7
        call ZeroParagraphs
.t7:
        mov cx, [cs:SectionCount]
        db 0x33, 0xC0                           ; insn: xor ax, ax
        db 0x33, 0xF6                           ; insn: xor si, si
        mov bx, SectionTable
.t8:
        db 0x0B, 0xF6                           ; insn: or si, si
        jne .t9
        mov si, [bx+2]
        db 0x0B, 0xF6                           ; insn: or si, si
        je .t9
        test byte [bx+7], 8
        je .t9
        mov si, [si]
.t9:
        test byte [bx+7], 1
        je .t10
        push cs
        call LoadSection
.t10:
        add bx, SectionStride
        inc ax
        loop .t8
        cmp word [OpenFileName], 0
        jne .t11
        db 0x0B, 0xF6                           ; insn: or si, si
        je .t11
        call OpenOverlayFile
.t11:
        call 0x1DE4:RtlAfterFiles               ; after the files are open
        mov ax, [MemLowOut]
        or ax, [MemLowOut+2]
        je .t12
        les bx, [MemLowOut]
        mov ax, [MemLow]
        mov [es:bx], ax
.t12:
        mov ax, [MemHighOut]
        or ax, [MemHighOut+2]
        je .t13
        les bx, [MemHighOut]
        mov ax, [MemHigh]
        mov [es:bx], ax
.t13:
        push ds
        push si
        lds si, [cs:LoadEntryPtr]
        mov word [si], LoadSectionAl            ; publish the 1-based loader
        mov [si+2], cs
        lds si, [cs:ReturnHookPtr]
        mov ax, OverlayReturn                   ; hook returns through OverlayReturn
        mov bx, cs
        xchg [si], ax
        xchg [si+2], bx
        pop si
        pop ds
        mov [SavedHook], ax
        mov [SavedHook+2], bx
        popf
        ret

;-----------------------------------------------------------------------------
; ReloadStateSize                                            1B35:09E9  RTLink
; Far. Returns in AX how many bytes SaveReloadState will write.
; The last record (the EXE itself) is not included.
;-----------------------------------------------------------------------------
ReloadStateSize:
        push bx
        push cx
        push ds
        mov ax, 0x1B35
        mov ds, ax
        mov cx, [SectionCount]
        dec cx
        db 0x33, 0xC0                           ; insn: xor ax, ax
        mov bx, SectionTable
.t1:
        test byte [bx+7], 2
        je .t2
        add ax, 2
        test byte [bx+7], 8
        je .t2
        add ax, 2
.t2:
        add bx, SectionStride
        loop .t1
        add ax, 2
        pop ds
        pop cx
        pop bx
        retf

;-----------------------------------------------------------------------------
; SaveReloadState                                            1B35:0A19  RTLink
; Far. The argument is a far pointer to a buffer. Saves the reload stack
; pointer and one entry for each resident section.
;-----------------------------------------------------------------------------
SaveReloadState:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        lds dx, [bp+6]
        jmp SaveReloadBody

;-----------------------------------------------------------------------------
; SaveReloadStateNear                                        1B35:0A22  RTLink
; Near entry for the same save. The caller has already set DS:DX to the buffer.
;-----------------------------------------------------------------------------
SaveReloadStateNear:
        push bp
        push ds

; Body shared by SaveReloadState and SaveReloadStateNear.
SaveReloadBody:
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push es
        cld
        mov ax, ds
        mov es, ax
        db 0x8B, 0xFA                           ; insn: mov di, dx
        mov ax, 0x1B35
        mov ds, ax
        mov ax, [ReloadSp]
        stosw
        mov cx, [SectionCount]
        dec cx
        db 0x33, 0xD2                           ; insn: xor dx, dx
        mov bx, SectionTable
.t1:
        test byte [bx+7], 2
        je .t2
        db 0x8B, 0xC2                           ; insn: mov ax, dx
        stosw
        test byte [bx+7], 8
        je .t2
        mov si, [bx+2]
        mov ax, [si+0xA]
        stosw
.t2:
        add bx, SectionStride
        inc dx
        loop .t1
        pop es
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        pop ds
        pop bp
        retf

;-----------------------------------------------------------------------------
; RestoreReloadState                                         1B35:0A6D  RTLink
; Far. The argument is a far pointer to a buffer saved by SaveReloadState,
; plus the byte count. Loads those sections again.
;-----------------------------------------------------------------------------
RestoreReloadState:
        push bp
        db 0x8B, 0xEC                           ; insn: mov bp, sp
        push ds
        lds dx, [bp+6]
        mov ax, [bp+0xA]
        jmp RestoreReloadBody

;-----------------------------------------------------------------------------
; RestoreReloadStateNear                                     1B35:0A79  RTLink
; Near entry for the same restore. DS:DX is the buffer and AX is the length.
;-----------------------------------------------------------------------------
RestoreReloadStateNear:
        push bp
        push ds

; Body shared by RestoreReloadState and RestoreReloadStateNear.
RestoreReloadBody:
        pushf
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        push es
        cld
        db 0x8B, 0xF2                           ; insn: mov si, dx
        db 0x8B, 0xC8                           ; insn: mov cx, ax
        mov ax, 0x1B35
        mov es, ax
        lodsw
        sub cx, 2
        mov [es:ReloadSp], ax
        mov dl, [es:ChainLoads]
        mov byte [es:ChainLoads], 0
.t1:
        jcxz .t3
        lodsw
        sub cx, 2
        push cs
        call LoadSection
        call SectionRecord
        test byte [es:bx+7], 8
        je .t1
        lodsw
        sub cx, 2
        mov di, [es:bx+2]
        mov [es:di+0xA], ax
        db 0x0B, 0xC0                           ; insn: or ax, ax
        je .t2
        or byte [es:bx+7], 0x10
        jmp .t1
.t2:
        and byte [es:bx+7], 0xEF
        jmp .t1
.t3:
        mov [es:ChainLoads], dl
        pop es
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        pop ds
        pop bp
        retf

;-----------------------------------------------------------------------------
; EndOverlays                                                1B35:0AE2  RTLink
; Far. Closes the overlay file and sets OverlaysEnded. A load after this
; is fatal (eov0010, after $$RTL_TERMINATE).
;-----------------------------------------------------------------------------
EndOverlays:
        push ax
        push es
        push cs
        call CloseOverlayFile
        mov ax, 0x1B35
        mov es, ax
        mov byte [es:OverlaysEnded], 1
        pop es
        pop ax
        retf

;-----------------------------------------------------------------------------
; CloseOverlayFile                                           1B35:0AF6  RTLink
; Far. Closes FileHandle when a file is open. AX is 0, or -1 if DOS refused.
;-----------------------------------------------------------------------------
CloseOverlayFile:
        push bx
        push es
        call 0x1DE4:RtlBeforeClose              ; before the handle is closed
        mov ax, 0x1B35
        mov es, ax
        mov ax, 0
        cmp word [es:OpenFileName], 0
        je .t2
        mov bx, [es:FileHandle]
        mov ah, 0x3E                            ; DOS close
        int 0x21
        jb .t1
        mov word [es:OpenFileName], 0
        mov ax, 0
        jmp .t2
.t1:
        mov ax, 0xFFFF
.t2:
        pop es
        pop bx
        retf

;-----------------------------------------------------------------------------
; ReportFileError                                            1B35:0B2A  RTLink
; Near. BX points at an eov message (code, then text). Fatal, and the open
; file name is passed along with the message.
;-----------------------------------------------------------------------------
ReportFileError:
        call SetupErrorText
        mov dx, [OpenFileName]
        mov [ErrorFile], dx
        mov dx, [MsgPtrClose]
        mov [ErrorLead], dx
        jmp far [es:si]

; Arguments handed to the fatal-error routine.
ErrorMsg:                                       ; RTLink overlay manager data; used by SetupErrorText
        dw 0
;-----------------------------------------------------------------------------
; ErrorText                                                  1B35:0B42  RTLink
; RTLink overlay manager data.
;-----------------------------------------------------------------------------
ErrorText:                                      ; RTLink overlay manager data; used by SetupErrorText
        dw 0                                    ; first byte after the message's null
ErrorFile:                                      ; RTLink overlay manager data; used by ReportFileError
        dw 0                                    ; open file name, file errors only
ErrorLead:                                      ; RTLink overlay manager data; used by ReportFileError
        dw 0                                    ; the closing-quote message
        dw 0

;-----------------------------------------------------------------------------
; ReportOverlayError                                         1B35:0B4A  RTLink
; Near. BX points at an eov message. Fatal, without a file name.
;-----------------------------------------------------------------------------
ReportOverlayError:
        call SetupErrorText
        jmp far [es:si]

;-----------------------------------------------------------------------------
; SetupErrorText                                             1B35:0B50  RTLink
; Near. BX points at a message. Stores that pointer and the first byte after
; its terminating null, and loads the far pointer the reporter jumps through.
;-----------------------------------------------------------------------------
SetupErrorText:
        mov dx, cs
        mov ds, dx
        mov [ErrorMsg], bx
.t1:
        inc bx
        cmp byte [bx], 0
        je .t2
        jmp .t1
.t2:
        inc bx
        mov [ErrorText], bx
        mov bx, ErrorMsg
        les si, [ErrorVector]
        ret

; Working storage for the manager. Paragraphs here are relocated.
ErrorVector:                                    ; RTLink overlay manager data; used by SetupErrorText
        dw RtlErrorSlot
        dw 0x1DE4                               ; segment of the RTLink runtime, relocated
        db 0x90                                 ; not read
ReloadSp:                                       ; RTLink overlay manager data; used by LoadFromThunk,
                                                ; OverlayReturn, PopReloadFrame ...
        dw 0
ReloadBase:                                     ; RTLink overlay manager data; used by LoadFromThunk,
                                                ; OverlayReturn, PopReloadFrame ...
        dw 0                                    ; offset of the reload stack
ReloadSeg:                                      ; RTLink overlay manager data; used by LoadFromThunk,
                                                ; OverlayReturn, PopReloadFrame
        dw 0x1B35                               ; segment of this overlay manager, relocated
ReloadLimit:                                    ; RTLink overlay manager data; used by LoadFromThunk,
                                                ; InitOverlay
        dw 0
ReturnHookPtr:                                  ; RTLink overlay manager data; used by PrepareSections
        dw 0xE35E                               ; offset in the relocated segment
        dw 0x45C9                               ; relocated
LoadEntryPtr:                                   ; RTLink overlay manager data; used by PrepareSections
        dw 0xE362                               ; offset in the relocated segment
        dw 0x45C9                               ; relocated
ReturnBytePtr:                                  ; RTLink overlay manager data; used by OverlayReturn
        dw 0xE36D                               ; offset in the relocated segment
        dw 0x45C9                               ; relocated
SavedHook:                                      ; RTLink overlay manager data; used by OverlayReturn,
                                                ; PrepareSections
        dd 0
SearchOrder:                                    ; RTLink overlay manager data; used by OpenOverlayFile
        db 'C,P,EPATH,A', 0                     ; where to look for an overlay
ProbeOn:                                        ; RTLink overlay manager data; used by ReleaseSection,
                                                ; LoadSection, InitOverlay
        db 0
OpenMode:                                       ; RTLink overlay manager data; used by OpenOverlayFile,
                                                ; PrepareSections
        db 0                                    ; DOS open mode; 0A0h once DOS is 3 or newer
EntryEs:                                        ; RTLink overlay manager data; used by LoadSection,
                                                ; OpenOverlayFile, CheckThunkList ...
        dw 0                                    ; PSP, from ES at entry
EntryDs:                                        ; RTLink overlay manager data; used by __astart
        dw 0                                    ; DS at entry, restored for the C startup
CurrentSection:                                 ; RTLink overlay manager data; used by LoadSection
        dw 0
OpenFileName:                                   ; RTLink overlay manager data; used by OpenOverlayFile,
                                                ; PrepareSections, CloseOverlayFile ...
        dw 0
FileHandle:                                     ; word; used by LoadSection, OpenOverlayFile, CloseOverlayFile
        dw 0
;-----------------------------------------------------------------------------
; SectionEnd                                                 1B35:0BA2  RTLink
; Not a routine: the word after the overlay section table, then the buffer overlay
; relocations are read into.
;-----------------------------------------------------------------------------
SectionEnd:                                     ; word; used by InitOverlay
        dw 0                                    ; first byte after the section table
FixupBuffer:                                    ; overlay relocations are read into here
        times 0x15C db 0                        ; up to the parameter block

; Parameters and the section table. The bytes from 0D10h through 0D20h
; are not read by this segment.
        dw 0, 0
ChainLoads:                                     ; RTLink overlay manager data; used by LoadSection,
                                                ; RestoreReloadStateNear
        db 0xFF                                 ; nonzero: a loaded section may load another
MemLow:                                         ; RTLink overlay manager data; used by PrepareSections
        dw 0
MemHigh:                                        ; RTLink overlay manager data; used by PrepareSections
        dw 0
;-----------------------------------------------------------------------------
; ExeFileName                                                1B35:0D09  RTLink
; RTLink overlay manager data.
;-----------------------------------------------------------------------------
ExeFileName:                                    ; RTLink overlay manager data; used by LoadSection,
                                                ; OpenOverlayFile
        dw 0xFFFF                               ; file whose seek gets ExeDataOff added
ExeDataOff:                                     ; RTLink overlay manager data; used by LoadSection
        dw RtlFileAdjust
        dw 0x1DE4                               ; segment of the RTLink runtime, relocated
OverlaysEnded:                                  ; RTLink overlay manager data; used by LoadSection,
                                                ; EndOverlays
        db 0
        db 0x90, 0x2D, 0x0D, 0x33, 0x0D, 0x12, 0x00, 0x07, 0x01 ; unidentified
        db 0x08, 0x0C, 0x0C, 0x0E, 0x00, 0x00, 0x20, 0x90
ManagerFlags:                                   ; RTLink overlay manager data; used by ReleaseSection,
                                                ; OpenOverlayFile, LoadFromThunk ...
        dw 1                                    ; bit 0: keep the caller's CS
InitStackSeg:                                   ; RTLink overlay manager data; used by __astart
        dw 0x5580                               ; stack used during init, relocated
MemLowOut:                                      ; RTLink overlay manager data; used by PrepareSections
        dd 0                                    ; far pointer that receives MemLow
MemHighOut:                                     ; RTLink overlay manager data; used by PrepareSections
        dd 0                                    ; far pointer that receives MemHigh
SectionCount:                                   ; word; used by LoadSection, MeasureThunkList, IsOverlayThunk
                                                ; ...
        dw (SectionEndMark - SectionTable) / SectionStride
ReloadPad:                                      ; RTLink overlay manager data; used by InitOverlay
        dw 0                                    ; times 32, bytes inserted before the stack
ReloadStackBytes:                               ; RTLink overlay manager data; used by InitOverlay
        dw 0x6C0                                ; reload stack size

; One record per overlay file, 18 bytes, then the EXE as the last record. +0 load paragraph (relocated), +2
; file slot, +4 file position in paragraphs (24 bits, the high byte is +6), +7 flags, +8 memory size in
; paragraphs, +0Ah relocation count, +0Ch section to load next or -1, +0Eh number printed in errors, +10h
;
; paragraphs to read.
SectionTable:                                   ; used by LoadSection, SectionRecord, MeasureThunkList ...
SecMenus:                                       ; 18-byte section record for MENUS.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x1E45                               ; load paragraph, relocated
        dw FileMenus                            ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1249                               ; memory size, paragraphs
        dw 0x979                                ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 2                                    ; number printed in errors
        dw 0x1249                               ; paragraphs to read
SecLp:                                          ; 18-byte section record for LP.OVL; a record of SectionTable,
                                                ; reached by section number
        dw 0x1E45                               ; load paragraph, relocated
        dw FileLp                               ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x116E                               ; memory size, paragraphs
        dw 0x876                                ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 3                                    ; number printed in errors
        dw 0x116E                               ; paragraphs to read
SecStats:                                       ; 18-byte section record for STATS.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x1E45                               ; load paragraph, relocated
        dw FileStats                            ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x9BF                                ; memory size, paragraphs
        dw 0x503                                ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 4                                    ; number printed in errors
        dw 0x9BF                                ; paragraphs to read
SecGame:                                        ; 18-byte section record for GAME.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x1E45                               ; load paragraph, relocated
        dw FileGame                             ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x157                                ; memory size, paragraphs
        dw 0x93                                 ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 5                                    ; number printed in errors
        dw 0x157                                ; paragraphs to read
SecInit:                                        ; 18-byte section record for INIT.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x1F9C                               ; load paragraph, relocated
        dw FileInit                             ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x987                                ; memory size, paragraphs
        dw 0x48C                                ; relocation entries
        dw 3                                    ; section to chain, or -1
        dw 6                                    ; number printed in errors
        dw 0x987                                ; paragraphs to read
SecAi:                                          ; 18-byte section record for AI.OVL; a record of SectionTable,
                                                ; reached by section number
        dw 0x1F9C                               ; load paragraph, relocated
        dw FileAi                               ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x13AD                               ; memory size, paragraphs
        dw 0x4AB                                ; relocation entries
        dw 3                                    ; section to chain, or -1
        dw 7                                    ; number printed in errors
        dw 0x13AD                               ; paragraphs to read
SecMovie:                                       ; 18-byte section record for MOVIE.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3349                               ; load paragraph, relocated
        dw FileMovie                            ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0xCC                                 ; memory size, paragraphs
        dw 0x21                                 ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 8                                    ; number printed in errors
        dw 0xCC                                 ; paragraphs to read
SecFades:                                       ; 18-byte section record for FADES.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3349                               ; load paragraph, relocated
        dw FileFades                            ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0xF                                  ; memory size, paragraphs
        dw 4                                    ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 9                                    ; number printed in errors
        dw 0xF                                  ; paragraphs to read
SecFades1:                                      ; 18-byte section record for FADES1.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades1                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1C                                 ; memory size, paragraphs
        dw 8                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xA                                  ; number printed in errors
        dw 0x1C                                 ; paragraphs to read
SecFades2:                                      ; 18-byte section record for FADES2.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades2                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1E                                 ; memory size, paragraphs
        dw 2                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xB                                  ; number printed in errors
        dw 0x1E                                 ; paragraphs to read
SecFades3:                                      ; 18-byte section record for FADES3.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades3                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1D                                 ; memory size, paragraphs
        dw 3                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xC                                  ; number printed in errors
        dw 0x1D                                 ; paragraphs to read
SecFades4:                                      ; 18-byte section record for FADES4.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades4                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0xE                                  ; memory size, paragraphs
        dw 0xA                                  ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xD                                  ; number printed in errors
        dw 0xE                                  ; paragraphs to read
SecFades5:                                      ; 18-byte section record for FADES5.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades5                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1C                                 ; memory size, paragraphs
        dw 7                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xE                                  ; number printed in errors
        dw 0x1C                                 ; paragraphs to read
SecFades6:                                      ; 18-byte section record for FADES6.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades6                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x17                                 ; memory size, paragraphs
        dw 7                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0xF                                  ; number printed in errors
        dw 0x17                                 ; paragraphs to read
SecFades7:                                      ; 18-byte section record for FADES7.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades7                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x21                                 ; memory size, paragraphs
        dw 3                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x10                                 ; number printed in errors
        dw 0x21                                 ; paragraphs to read
SecFades8:                                      ; 18-byte section record for FADES8.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades8                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x20                                 ; memory size, paragraphs
        dw 0xA                                  ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x11                                 ; number printed in errors
        dw 0x20                                 ; paragraphs to read
SecFades9:                                      ; 18-byte section record for FADES9.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades9                           ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x11                                 ; memory size, paragraphs
        dw 2                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x12                                 ; number printed in errors
        dw 0x11                                 ; paragraphs to read
SecFades10:                                     ; 18-byte section record for FADES10.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades10                          ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x23                                 ; memory size, paragraphs
        dw 8                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x13                                 ; number printed in errors
        dw 0x23                                 ; paragraphs to read
SecFades11:                                     ; 18-byte section record for FADES11.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades11                          ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x38                                 ; memory size, paragraphs
        dw 7                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x14                                 ; number printed in errors
        dw 0x38                                 ; paragraphs to read
SecFades12:                                     ; 18-byte section record for FADES12.OVL; a record of
                                                ; SectionTable, reached by section number
        dw 0x3358                               ; load paragraph, relocated
        dw FileFades12                          ; file slot
        dw 0                                    ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 4                                    ; flags
        dw 0x1A                                 ; memory size, paragraphs
        dw 7                                    ; relocation entries
        dw 7                                    ; section to chain, or -1
        dw 0x15                                 ; number printed in errors
        dw 0x1A                                 ; paragraphs to read
SecHockey:                                      ; 18-byte section record for HOCKEY.EXE; a record of
                                                ; SectionTable, reached by section number
        dw 0x3415                               ; load paragraph, relocated
        dw FileHockey                           ; file slot
        dw 0x2005                               ; file position, paragraphs
        db 0                                    ; high byte of that position
        db 1                                    ; flags
        dw 0x216B                               ; memory size, paragraphs
        dw 0x484                                ; relocation entries
        dw 0xFFFF                               ; section to chain, or -1
        dw 0x16                                 ; number printed in errors
        dw 0x1AA2                               ; paragraphs to read
SectionEndMark:                                 ; used by ExeFileName

; Reload stack. The file slots begin immediately after it.
ReloadStack:                                    ; reload stack placed after the section table; InitOverlay
                                                ; points ReloadBase here (SectionEnd)
        times 0x6C2 db 0                        ; up to FileMenus

; One 128-byte slot per overlay file, then the EXE. The byte in front of
; the name is a flag: bit 0 means the name has been opened.
FileMenus:                                      ; file slot for MENUS.OVL; used by ExeFileName
        db 0, 'MENUS.OVL', 0
        times (FileSlotSize - ($ - FileMenus)) db 0
FileLp:                                         ; file slot for LP.OVL; used by ExeFileName
        db 0, 'LP.OVL', 0
        times (FileSlotSize - ($ - FileLp)) db 0
FileStats:                                      ; file slot for STATS.OVL; used by ExeFileName
        db 0, 'STATS.OVL', 0
        times (FileSlotSize - ($ - FileStats)) db 0
FileGame:                                       ; file slot for GAME.OVL; used by ExeFileName
        db 0, 'GAME.OVL', 0
        times (FileSlotSize - ($ - FileGame)) db 0
FileInit:                                       ; file slot for INIT.OVL; used by ExeFileName
        db 0, 'INIT.OVL', 0
        times (FileSlotSize - ($ - FileInit)) db 0
FileAi:                                         ; file slot for AI.OVL; used by ExeFileName
        db 0, 'AI.OVL', 0
        times (FileSlotSize - ($ - FileAi)) db 0
FileMovie:                                      ; file slot for MOVIE.OVL; used by ExeFileName
        db 0, 'MOVIE.OVL', 0
        times (FileSlotSize - ($ - FileMovie)) db 0
FileFades:                                      ; file slot for FADES.OVL; used by ExeFileName
        db 0, 'FADES.OVL', 0
        times (FileSlotSize - ($ - FileFades)) db 0
FileFades1:                                     ; file slot for FADES1.OVL; used by ExeFileName
        db 0, 'FADES1.OVL', 0
        times (FileSlotSize - ($ - FileFades1)) db 0
FileFades2:                                     ; file slot for FADES2.OVL; used by ExeFileName
        db 0, 'FADES2.OVL', 0
        times (FileSlotSize - ($ - FileFades2)) db 0
FileFades3:                                     ; file slot for FADES3.OVL; used by ExeFileName
        db 0, 'FADES3.OVL', 0
        times (FileSlotSize - ($ - FileFades3)) db 0
FileFades4:                                     ; file slot for FADES4.OVL; used by ExeFileName
        db 0, 'FADES4.OVL', 0
        times (FileSlotSize - ($ - FileFades4)) db 0
FileFades5:                                     ; file slot for FADES5.OVL; used by ExeFileName
        db 0, 'FADES5.OVL', 0
        times (FileSlotSize - ($ - FileFades5)) db 0
FileFades6:                                     ; file slot for FADES6.OVL; used by ExeFileName
        db 0, 'FADES6.OVL', 0
        times (FileSlotSize - ($ - FileFades6)) db 0
FileFades7:                                     ; file slot for FADES7.OVL; used by ExeFileName
        db 0, 'FADES7.OVL', 0
        times (FileSlotSize - ($ - FileFades7)) db 0
FileFades8:                                     ; file slot for FADES8.OVL; used by ExeFileName
        db 0, 'FADES8.OVL', 0
        times (FileSlotSize - ($ - FileFades8)) db 0
FileFades9:                                     ; file slot for FADES9.OVL; used by ExeFileName
        db 0, 'FADES9.OVL', 0
        times (FileSlotSize - ($ - FileFades9)) db 0
FileFades10:                                    ; file slot for FADES10.OVL; used by ExeFileName
        db 0, 'FADES10.OVL', 0
        times (FileSlotSize - ($ - FileFades10)) db 0
FileFades11:                                    ; file slot for FADES11.OVL; used by ExeFileName
        db 0, 'FADES11.OVL', 0
        times (FileSlotSize - ($ - FileFades11)) db 0
FileFades12:                                    ; file slot for FADES12.OVL; used by ExeFileName
        db 0, 'FADES12.OVL', 0
        times (FileSlotSize - ($ - FileFades12)) db 0
FileHockey:                                     ; file slot for HOCKEY.EXE; used by ExeFileName
        db 0, 'HOCKEY.EXE', 0
        times (FileSlotSize - ($ - FileHockey)) db 0

;-----------------------------------------------------------------------------
; OverlayThunks                                              1B35:1FEF  RTLink
; Overlay call thunks. A near call loads the section, the far jump goes
; to the routine once it is resident, and the word is the section index.
;-----------------------------------------------------------------------------
OverlayThunks:
StatsSelLeagueThunk:
        call LoadFromThunk
        jmp 0x2248:StatsSelLeague               ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StatsSelLeaguePlayoffsThunk                                1B35:1FF9  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsSelLeaguePlayoffs.
;-----------------------------------------------------------------------------
StatsSelLeaguePlayoffsThunk:
        call LoadFromThunk
        jmp 0x2248:StatsSelLeaguePlayoffs       ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StatsSelPlayoffModeThunk                                   1B35:2003  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsSelPlayoffMode.
;-----------------------------------------------------------------------------
StatsSelPlayoffModeThunk:
        call LoadFromThunk
        jmp 0x2248:StatsSelPlayoffMode          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CalNextMonthThunk                                          1B35:200D  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to CalNextMonth.
;-----------------------------------------------------------------------------
CalNextMonthThunk:
        call LoadFromThunk
        jmp 0x25B2:CalNextMonth                 ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; CalPrevMonthThunk                                          1B35:2017  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to CalPrevMonth.
;-----------------------------------------------------------------------------
CalPrevMonthThunk:
        call LoadFromThunk
        jmp 0x25B2:CalPrevMonth                 ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TradeShowStatsThunk                                        1B35:2021  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TradeShowStats.
;-----------------------------------------------------------------------------
TradeShowStatsThunk:
        call LoadFromThunk
        jmp 0x2A57:TradeShowStats               ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; GameDressPlayerThunk                                       1B35:202B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to GameDressPlayer.
;-----------------------------------------------------------------------------
GameDressPlayerThunk:
        call LoadFromThunk
        jmp 0x2047:GameDressPlayer              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskHomeLinesThunk                                         1B35:2035  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskHomeLines.
;-----------------------------------------------------------------------------
DeskHomeLinesThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskHomeLines                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; PlayoffModeLoopThunk                                       1B35:203F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to PlayoffModeLoop.
;-----------------------------------------------------------------------------
PlayoffModeLoopThunk:
        call LoadFromThunk
        jmp 0x26D4:PlayoffModeLoop              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuExportDbsThunk                                         1B35:2049  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuExportDbs.
;-----------------------------------------------------------------------------
MenuExportDbsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuExportDbs                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; EditPlayoffSettingsThunk                                   1B35:2053  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to EditPlayoffSettings.
;-----------------------------------------------------------------------------
EditPlayoffSettingsThunk:
        call LoadFromThunk
        jmp 0x2B26:EditPlayoffSettings          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuPlayoffHilightsThunk                                   1B35:205D  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuPlayoffHilights.
;-----------------------------------------------------------------------------
MenuPlayoffHilightsThunk:
        call LoadFromThunk
        jmp 0x26D4:MenuPlayoffHilights          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; POMenuResult4Thunk                                         1B35:2067  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to POMenuResult4.
;-----------------------------------------------------------------------------
POMenuResult4Thunk:
        call LoadFromThunk
        jmp 0x26D4:POMenuResult4                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuNextLeagueGameThunk                                    1B35:2071  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuNextLeagueGame.
;-----------------------------------------------------------------------------
MenuNextLeagueGameThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuNextLeagueGame           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; WriteTeamLinesThunk                                        1B35:207B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to WriteTeamLines.
;-----------------------------------------------------------------------------
WriteTeamLinesThunk:
        call LoadFromThunk
        jmp 0x2047:WriteTeamLines               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; GameScratchPlayerThunk                                     1B35:2085  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to GameScratchPlayer.
;-----------------------------------------------------------------------------
GameScratchPlayerThunk:
        call LoadFromThunk
        jmp 0x2047:GameScratchPlayer            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuUseTheseLinesThunk                                     1B35:208F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuUseTheseLines.
;-----------------------------------------------------------------------------
MenuUseTheseLinesThunk:
        call LoadFromThunk
        jmp 0x2047:MenuUseTheseLines            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskVisitorLinesThunk                                      1B35:2099  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskVisitorLines.
;-----------------------------------------------------------------------------
DeskVisitorLinesThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskVisitorLines             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; EvadePCThunk                                               1B35:20A3  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to EvadePC.
;-----------------------------------------------------------------------------
EvadePCThunk:
        call LoadFromThunk
        jmp 0x2425:EvadePC                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; avdgoal_boxThunk                                           1B35:20AD  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to avdgoal_box.
;-----------------------------------------------------------------------------
avdgoal_boxThunk:
        call LoadFromThunk
        jmp 0x2425:avdgoal_box                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asspuckc_chkdirThunk                                       1B35:20B7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asspuckc_chkdir.
;-----------------------------------------------------------------------------
asspuckc_chkdirThunk:
        call LoadFromThunk
        jmp 0x2519:asspuckc_chkdir              ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; EvadePlayersThunk                                          1B35:20C1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to EvadePlayers.
;-----------------------------------------------------------------------------
EvadePlayersThunk:
        call LoadFromThunk
        jmp 0x2425:EvadePlayers                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; MainDeskLoopThunk                                          1B35:20CB  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MainDeskLoop.
;-----------------------------------------------------------------------------
MainDeskLoopThunk:
        call LoadFromThunk
        jmp 0x2E70:MainDeskLoop                 ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; FadePaletteInThunk                                         1B35:20D5  RTLink
; Overlay thunk: loads FADES4.OVL (LoadFromThunk), then far-jumps to FadePaletteIn.
;-----------------------------------------------------------------------------
FadePaletteInThunk:
        call LoadFromThunk
        jmp 0x3358:FadePaletteIn                ; load paragraph, relocated
        dw 11                                   ; FADES4.OVL
;-----------------------------------------------------------------------------
; TitleScreenThunk                                           1B35:20DF  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to TitleScreen.
;-----------------------------------------------------------------------------
TitleScreenThunk:
        call LoadFromThunk
        jmp 0x1F9D:TitleScreen                  ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; ReloadSoundConfigThunk                                     1B35:20E9  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to ReloadSoundConfig.
;-----------------------------------------------------------------------------
ReloadSoundConfigThunk:
        call LoadFromThunk
        jmp 0x22D3:ReloadSoundConfig            ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; LoadModeStateThunk                                         1B35:20F3  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to LoadModeState.
;-----------------------------------------------------------------------------
LoadModeStateThunk:
        call LoadFromThunk
        jmp 0x2E70:LoadModeState                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; GoodnightScreenThunk                                       1B35:20FD  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to GoodnightScreen.
;-----------------------------------------------------------------------------
GoodnightScreenThunk:
        call LoadFromThunk
        jmp 0x1F9D:GoodnightScreen              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuExitThunk                                              1B35:2107  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuExit.
;-----------------------------------------------------------------------------
MenuExitThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuExit                     ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; CreatePlayoffsThunk                                        1B35:2111  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to CreatePlayoffs.
;-----------------------------------------------------------------------------
CreatePlayoffsThunk:
        call LoadFromThunk
        jmp 0x26D4:CreatePlayoffs               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuImportDbsThunk                                         1B35:211B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuImportDbs.
;-----------------------------------------------------------------------------
MenuImportDbsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuImportDbs                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuNewLeagueThunk                                         1B35:2125  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuNewLeague.
;-----------------------------------------------------------------------------
MenuNewLeagueThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuNewLeague                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuNewExhibitionThunk                                     1B35:212F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuNewExhibition.
;-----------------------------------------------------------------------------
MenuNewExhibitionThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuNewExhibition            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuOpenSavedThunk                                         1B35:2139  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuOpenSaved.
;-----------------------------------------------------------------------------
MenuOpenSavedThunk:
        call LoadFromThunk
        jmp 0x23A3:MenuOpenSaved                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuUpdateTeamDbsThunk                                     1B35:2143  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuUpdateTeamDbs.
;-----------------------------------------------------------------------------
MenuUpdateTeamDbsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuUpdateTeamDbs            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuLeagueHilightsThunk                                    1B35:214D  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuLeagueHilights.
;-----------------------------------------------------------------------------
MenuLeagueHilightsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuLeagueHilights           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuLeagueSettingsThunk                                    1B35:2157  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuLeagueSettings.
;-----------------------------------------------------------------------------
MenuLeagueSettingsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuLeagueSettings           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuMergeUpdateDbsThunk                                    1B35:2161  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuMergeUpdateDbs.
;-----------------------------------------------------------------------------
MenuMergeUpdateDbsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuMergeUpdateDbs           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuRebuildDbsThunk                                        1B35:216B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuRebuildDbs.
;-----------------------------------------------------------------------------
MenuRebuildDbsThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuRebuildDbs               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuTradePlayersThunk                                      1B35:2175  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuTradePlayers.
;-----------------------------------------------------------------------------
MenuTradePlayersThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuTradePlayers             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuAddTeamThunk                                           1B35:217F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuAddTeam.
;-----------------------------------------------------------------------------
MenuAddTeamThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuAddTeam                  ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuRemoveTeamThunk                                        1B35:2189  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuRemoveTeam.
;-----------------------------------------------------------------------------
MenuRemoveTeamThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuRemoveTeam               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuMergeLeagueFilesThunk                                  1B35:2193  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuMergeLeagueFiles.
;-----------------------------------------------------------------------------
MenuMergeLeagueFilesThunk:
        call LoadFromThunk
        jmp 0x2E70:MenuMergeLeagueFiles         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; EasnStandingsMenuThunk                                     1B35:219D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to EasnStandingsMenu.
;-----------------------------------------------------------------------------
EasnStandingsMenuThunk:
        call LoadFromThunk
        jmp 0x22B3:EasnStandingsMenu            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuSoundSettingsThunk                                     1B35:21A7  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuSoundSettings.
;-----------------------------------------------------------------------------
MenuSoundSettingsThunk:
        call LoadFromThunk
        jmp 0x2528:MenuSoundSettings            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP2ControlsExhThunk                                     1B35:21B1  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP2ControlsExh.
;-----------------------------------------------------------------------------
MenuP2ControlsExhThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP2ControlsExh            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP1ControlsExhThunk                                     1B35:21BB  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP1ControlsExh.
;-----------------------------------------------------------------------------
MenuP1ControlsExhThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP1ControlsExh            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuExhibitionSettingsThunk                                1B35:21C5  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuExhibitionSettings.
;-----------------------------------------------------------------------------
MenuExhibitionSettingsThunk:
        call LoadFromThunk
        jmp 0x2CAA:MenuExhibitionSettings       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; LockerRoomScreenThunk                                      1B35:21CF  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to LockerRoomScreen.
;-----------------------------------------------------------------------------
LockerRoomScreenThunk:
        call LoadFromThunk
        jmp 0x25DD:LockerRoomScreen             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuSavePctLeadersThunk                                    1B35:21D9  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuSavePct.
;-----------------------------------------------------------------------------
MenuSavePctLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuSavePct           ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuWinsLeadersThunk                                       1B35:21E3  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuGoalieWins.
;-----------------------------------------------------------------------------
MenuWinsLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuGoalieWins              ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuGAALeadersThunk                                        1B35:21ED  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuGAA.
;-----------------------------------------------------------------------------
MenuGAALeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuGAA               ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuShootPctLeadersThunk                                   1B35:21F7  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuShootPct.
;-----------------------------------------------------------------------------
MenuShootPctLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuShootPct          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuPIMLeadersThunk                                        1B35:2201  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPIM.
;-----------------------------------------------------------------------------
MenuPIMLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPIM               ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuPlusMinusLeadersThunk                                  1B35:220B  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPlusMinus.
;-----------------------------------------------------------------------------
MenuPlusMinusLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPlusMinus         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuSHGoalLeadersThunk                                     1B35:2215  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuSHGoals.
;-----------------------------------------------------------------------------
MenuSHGoalLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuSHGoals            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuPPGoalLeadersThunk                                     1B35:221F  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPPGoals.
;-----------------------------------------------------------------------------
MenuPPGoalLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPPGoals            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuAssistLeadersThunk                                     1B35:2229  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuAssists.
;-----------------------------------------------------------------------------
MenuAssistLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuAssists            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuGoalLeadersThunk                                       1B35:2233  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuGoals.
;-----------------------------------------------------------------------------
MenuGoalLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuGoals              ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuPointLeadersThunk                                      1B35:223D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPoints.
;-----------------------------------------------------------------------------
MenuPointLeadersThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPoints             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuTeamPenaltiesThunk                                     1B35:2247  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuTeamPenalties.
;-----------------------------------------------------------------------------
MenuTeamPenaltiesThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuTeamPenalties            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuTeamPKThunk                                            1B35:2251  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPenaltyKilling.
;-----------------------------------------------------------------------------
MenuTeamPKThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPenaltyKilling                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuTeamPPThunk                                            1B35:225B  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuPowerPlay.
;-----------------------------------------------------------------------------
MenuTeamPPThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuPowerPlay                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuTeamDefenseThunk                                       1B35:2265  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuTeamDefense.
;-----------------------------------------------------------------------------
MenuTeamDefenseThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuTeamDefense              ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuTeamScoringThunk                                       1B35:226F  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuTeamScoring.
;-----------------------------------------------------------------------------
MenuTeamScoringThunk:
        call LoadFromThunk
        jmp 0x2248:StatsMenuTeamScoring              ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; DeskExitGameThunk                                          1B35:2279  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskExitGame.
;-----------------------------------------------------------------------------
DeskExitGameThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskExitGame                 ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskReturnConfirmThunk                                     1B35:2283  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskReturnConfirm.
;-----------------------------------------------------------------------------
DeskReturnConfirmThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskReturnConfirm            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskBackToGameThunk                                        1B35:228D  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskBackToGame.
;-----------------------------------------------------------------------------
DeskBackToGameThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskBackToGame               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskToSportsDeskThunk                                      1B35:2297  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskToSportsDesk.
;-----------------------------------------------------------------------------
DeskToSportsDeskThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskToSportsDesk             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuModeSettingsThunk                                      1B35:22A1  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuModeSettings.
;-----------------------------------------------------------------------------
MenuModeSettingsThunk:
        call LoadFromThunk
        jmp 0x2C1E:MenuModeSettings             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP2ControlsInGameThunk                                  1B35:22AB  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP2ControlsInGame.
;-----------------------------------------------------------------------------
MenuP2ControlsInGameThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP2ControlsInGame         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP1ControlsInGameThunk                                  1B35:22B5  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP1ControlsInGame.
;-----------------------------------------------------------------------------
MenuP1ControlsInGameThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP1ControlsInGame         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskAwayGoalieNoneThunk                                    1B35:22BF  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskAwayGoalieNone.
;-----------------------------------------------------------------------------
DeskAwayGoalieNoneThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskAwayGoalieNone           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskAwayGoalie2Thunk                                       1B35:22C9  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskAwayGoalie2.
;-----------------------------------------------------------------------------
DeskAwayGoalie2Thunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskAwayGoalie2              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskAwayGoalie1Thunk                                       1B35:22D3  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskAwayGoalie1.
;-----------------------------------------------------------------------------
DeskAwayGoalie1Thunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskAwayGoalie1              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskHomeGoalieNoneThunk                                    1B35:22DD  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskHomeGoalieNone.
;-----------------------------------------------------------------------------
DeskHomeGoalieNoneThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskHomeGoalieNone           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskHomeGoalie2Thunk                                       1B35:22E7  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskHomeGoalie2.
;-----------------------------------------------------------------------------
DeskHomeGoalie2Thunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskHomeGoalie2              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskHomeGoalie1Thunk                                       1B35:22F1  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskHomeGoalie1.
;-----------------------------------------------------------------------------
DeskHomeGoalie1Thunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskHomeGoalie1              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskGoToReplayThunk                                        1B35:22FB  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskGoToReplay.
;-----------------------------------------------------------------------------
DeskGoToReplayThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskGoToReplay               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskTeamScratchesThunk                                     1B35:2305  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskTeamScratches.
;-----------------------------------------------------------------------------
DeskTeamScratchesThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskTeamScratches            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskScoringSummaryThunk                                    1B35:230F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskScoringSummary.
;-----------------------------------------------------------------------------
DeskScoringSummaryThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskScoringSummary           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskPenaltySummaryThunk                                    1B35:2319  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskPenaltySummary.
;-----------------------------------------------------------------------------
DeskPenaltySummaryThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskPenaltySummary           ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; DeskGameStatsThunk                                         1B35:2323  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DeskGameStats.
;-----------------------------------------------------------------------------
DeskGameStatsThunk:
        call LoadFromThunk
        jmp 0x2CF8:DeskGameStats                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; GameStandingsMenuThunk                                     1B35:232D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to GameStandingsMenu.
;-----------------------------------------------------------------------------
GameStandingsMenuThunk:
        call LoadFromThunk
        jmp 0x215A:GameStandingsMenu            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuGameShowPlayerStatsThunk                               1B35:2337  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuGameShowPlayerStats.
;-----------------------------------------------------------------------------
MenuGameShowPlayerStatsThunk:
        call LoadFromThunk
        jmp 0x2047:MenuGameShowPlayerStats      ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuUseDefaultLinesThunk                                   1B35:2341  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuUseDefaultLines.
;-----------------------------------------------------------------------------
MenuUseDefaultLinesThunk:
        call LoadFromThunk
        jmp 0x2047:MenuUseDefaultLines          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuUseOriginalLinesThunk                                  1B35:234B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuUseOriginalLines.
;-----------------------------------------------------------------------------
MenuUseOriginalLinesThunk:
        call LoadFromThunk
        jmp 0x2047:MenuUseOriginalLines         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuLineEdCancelThunk                                      1B35:2355  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuLineEdCancel.
;-----------------------------------------------------------------------------
MenuLineEdCancelThunk:
        call LoadFromThunk
        jmp 0x2047:MenuLineEdCancel             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; WriteTeamLines2Thunk                                       1B35:235F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to WriteTeamLines2.
;-----------------------------------------------------------------------------
WriteTeamLines2Thunk:
        call LoadFromThunk
        jmp 0x2047:WriteTeamLines2              ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuReturnToLineEditorThunk                                1B35:2369  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuReturnToLineEditor.
;-----------------------------------------------------------------------------
MenuReturnToLineEditorThunk:
        call LoadFromThunk
        jmp 0x2047:MenuReturnToLineEditor       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; StandingsActExitThunk                                      1B35:2373  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StandingsActExit.
;-----------------------------------------------------------------------------
StandingsActExitThunk:
        call LoadFromThunk
        jmp 0x2248:StandingsActExit             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StandingsActStandingsThunk                                 1B35:237D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StandingsActStandings.
;-----------------------------------------------------------------------------
StandingsActStandingsThunk:
        call LoadFromThunk
        jmp 0x2248:StandingsActStandings        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StandingsActRosterThunk                                    1B35:2387  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StandingsActRoster.
;-----------------------------------------------------------------------------
StandingsActRosterThunk:
        call LoadFromThunk
        jmp 0x2248:StandingsActRoster           ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StandingsActRoster2Thunk                                   1B35:2391  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StandingsActRoster2.
;-----------------------------------------------------------------------------
StandingsActRoster2Thunk:
        call LoadFromThunk
        jmp 0x2248:StandingsActRoster2          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StandingsActPlayerThunk                                    1B35:239B  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StandingsActPlayer.
;-----------------------------------------------------------------------------
StandingsActPlayerThunk:
        call LoadFromThunk
        jmp 0x2248:StandingsActPlayer           ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; MenuLeagueSettingsEditThunk                                1B35:23A5  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuLeagueSettingsEdit.
;-----------------------------------------------------------------------------
MenuLeagueSettingsEditThunk:
        call LoadFromThunk
        jmp 0x2B26:MenuLeagueSettingsEdit       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP2ControlsPlayoffThunk                                 1B35:23AF  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP2ControlsPlayoff.
;-----------------------------------------------------------------------------
MenuP2ControlsPlayoffThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP2ControlsPlayoff        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuP1ControlsPlayoffThunk                                 1B35:23B9  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuP1ControlsPlayoff.
;-----------------------------------------------------------------------------
MenuP1ControlsPlayoffThunk:
        call LoadFromThunk
        jmp 0x1E45:MenuP1ControlsPlayoff        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; POMenuResult1Thunk                                         1B35:23C3  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to POMenuResult1.
;-----------------------------------------------------------------------------
POMenuResult1Thunk:
        call LoadFromThunk
        jmp 0x26D4:POMenuResult1                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SaveGameStateThunk                                         1B35:23CD  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to SaveGameState.
;-----------------------------------------------------------------------------
SaveGameStateThunk:
        call LoadFromThunk
        jmp 0x278C:SaveGameState                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; WriteModeStateThunk                                        1B35:23D7  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to WriteModeState.
;-----------------------------------------------------------------------------
WriteModeStateThunk:
        call LoadFromThunk
        jmp 0x2E70:WriteModeState               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SaveLeagueGameRefThunk                                     1B35:23E1  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to SaveLeagueGameRef.
;-----------------------------------------------------------------------------
SaveLeagueGameRefThunk:
        call LoadFromThunk
        jmp 0x2E18:SaveLeagueGameRef            ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; EditTextFieldThunk                                         1B35:23EB  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to EditTextField.
;-----------------------------------------------------------------------------
EditTextFieldThunk:
        call LoadFromThunk
        jmp 0x1E45:EditTextField                ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; SetCtlTeamsThunk                                           1B35:23F5  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to SetCtlTeams.
;-----------------------------------------------------------------------------
SetCtlTeamsThunk:
        call LoadFromThunk
        jmp 0x1E45:SetCtlTeams                  ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; restoreplThunk                                             1B35:23FF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to restorepl.
;-----------------------------------------------------------------------------
restoreplThunk:
        call LoadFromThunk
        jmp 0x2E42:restorepl                    ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; setpersonelThunk                                           1B35:2409  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to setpersonel.
;-----------------------------------------------------------------------------
setpersonelThunk:
        call LoadFromThunk
        jmp 0x2E42:setpersonel                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; PlayHilightThunk                                           1B35:2413  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to PlayHilight.
;-----------------------------------------------------------------------------
PlayHilightThunk:
        call LoadFromThunk
        jmp 0x2062:PlayHilight                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; MviOpenThunk                                               1B35:241D  RTLink
; Overlay thunk: loads MOVIE.OVL (LoadFromThunk), then far-jumps to MviOpen.
;-----------------------------------------------------------------------------
MviOpenThunk:
        call LoadFromThunk
        jmp 0x3357:MviOpen                      ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; MviCloseThunk                                              1B35:2427  RTLink
; Overlay thunk: loads MOVIE.OVL (LoadFromThunk), then far-jumps to MviClose.
;-----------------------------------------------------------------------------
MviCloseThunk:
        call LoadFromThunk
        jmp 0x3357:MviClose                     ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; PlanarToLinearThunk                                        1B35:2431  RTLink
; Overlay thunk: loads MOVIE.OVL (LoadFromThunk), then far-jumps to PlanarToLinear.
;-----------------------------------------------------------------------------
PlanarToLinearThunk:
        call LoadFromThunk
        jmp 0x3349:PlanarToLinear               ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; MviNextFrameThunk                                          1B35:243B  RTLink
; Overlay thunk: loads MOVIE.OVL (LoadFromThunk), then far-jumps to MviNextFrame.
;-----------------------------------------------------------------------------
MviNextFrameThunk:
        call LoadFromThunk
        jmp 0x3357:MviNextFrame                 ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; DrawDlgFrameThunk                                          1B35:2445  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DrawDlgFrame.
;-----------------------------------------------------------------------------
DrawDlgFrameThunk:
        call LoadFromThunk
        jmp 0x2047:DrawDlgFrame                 ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; GameLineEditorThunk                                        1B35:244F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to GameLineEditor.
;-----------------------------------------------------------------------------
GameLineEditorThunk:
        call LoadFromThunk
        jmp 0x2047:GameLineEditor               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; RosterScreenThunk                                          1B35:2459  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to RosterScreen.
;-----------------------------------------------------------------------------
RosterScreenThunk:
        call LoadFromThunk
        jmp 0x2446:RosterScreen                 ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; InitMenuRemapThunk                                         1B35:2463  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to InitMenuRemap.
;-----------------------------------------------------------------------------
InitMenuRemapThunk:
        call LoadFromThunk
        jmp 0x2095:InitMenuRemap                ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StatsMenuLoopThunk                                         1B35:246D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsMenuLoop.
;-----------------------------------------------------------------------------
StatsMenuLoopThunk:
        call LoadFromThunk
        jmp 0x1EAE:StatsMenuLoop                ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; SetupStatsMenusThunk                                       1B35:2477  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to SetupStatsMenus.
;-----------------------------------------------------------------------------
SetupStatsMenusThunk:
        call LoadFromThunk
        jmp 0x1E45:SetupStatsMenus              ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; BuildSeasonTitleThunk                                      1B35:2481  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to BuildSeasonTitle.
;-----------------------------------------------------------------------------
BuildSeasonTitleThunk:
        call LoadFromThunk
        jmp 0x1E45:BuildSeasonTitle             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; LoadScheduleDBThunk                                        1B35:248B  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to LoadScheduleDB.
;-----------------------------------------------------------------------------
LoadScheduleDBThunk:
        call LoadFromThunk
        jmp 0x26D4:LoadScheduleDB               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SetSoundDeviceThunk                                        1B35:2495  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to SetSoundDevice.
;-----------------------------------------------------------------------------
SetSoundDeviceThunk:
        call LoadFromThunk
        jmp 0x2528:SetSoundDevice               ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SaveModeStateThunk                                         1B35:249F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to SaveModeState.
;-----------------------------------------------------------------------------
SaveModeStateThunk:
        call LoadFromThunk
        jmp 0x2E70:SaveModeState                ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SimulateGameThunk                                          1B35:24A9  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to SimulateGame.
;-----------------------------------------------------------------------------
SimulateGameThunk:
        call LoadFromThunk
        jmp 0x23AD:SimulateGame                 ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; PostGameToTeamDbThunk                                      1B35:24B3  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to PostGameToTeamDb.
;-----------------------------------------------------------------------------
PostGameToTeamDbThunk:
        call LoadFromThunk
        jmp 0x25B2:PostGameToTeamDb             ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; EasnStandingsScreenThunk                                   1B35:24BD  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to EasnStandingsScreen.
;-----------------------------------------------------------------------------
EasnStandingsScreenThunk:
        call LoadFromThunk
        jmp 0x22B3:EasnStandingsScreen          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; EasnGoalieStatsScreenThunk                                 1B35:24C7  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to EasnGoalieStatsScreen.
;-----------------------------------------------------------------------------
EasnGoalieStatsScreenThunk:
        call LoadFromThunk
        jmp 0x22B3:EasnGoalieStatsScreen        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; EasnSkaterStatsScreenThunk                                 1B35:24D1  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to EasnSkaterStatsScreen.
;-----------------------------------------------------------------------------
EasnSkaterStatsScreenThunk:
        call LoadFromThunk
        jmp 0x22B3:EasnSkaterStatsScreen        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; EasnTeamStatsScreenThunk                                   1B35:24DB  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to EasnTeamStatsScreen.
;-----------------------------------------------------------------------------
EasnTeamStatsScreenThunk:
        call LoadFromThunk
        jmp 0x22B3:EasnTeamStatsScreen          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; PlayGameThunk                                              1B35:24E5  RTLink
; Overlay thunk: loads GAME.OVL (LoadFromThunk), then far-jumps to PlayGame.
;-----------------------------------------------------------------------------
PlayGameThunk:
        call LoadFromThunk
        jmp 0x1E7E:PlayGame                     ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; GameStandingsScreenThunk                                   1B35:24EF  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to GameStandingsScreen.
;-----------------------------------------------------------------------------
GameStandingsScreenThunk:
        call LoadFromThunk
        jmp 0x215A:GameStandingsScreen          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; GameGoalieStatsScreenThunk                                 1B35:24F9  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to GameGoalieStatsScreen.
;-----------------------------------------------------------------------------
GameGoalieStatsScreenThunk:
        call LoadFromThunk
        jmp 0x215A:GameGoalieStatsScreen        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; GameSkaterStatsScreenThunk                                 1B35:2503  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to GameSkaterStatsScreen.
;-----------------------------------------------------------------------------
GameSkaterStatsScreenThunk:
        call LoadFromThunk
        jmp 0x215A:GameSkaterStatsScreen        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; GameTeamStatsScreenThunk                                   1B35:250D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to GameTeamStatsScreen.
;-----------------------------------------------------------------------------
GameTeamStatsScreenThunk:
        call LoadFromThunk
        jmp 0x215A:GameTeamStatsScreen          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; SetupControllersThunk                                      1B35:2517  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to SetupControllers.
;-----------------------------------------------------------------------------
SetupControllersThunk:
        call LoadFromThunk
        jmp 0x1F9C:SetupControllers             ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; SetStatsMenuTextThunk                                      1B35:2521  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to SetStatsMenuText.
;-----------------------------------------------------------------------------
SetStatsMenuTextThunk:
        call LoadFromThunk
        jmp 0x1E45:SetStatsMenuText             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; ShowMatchupScreenThunk                                     1B35:252B  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ShowMatchupScreen.
;-----------------------------------------------------------------------------
ShowMatchupScreenThunk:
        call LoadFromThunk
        jmp 0x2007:ShowMatchupScreen            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; CreateGSummaryDbThunk                                      1B35:2535  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to CreateGSummaryDb.
;-----------------------------------------------------------------------------
CreateGSummaryDbThunk:
        call LoadFromThunk
        jmp 0x2425:CreateGSummaryDb             ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; DrawLeagueSetDlgSelThunk                                   1B35:253F  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to DrawLeagueSetDlgSel.
;-----------------------------------------------------------------------------
DrawLeagueSetDlgSelThunk:
        call LoadFromThunk
        jmp 0x2B26:DrawLeagueSetDlgSel          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuShowLeagueSettingsThunk                                1B35:2549  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuShowLeagueSettings.
;-----------------------------------------------------------------------------
MenuShowLeagueSettingsThunk:
        call LoadFromThunk
        jmp 0x2B26:MenuShowLeagueSettings       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; MenuShowLeagueSettings2Thunk                               1B35:2553  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to MenuShowLeagueSettings2.
;-----------------------------------------------------------------------------
MenuShowLeagueSettings2Thunk:
        call LoadFromThunk
        jmp 0x2B26:MenuShowLeagueSettings2      ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; SportsDeskThunk                                            1B35:255D  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to SportsDesk.
;-----------------------------------------------------------------------------
SportsDeskThunk:
        call LoadFromThunk
        jmp 0x2CF8:SportsDesk                   ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; FreePPVFilesThunk                                          1B35:2567  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to FreePPVFiles.
;-----------------------------------------------------------------------------
FreePPVFilesThunk:
        call LoadFromThunk
        jmp 0x256C:FreePPVFiles                 ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; ReplayIsEmptyThunk                                         1B35:2571  RTLink
; Overlay thunk: loads GAME.OVL (LoadFromThunk), then far-jumps to ReplayIsEmpty.
;-----------------------------------------------------------------------------
ReplayIsEmptyThunk:
        call LoadFromThunk
        jmp 0x1E7E:ReplayIsEmpty                ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; LoadScoreboardArtThunk                                     1B35:257B  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadScoreboardArt.
;-----------------------------------------------------------------------------
LoadScoreboardArtThunk:
        call LoadFromThunk
        jmp 0x251E:LoadScoreboardArt            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; LoadRinkEndArtThunk                                        1B35:2585  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadRinkEndArt.
;-----------------------------------------------------------------------------
LoadRinkEndArtThunk:
        call LoadFromThunk
        jmp 0x1F9C:LoadRinkEndArt               ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; LoadPPVFilesThunk                                          1B35:258F  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadPPVFiles.
;-----------------------------------------------------------------------------
LoadPPVFilesThunk:
        call LoadFromThunk
        jmp 0x1F9C:LoadPPVFiles                 ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; InstantReplayThunk                                         1B35:2599  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to InstantReplay.
;-----------------------------------------------------------------------------
InstantReplayThunk:
        call LoadFromThunk
        jmp 0x2581:InstantReplay                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; ShowGameSummaryThunk                                       1B35:25A3  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ShowGameSummary.
;-----------------------------------------------------------------------------
ShowGameSummaryThunk:
        call LoadFromThunk
        jmp 0x21A1:ShowGameSummary              ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; ShowTeamStatsThunk                                         1B35:25AD  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ShowTeamStats.
;-----------------------------------------------------------------------------
ShowTeamStatsThunk:
        call LoadFromThunk
        jmp 0x2306:ShowTeamStats                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; SetTeamGoalieThunk                                         1B35:25B7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to SetTeamGoalie.
;-----------------------------------------------------------------------------
SetTeamGoalieThunk:
        call LoadFromThunk
        jmp 0x226F:SetTeamGoalie                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; CopyGameSettingsThunk                                      1B35:25C1  RTLink
; Overlay thunk: loads MENUS.OVL (LoadFromThunk), then far-jumps to CopyGameSettings.
;-----------------------------------------------------------------------------
CopyGameSettingsThunk:
        call LoadFromThunk
        jmp 0x2E70:CopyGameSettings             ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; AddHumanTeamThunk                                          1B35:25CB  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to AddHumanTeam.
;-----------------------------------------------------------------------------
AddHumanTeamThunk:
        call LoadFromThunk
        jmp 0x1ECB:AddHumanTeam                 ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; CreateNewLeagueThunk                                       1B35:25D5  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to CreateNewLeague.
;-----------------------------------------------------------------------------
CreateNewLeagueThunk:
        call LoadFromThunk
        jmp 0x2A1B:CreateNewLeague              ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; MergeUpdateDbsThunk                                        1B35:25DF  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to MergeUpdateDbs.
;-----------------------------------------------------------------------------
MergeUpdateDbsThunk:
        call LoadFromThunk
        jmp 0x2CB7:MergeUpdateDbs               ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; RebuildLeagueDbsThunk                                      1B35:25E9  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to RebuildLeagueDbs.
;-----------------------------------------------------------------------------
RebuildLeagueDbsThunk:
        call LoadFromThunk
        jmp 0x2CB7:RebuildLeagueDbs             ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; CheckMasterPasswordThunk                                   1B35:25F3  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to CheckMasterPassword.
;-----------------------------------------------------------------------------
CheckMasterPasswordThunk:
        call LoadFromThunk
        jmp 0x2305:CheckMasterPassword          ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; RemoveHumanTeamThunk                                       1B35:25FD  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to RemoveHumanTeam.
;-----------------------------------------------------------------------------
RemoveHumanTeamThunk:
        call LoadFromThunk
        jmp 0x1ECB:RemoveHumanTeam              ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TradePlayersThunk                                          1B35:2607  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TradePlayers.
;-----------------------------------------------------------------------------
TradePlayersThunk:
        call LoadFromThunk
        jmp 0x2A57:TradePlayers                 ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; UpdateTeamDbsThunk                                         1B35:2611  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to UpdateTeamDbs.
;-----------------------------------------------------------------------------
UpdateTeamDbsThunk:
        call LoadFromThunk
        jmp 0x2CB7:UpdateTeamDbs                ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; MergeLeagueFilesThunk                                      1B35:261B  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to MergeLeagueFiles.
;-----------------------------------------------------------------------------
MergeLeagueFilesThunk:
        call LoadFromThunk
        jmp 0x2CB7:MergeLeagueFiles             ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; ImportDbsThunk                                             1B35:2625  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to ImportDbs.
;-----------------------------------------------------------------------------
ImportDbsThunk:
        call LoadFromThunk
        jmp 0x2139:ImportDbs                    ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; PlayLeagueGameThunk                                        1B35:262F  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to PlayLeagueGame.
;-----------------------------------------------------------------------------
PlayLeagueGameThunk:
        call LoadFromThunk
        jmp 0x25B2:PlayLeagueGame               ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; ExportDbsThunk                                             1B35:2639  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to ExportDbs.
;-----------------------------------------------------------------------------
ExportDbsThunk:
        call LoadFromThunk
        jmp 0x2139:ExportDbs                    ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; ReadTeamNamesThunk                                         1B35:2643  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to ReadTeamNames.
;-----------------------------------------------------------------------------
ReadTeamNamesThunk:
        call LoadFromThunk
        jmp 0x22D3:ReadTeamNames                ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TradeCancelThunk                                           1B35:264D  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TradeCancel.
;-----------------------------------------------------------------------------
TradeCancelThunk:
        call LoadFromThunk
        jmp 0x2A57:TradeCancel                  ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TradeDoneThunk                                             1B35:2657  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TradeDone.
;-----------------------------------------------------------------------------
TradeDoneThunk:
        call LoadFromThunk
        jmp 0x2A57:TradeDone                    ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TeamSelCancelThunk                                         1B35:2661  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TeamSelCancel.
;-----------------------------------------------------------------------------
TeamSelCancelThunk:
        call LoadFromThunk
        jmp 0x1F31:TeamSelCancel                ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; TeamSelDoneThunk                                           1B35:266B  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to TeamSelDone.
;-----------------------------------------------------------------------------
TeamSelDoneThunk:
        call LoadFromThunk
        jmp 0x1F31:TeamSelDone                  ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; CalReturnThunk                                             1B35:2675  RTLink
; Overlay thunk: loads LP.OVL (LoadFromThunk), then far-jumps to CalReturn.
;-----------------------------------------------------------------------------
CalReturnThunk:
        call LoadFromThunk
        jmp 0x25B2:CalReturn                    ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; CalStandingsMenuThunk                                      1B35:267F  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CalStandingsMenu.
;-----------------------------------------------------------------------------
CalStandingsMenuThunk:
        call LoadFromThunk
        jmp 0x2351:CalStandingsMenu             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CalStandingsScreenThunk                                    1B35:2689  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CalStandingsScreen.
;-----------------------------------------------------------------------------
CalStandingsScreenThunk:
        call LoadFromThunk
        jmp 0x2351:CalStandingsScreen           ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CalGoalieStatsScreenThunk                                  1B35:2693  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CalGoalieStatsScreen.
;-----------------------------------------------------------------------------
CalGoalieStatsScreenThunk:
        call LoadFromThunk
        jmp 0x2351:CalGoalieStatsScreen         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CalSkaterStatsScreenThunk                                  1B35:269D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CalSkaterStatsScreen.
;-----------------------------------------------------------------------------
CalSkaterStatsScreenThunk:
        call LoadFromThunk
        jmp 0x2351:CalSkaterStatsScreen         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CalTeamStatsScreenThunk                                    1B35:26A7  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CalTeamStatsScreen.
;-----------------------------------------------------------------------------
CalTeamStatsScreenThunk:
        call LoadFromThunk
        jmp 0x2351:CalTeamStatsScreen           ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; LoadGameTeamsThunk                                         1B35:26B1  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadGameTeams.
;-----------------------------------------------------------------------------
LoadGameTeamsThunk:
        call LoadFromThunk
        jmp 0x2425:LoadGameTeams                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; FadeZoomRectThunk                                          1B35:26BB  RTLink
; Overlay thunk: loads FADES12.OVL (LoadFromThunk), then far-jumps to FadeZoomRect.
;-----------------------------------------------------------------------------
FadeZoomRectThunk:
        call LoadFromThunk
        jmp 0x3358:FadeZoomRect                 ; load paragraph, relocated
        dw 19                                   ; FADES12.OVL
;-----------------------------------------------------------------------------
; StatsSelNhlPlayoffsThunk                                   1B35:26C5  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsSelNhlPlayoffs.
;-----------------------------------------------------------------------------
StatsSelNhlPlayoffsThunk:
        call LoadFromThunk
        jmp 0x2248:StatsSelNhlPlayoffs          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; StatsSelNhlSeasonThunk                                     1B35:26CF  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to StatsSelNhlSeason.
;-----------------------------------------------------------------------------
StatsSelNhlSeasonThunk:
        call LoadFromThunk
        jmp 0x2248:StatsSelNhlSeason            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpPointsThunk                                             1B35:26D9  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpPoints.
;-----------------------------------------------------------------------------
CmpPointsThunk:
        call LoadFromThunk
        jmp 0x2095:CmpPoints                    ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpGAAThunk                                                1B35:26E3  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpGAA.
;-----------------------------------------------------------------------------
CmpGAAThunk:
        call LoadFromThunk
        jmp 0x2095:CmpGAA                       ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpTeamScoringThunk                                        1B35:26ED  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpTeamScoring.
;-----------------------------------------------------------------------------
CmpTeamScoringThunk:
        call LoadFromThunk
        jmp 0x25E5:CmpTeamScoring               ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpTeamDefenseThunk                                        1B35:26F7  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpTeamDefense.
;-----------------------------------------------------------------------------
CmpTeamDefenseThunk:
        call LoadFromThunk
        jmp 0x25E5:CmpTeamDefense               ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpTeamPKThunk                                             1B35:2701  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpTeamPK.
;-----------------------------------------------------------------------------
CmpTeamPKThunk:
        call LoadFromThunk
        jmp 0x25E5:CmpTeamPK                    ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpTeamPPThunk                                             1B35:270B  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpTeamPP.
;-----------------------------------------------------------------------------
CmpTeamPPThunk:
        call LoadFromThunk
        jmp 0x25E5:CmpTeamPP                    ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpTeamPenaltiesThunk                                      1B35:2715  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpTeamPenalties.
;-----------------------------------------------------------------------------
CmpTeamPenaltiesThunk:
        call LoadFromThunk
        jmp 0x25E5:CmpTeamPenalties             ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpGoalsThunk                                              1B35:271F  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpGoals.
;-----------------------------------------------------------------------------
CmpGoalsThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpGoals                     ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpAssistsThunk                                            1B35:2729  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpAssists.
;-----------------------------------------------------------------------------
CmpAssistsThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpAssists                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpPPGoalsThunk                                            1B35:2733  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpPPGoals.
;-----------------------------------------------------------------------------
CmpPPGoalsThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpPPGoals                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpSHGoalsThunk                                            1B35:273D  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpSHGoals.
;-----------------------------------------------------------------------------
CmpSHGoalsThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpSHGoals                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpPlusMinusThunk                                          1B35:2747  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpPlusMinus.
;-----------------------------------------------------------------------------
CmpPlusMinusThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpPlusMinus                 ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpPIMThunk                                                1B35:2751  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpPIM.
;-----------------------------------------------------------------------------
CmpPIMThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpPIM                       ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpShootPctThunk                                           1B35:275B  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpShootPct.
;-----------------------------------------------------------------------------
CmpShootPctThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpShootPct                  ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpGoalieWinsThunk                                         1B35:2765  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpGoalieWins.
;-----------------------------------------------------------------------------
CmpGoalieWinsThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpGoalieWins                ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; CmpSavePctThunk                                            1B35:276F  RTLink
; Overlay thunk: loads STATS.OVL (LoadFromThunk), then far-jumps to CmpSavePct.
;-----------------------------------------------------------------------------
CmpSavePctThunk:
        call LoadFromThunk
        jmp 0x26BE:CmpSavePct                   ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; assbenchsideThunk                                          1B35:2779  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assbenchside.
;-----------------------------------------------------------------------------
assbenchsideThunk:
        call LoadFromThunk
        jmp 0x2CD2:assbenchside                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assboxenterThunk                                           1B35:2783  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assboxenter.
;-----------------------------------------------------------------------------
assboxenterThunk:
        call LoadFromThunk
        jmp 0x2CD2:assboxenter                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assbenchwaitThunk                                          1B35:278D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assbenchwait.
;-----------------------------------------------------------------------------
assbenchwaitThunk:
        call LoadFromThunk
        jmp 0x2164:assbenchwait                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assleaveboxThunk                                           1B35:2797  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assleavebox.
;-----------------------------------------------------------------------------
assleaveboxThunk:
        call LoadFromThunk
        jmp 0x2164:assleavebox                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asstakepositionThunk                                       1B35:27A1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asstakeposition.
;-----------------------------------------------------------------------------
asstakepositionThunk:
        call LoadFromThunk
        jmp 0x2164:asstakeposition              ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assintrolineThunk                                          1B35:27AB  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assintroline.
;-----------------------------------------------------------------------------
assintrolineThunk:
        call LoadFromThunk
        jmp 0x2CD2:assintroline                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assintrostandThunk                                         1B35:27B5  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assintrostand.
;-----------------------------------------------------------------------------
assintrostandThunk:
        call LoadFromThunk
        jmp 0x2CD2:assintrostand                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefwhistleThunk                                         1B35:27BF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefwhistle.
;-----------------------------------------------------------------------------
assrefwhistleThunk:
        call LoadFromThunk
        jmp 0x2519:assrefwhistle                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefgoallineThunk                                        1B35:27C9  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefgoalline.
;-----------------------------------------------------------------------------
assrefgoallineThunk:
        call LoadFromThunk
        jmp 0x2519:assrefgoalline               ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefdropThunk                                            1B35:27D3  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefdrop.
;-----------------------------------------------------------------------------
assrefdropThunk:
        call LoadFromThunk
        jmp 0x2519:assrefdrop                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefgoalpaThunk                                          1B35:27DD  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefgoalpa.
;-----------------------------------------------------------------------------
assrefgoalpaThunk:
        call LoadFromThunk
        jmp 0x2519:assrefgoalpa                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefsignalThunk                                          1B35:27E7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefsignal.
;-----------------------------------------------------------------------------
assrefsignalThunk:
        call LoadFromThunk
        jmp 0x2519:assrefsignal                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assreffollowThunk                                          1B35:27F1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assreffollow.
;-----------------------------------------------------------------------------
assreffollowThunk:
        call LoadFromThunk
        jmp 0x2519:assreffollow                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assrefatdotThunk                                           1B35:27FB  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assrefatdot.
;-----------------------------------------------------------------------------
assrefatdotThunk:
        call LoadFromThunk
        jmp 0x2519:assrefatdot                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assleaveiceThunk                                           1B35:2805  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assleaveice.
;-----------------------------------------------------------------------------
assleaveiceThunk:
        call LoadFromThunk
        jmp 0x2519:assleaveice                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; puckfaceoff2Thunk                                          1B35:280F  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to puckfaceoff2.
;-----------------------------------------------------------------------------
puckfaceoff2Thunk:
        call LoadFromThunk
        jmp 0x2164:puckfaceoff2                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; puckfaceoffThunk                                           1B35:2819  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to puckfaceoff.
;-----------------------------------------------------------------------------
puckfaceoffThunk:
        call LoadFromThunk
        jmp 0x2164:puckfaceoff                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; pucknothingThunk                                           1B35:2823  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to pucknothing.
;-----------------------------------------------------------------------------
pucknothingThunk:
        call LoadFromThunk
        jmp 0x2519:pucknothing                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; puckshadowThunk                                            1B35:282D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to puckshadow.
;-----------------------------------------------------------------------------
puckshadowThunk:
        call LoadFromThunk
        jmp 0x28BB:puckshadow                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; pucknormThunk                                              1B35:2837  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to pucknorm.
;-----------------------------------------------------------------------------
pucknormThunk:
        call LoadFromThunk
        jmp 0x2519:pucknorm                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assfaceoffplThunk                                          1B35:2841  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assfaceoffpl.
;-----------------------------------------------------------------------------
assfaceoffplThunk:
        call LoadFromThunk
        jmp 0x2519:assfaceoffpl                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assfaceoffThunk                                            1B35:284B  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assfaceoff.
;-----------------------------------------------------------------------------
assfaceoffThunk:
        call LoadFromThunk
        jmp 0x2519:assfaceoff                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assthreestarsThunk                                         1B35:2855  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assthreestars.
;-----------------------------------------------------------------------------
assthreestarsThunk:
        call LoadFromThunk
        jmp 0x2CD2:assthreestars                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assstarskateThunk                                          1B35:285F  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assstarskate.
;-----------------------------------------------------------------------------
assstarskateThunk:
        call LoadFromThunk
        jmp 0x2CD2:assstarskate                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asspassrecThunk                                            1B35:2869  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asspassrec.
;-----------------------------------------------------------------------------
asspassrecThunk:
        call LoadFromThunk
        jmp 0x2C24:asspassrec                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assshootThunk                                              1B35:2873  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assshoot.
;-----------------------------------------------------------------------------
assshootThunk:
        call LoadFromThunk
        jmp 0x2519:assshoot                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assnearestThunk                                            1B35:287D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assnearest.
;-----------------------------------------------------------------------------
assnearestThunk:
        call LoadFromThunk
        jmp 0x2519:assnearest                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asspuckcThunk                                              1B35:2887  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asspuckc.
;-----------------------------------------------------------------------------
asspuckcThunk:
        call LoadFromThunk
        jmp 0x2519:asspuckc                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assgoalietopuckThunk                                       1B35:2891  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assgoalietopuck.
;-----------------------------------------------------------------------------
assgoalietopuckThunk:
        call LoadFromThunk
        jmp 0x2519:assgoalietopuck              ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assgoalieThunk                                             1B35:289B  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assgoalie.
;-----------------------------------------------------------------------------
assgoalieThunk:
        call LoadFromThunk
        jmp 0x2519:assgoalie                    ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assdopenThunk                                              1B35:28A5  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assdopen.
;-----------------------------------------------------------------------------
assdopenThunk:
        call LoadFromThunk
        jmp 0x2519:assdopen                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asspenaltyThunk                                            1B35:28AF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asspenalty.
;-----------------------------------------------------------------------------
asspenaltyThunk:
        call LoadFromThunk
        jmp 0x2519:asspenalty                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assbenchThunk                                              1B35:28B9  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assbench.
;-----------------------------------------------------------------------------
assbenchThunk:
        call LoadFromThunk
        jmp 0x2519:assbench                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assepenThunk                                               1B35:28C3  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assepen.
;-----------------------------------------------------------------------------
assepenThunk:
        call LoadFromThunk
        jmp 0x2519:assepen                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assebenThunk                                               1B35:28CD  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asseben.
;-----------------------------------------------------------------------------
assebenThunk:
        call LoadFromThunk
        jmp 0x2519:asseben                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assstanleyThunk                                            1B35:28D7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assstanley.
;-----------------------------------------------------------------------------
assstanleyThunk:
        call LoadFromThunk
        jmp 0x2519:assstanley                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assscoreThunk                                              1B35:28E1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assscore.
;-----------------------------------------------------------------------------
assscoreThunk:
        call LoadFromThunk
        jmp 0x2519:assscore                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asscenteroThunk                                            1B35:28EB  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asscentero.
;-----------------------------------------------------------------------------
asscenteroThunk:
        call LoadFromThunk
        jmp 0x2519:asscentero                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asscenterdThunk                                            1B35:28F5  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asscenterd.
;-----------------------------------------------------------------------------
asscenterdThunk:
        call LoadFromThunk
        jmp 0x2519:asscenterd                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asswingoThunk                                              1B35:28FF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asswingo.
;-----------------------------------------------------------------------------
asswingoThunk:
        call LoadFromThunk
        jmp 0x2519:asswingo                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; asswingdThunk                                              1B35:2909  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to asswingd.
;-----------------------------------------------------------------------------
asswingdThunk:
        call LoadFromThunk
        jmp 0x2519:asswingd                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assdefdThunk                                               1B35:2913  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assdefd.
;-----------------------------------------------------------------------------
assdefdThunk:
        call LoadFromThunk
        jmp 0x2519:assdefd                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; assdefoThunk                                               1B35:291D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to assdefo.
;-----------------------------------------------------------------------------
assdefoThunk:
        call LoadFromThunk
        jmp 0x2519:assdefo                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; rtssThunk                                                  1B35:2927  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to rtss.
;-----------------------------------------------------------------------------
rtssThunk:
        call LoadFromThunk
        jmp 0x2519:rtss                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; EndGameScreensThunk                                        1B35:2931  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to EndGameScreens.
;-----------------------------------------------------------------------------
EndGameScreensThunk:
        call LoadFromThunk
        jmp 0x237D:EndGameScreens               ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; joyq_flushThunk                                            1B35:293B  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to joyq_flush.
;-----------------------------------------------------------------------------
joyq_flushThunk:
        call LoadFromThunk
        jmp 0x2C24:joyq_flush                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; joyq_popThunk                                              1B35:2945  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to joyq_pop.
;-----------------------------------------------------------------------------
joyq_popThunk:
        call LoadFromThunk
        jmp 0x2C24:joyq_pop                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; DoGameFrameThunk                                           1B35:294F  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to DoGameFrame.
;-----------------------------------------------------------------------------
DoGameFrameThunk:
        call LoadFromThunk
        jmp 0x2E42:DoGameFrame                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; ClockTickThunk                                             1B35:2959  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to ClockTick.
;-----------------------------------------------------------------------------
ClockTickThunk:
        call LoadFromThunk
        jmp 0x2E42:ClockTick                    ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; joyq_peekThunk                                             1B35:2963  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to joyq_peek.
;-----------------------------------------------------------------------------
joyq_peekThunk:
        call LoadFromThunk
        jmp 0x2C24:joyq_peek                    ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; ShowGoalieBannerThunk                                      1B35:296D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to ShowGoalieBanner.
;-----------------------------------------------------------------------------
ShowGoalieBannerThunk:
        call LoadFromThunk
        jmp 0x226F:ShowGoalieBanner             ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; LoadGameGfxThunk                                           1B35:2977  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadGameGfx.
;-----------------------------------------------------------------------------
LoadGameGfxThunk:
        call LoadFromThunk
        jmp 0x1F9C:LoadGameGfx                  ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; LoadArenaJinglesThunk                                      1B35:2981  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadArenaJingles.
;-----------------------------------------------------------------------------
LoadArenaJinglesThunk:
        call LoadFromThunk
        jmp 0x2137:LoadArenaJingles             ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; LoadRinkTilesThunk                                         1B35:298B  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadRinkTiles.
;-----------------------------------------------------------------------------
LoadRinkTilesThunk:
        call LoadFromThunk
        jmp 0x24DE:LoadRinkTiles                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; FreeGameMemoryThunk                                        1B35:2995  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to FreeGameMemory.
;-----------------------------------------------------------------------------
FreeGameMemoryThunk:
        call LoadFromThunk
        jmp 0x256C:FreeGameMemory               ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; IntermissionScreensThunk                                   1B35:299F  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to IntermissionScreens.
;-----------------------------------------------------------------------------
IntermissionScreensThunk:
        call LoadFromThunk
        jmp 0x237D:IntermissionScreens          ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; StartThreeStarsThunk                                       1B35:29A9  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to StartThreeStars.
;-----------------------------------------------------------------------------
StartThreeStarsThunk:
        call LoadFromThunk
        jmp 0x2CD2:StartThreeStars              ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; FlushGSumQueueThunk                                        1B35:29B3  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to FlushGSumQueue.
;-----------------------------------------------------------------------------
FlushGSumQueueThunk:
        call LoadFromThunk
        jmp 0x2352:FlushGSumQueue               ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; DrawHudPanelThunk                                          1B35:29BD  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to DrawHudPanel.
;-----------------------------------------------------------------------------
DrawHudPanelThunk:
        call LoadFromThunk
        jmp 0x2083:DrawHudPanel                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; PeriodOverThunk                                            1B35:29C7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to PeriodOver.
;-----------------------------------------------------------------------------
PeriodOverThunk:
        call LoadFromThunk
        jmp 0x2E42:PeriodOver                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; RunDeferredCallsThunk                                      1B35:29D1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to RunDeferredCalls.
;-----------------------------------------------------------------------------
RunDeferredCallsThunk:
        call LoadFromThunk
        jmp 0x2352:RunDeferredCalls             ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; PutGSumTailThunk                                           1B35:29DB  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to PutGSumTail.
;-----------------------------------------------------------------------------
PutGSumTailThunk:
        call LoadFromThunk
        jmp 0x2352:PutGSumTail                  ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; UpdateHudPanelThunk                                        1B35:29E5  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to UpdateHudPanel.
;-----------------------------------------------------------------------------
UpdateHudPanelThunk:
        call LoadFromThunk
        jmp 0x2083:UpdateHudPanel               ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; DrawRinkOverlaysThunk                                      1B35:29EF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to DrawRinkOverlays.
;-----------------------------------------------------------------------------
DrawRinkOverlaysThunk:
        call LoadFromThunk
        jmp 0x2E42:DrawRinkOverlays             ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; ClearTeamNameTextThunk                                     1B35:29F9  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ClearTeamNameText.
;-----------------------------------------------------------------------------
ClearTeamNameTextThunk:
        call LoadFromThunk
        jmp 0x252F:ClearTeamNameText            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; SetTeamNameTextThunk                                       1B35:2A03  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to SetTeamNameText.
;-----------------------------------------------------------------------------
SetTeamNameTextThunk:
        call LoadFromThunk
        jmp 0x252F:SetTeamNameText              ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; SetupGameThunk                                             1B35:2A0D  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to SetupGame.
;-----------------------------------------------------------------------------
SetupGameThunk:
        call LoadFromThunk
        jmp 0x1F9C:SetupGame                    ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; GSummaryPathThunk                                          1B35:2A17  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to MakeGSummaryPath.
;-----------------------------------------------------------------------------
GSummaryPathThunk:
        call LoadFromThunk
        jmp 0x2425:MakeGSummaryPath                 ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; SetupTeamLinesThunk                                        1B35:2A21  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to SetupTeamLines.
;-----------------------------------------------------------------------------
SetupTeamLinesThunk:
        call LoadFromThunk
        jmp 0x317A:SetupTeamLines               ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; NormalizeDressFlagsThunk                                   1B35:2A2B  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to NormalizeDressFlags.
;-----------------------------------------------------------------------------
NormalizeDressFlagsThunk:
        call LoadFromThunk
        jmp 0x317A:NormalizeDressFlags          ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; BuildDefaultLinesThunk                                     1B35:2A35  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to BuildDefaultLines.
;-----------------------------------------------------------------------------
BuildDefaultLinesThunk:
        call LoadFromThunk
        jmp 0x317A:BuildDefaultLines            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; LoadGameStateThunk                                         1B35:2A3F  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to LoadGameState.
;-----------------------------------------------------------------------------
LoadGameStateThunk:
        call LoadFromThunk
        jmp 0x278C:LoadGameState                ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; NullGameHookThunk                                          1B35:2A49  RTLink
; Overlay thunk: loads GAME.OVL (LoadFromThunk), then far-jumps to NullGameHook.
;-----------------------------------------------------------------------------
NullGameHookThunk:
        call LoadFromThunk
        jmp 0x1F54:NullGameHook                 ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; StartPreGameThunk                                          1B35:2A53  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to StartPreGame.
;-----------------------------------------------------------------------------
StartPreGameThunk:
        call LoadFromThunk
        jmp 0x2CD2:StartPreGame                 ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; forceteamsThunk                                            1B35:2A5D  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to forceteams.
;-----------------------------------------------------------------------------
forceteamsThunk:
        call LoadFromThunk
        jmp 0x2E42:forceteams                   ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; StartGameThunk                                             1B35:2A67  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to StartGame.
;-----------------------------------------------------------------------------
StartGameThunk:
        call LoadFromThunk
        jmp 0x2E42:StartGame                    ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; FreeArenaJinglesThunk                                      1B35:2A71  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to FreeArenaJingles.
;-----------------------------------------------------------------------------
FreeArenaJinglesThunk:
        call LoadFromThunk
        jmp 0x2137:FreeArenaJingles             ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; ReturnZeroInitThunk                                        1B35:2A7B  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ReturnZeroInit.
;-----------------------------------------------------------------------------
ReturnZeroInitThunk:
        call LoadFromThunk
        jmp 0x237D:ReturnZeroInit               ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; ReturnZeroInit2Thunk                                       1B35:2A85  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to ReturnZeroInit2.
;-----------------------------------------------------------------------------
ReturnZeroInit2Thunk:
        call LoadFromThunk
        jmp 0x237D:ReturnZeroInit2              ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; WriteGSumHeaderThunk                                       1B35:2A8F  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to WriteGSumHeader.
;-----------------------------------------------------------------------------
WriteGSumHeaderThunk:
        call LoadFromThunk
        jmp 0x2352:WriteGSumHeader              ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; StartHL2Thunk                                              1B35:2A99  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to StartHL2.
;-----------------------------------------------------------------------------
StartHL2Thunk:
        call LoadFromThunk
        jmp 0x1FAA:StartHL2                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; PutGSumHeaderThunk                                         1B35:2AA3  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to PutGSumHeader.
;-----------------------------------------------------------------------------
PutGSumHeaderThunk:
        call LoadFromThunk
        jmp 0x2352:PutGSumHeader                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; FreePlayerFramesThunk                                      1B35:2AAD  RTLink
; Overlay thunk: loads INIT.OVL (LoadFromThunk), then far-jumps to FreePlayerFrames.
;-----------------------------------------------------------------------------
FreePlayerFramesThunk:
        call LoadFromThunk
        jmp 0x256C:FreePlayerFrames             ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; GameOverThunk                                              1B35:2AB7  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to GameOver.
;-----------------------------------------------------------------------------
GameOverThunk:
        call LoadFromThunk
        jmp 0x2E42:GameOver                     ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; ReplayFirstFrameThunk                                      1B35:2AC1  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to ReplayFirstFrame.
;-----------------------------------------------------------------------------
ReplayFirstFrameThunk:
        call LoadFromThunk
        jmp 0x2038:ReplayFirstFrame             ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; GetPeriodTimeThunk                                         1B35:2ACB  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to GetPeriodTime.
;-----------------------------------------------------------------------------
GetPeriodTimeThunk:
        call LoadFromThunk
        jmp 0x2E42:GetPeriodTime                ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; SprSortThunk                                               1B35:2AD5  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to SprSort.
;-----------------------------------------------------------------------------
SprSortThunk:
        call LoadFromThunk
        jmp 0x2E42:SprSort                      ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; ReplayRecordResetThunk                                     1B35:2ADF  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to ReplayRecordReset.
;-----------------------------------------------------------------------------
ReplayRecordResetThunk:
        call LoadFromThunk
        jmp 0x2038:ReplayRecordReset            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; BuildEventLinesThunk                                       1B35:2AE9  RTLink
; Overlay thunk: loads AI.OVL (LoadFromThunk), then far-jumps to BuildEventLines.
;-----------------------------------------------------------------------------
BuildEventLinesThunk:
        call LoadFromThunk
        db 0xEA                                 ; insn: jmp 0x2352:BuildEventLines, finished in the next segment
        dw BuildEventLines                      ; AI.OVL
        db 0x52
