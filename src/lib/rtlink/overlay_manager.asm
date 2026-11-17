; Resident RTLink/Plus overlay manager, and the thunk that calls each overlaid routine. DOS enters at
; __astart, which saves the PSP, sets this manager up, and jumps to the Microsoft C startup. The file-name
; slots and the thunks follow the manager in the same segment.

; MscStartup is in the C runtime; the Rtl routines are in the RTLink runtime.
SectionStride	equ	18
FileSlotSize	equ	0x80

; Overlay-manager messages. Each eov code is its own string and the
; sentence follows the terminating null. The print helper substitutes
; xxxx with the number it was given.
Messages:                                       ; not used in the EXE (overlays may use it)
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
MsgCloseQuote:                                  ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db '"', 13, 10
        db 0
MsgEov0001:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0001: '
        db 0
MsgCannotFind:                                  ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Cannot find overlay file "'
        db 0
MsgEov0002:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0002: '
        db 0
MsgOpenError:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Open error on overlay file "'
        db 0
MsgEov0003:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0003: '
        db 0
MsgReadError:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Read error on overlay file "'
        db 0
MsgEov0007:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0007: '
        db 0
MsgCommit:                                      ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Commit error - section '
MsgIntersectLead:                               ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        times 4 db 0
MsgIntersect:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'H intersects committed section '
MsgIntersect2Lead:                              ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        times 4 db 0
MsgIntersect2:                                  ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'H', 13, 10
        db 0
MsgEov0009:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0009: '
        db 0
MsgVector:                                      ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Vector at '
MsgVectorAt:                                    ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'xxxx:xxxx is corrupted.', 13, 10
        db 0
MsgEov0010:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0010: '
        db 0
MsgLoadAfter:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Attempt to load section '
MsgAfterLead:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        times 4 db 0
MsgAfterH:                                      ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'H after $$RTL_TERMINATE.', 13, 10
        db 0
MsgEov0004:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0004: '
        db 0
MsgOverflow:                                    ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'Overlay Manager Internal Reload Stack Overflow', 13, 10
        db '      -- use RELOAD to increase size', 13, 10
        db 0
MsgEov0005:                                     ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
        db 'eov0005: '
        db 0
MsgUnderflow:                                   ; RTLink overlay-manager message (eovxxxx strings); not
                                                ; referenced in the root code
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
SecMenus:                                       ; 18-byte section record for MENUS.OVL; not referenced in the
                                                ; root code
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
SecLp:                                          ; 18-byte section record for LP.OVL; not referenced in the
                                                ; root code
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
SecStats:                                       ; 18-byte section record for STATS.OVL; not referenced in the
                                                ; root code
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
SecGame:                                        ; 18-byte section record for GAME.OVL; not referenced in the
                                                ; root code
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
SecInit:                                        ; 18-byte section record for INIT.OVL; not referenced in the
                                                ; root code
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
SecAi:                                          ; 18-byte section record for AI.OVL; not referenced in the
                                                ; root code
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
SecMovie:                                       ; 18-byte section record for MOVIE.OVL; not referenced in the
                                                ; root code
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
SecFades:                                       ; 18-byte section record for FADES.OVL; not referenced in the
                                                ; root code
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
SecFades1:                                      ; 18-byte section record for FADES1.OVL; not referenced in the
                                                ; root code
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
SecFades2:                                      ; 18-byte section record for FADES2.OVL; not referenced in the
                                                ; root code
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
SecFades3:                                      ; 18-byte section record for FADES3.OVL; not referenced in the
                                                ; root code
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
SecFades4:                                      ; 18-byte section record for FADES4.OVL; not referenced in the
                                                ; root code
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
SecFades5:                                      ; 18-byte section record for FADES5.OVL; not referenced in the
                                                ; root code
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
SecFades6:                                      ; 18-byte section record for FADES6.OVL; not referenced in the
                                                ; root code
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
SecFades7:                                      ; 18-byte section record for FADES7.OVL; not referenced in the
                                                ; root code
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
SecFades8:                                      ; 18-byte section record for FADES8.OVL; not referenced in the
                                                ; root code
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
SecFades9:                                      ; 18-byte section record for FADES9.OVL; not referenced in the
                                                ; root code
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
SecFades10:                                     ; 18-byte section record for FADES10.OVL; not referenced in
                                                ; the root code
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
SecFades11:                                     ; 18-byte section record for FADES11.OVL; not referenced in
                                                ; the root code
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
SecFades12:                                     ; 18-byte section record for FADES12.OVL; not referenced in
                                                ; the root code
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
SecHockey:                                      ; 18-byte section record for HOCKEY.EXE; not referenced in the
                                                ; root code
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
ReloadStack:                                    ; reload stack placed after the section table; not referenced
                                                ; in the root code
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
OvlThunk0:
        call LoadFromThunk
        jmp 0x2248:0x1B0                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk1                                                  1B35:1FF9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk1:
        call LoadFromThunk
        jmp 0x2248:0x274                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk2                                                  1B35:2003  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk2:
        call LoadFromThunk
        jmp 0x2248:0x350                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk3                                                  1B35:200D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk3:
        call LoadFromThunk
        jmp 0x25B2:0x4C4                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk4                                                  1B35:2017  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk4:
        call LoadFromThunk
        jmp 0x25B2:0x51C                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk5                                                  1B35:2021  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk5:
        call LoadFromThunk
        jmp 0x2A57:0x34C                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk6                                                  1B35:202B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk6:
        call LoadFromThunk
        jmp 0x2047:0x30E6                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk7                                                  1B35:2035  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk7:
        call LoadFromThunk
        jmp 0x2CF8:0x12AA                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk8                                                  1B35:203F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk8:
        call LoadFromThunk
        jmp 0x26D4:0x2A80                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk9                                                  1B35:2049  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk9:
        call LoadFromThunk
        jmp 0x2E70:0x2090                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk10                                                 1B35:2053  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk10:
        call LoadFromThunk
        jmp 0x2B26:0x112                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk11                                                 1B35:205D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk11:
        call LoadFromThunk
        jmp 0x26D4:0x16                         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk12                                                 1B35:2067  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk12:
        call LoadFromThunk
        jmp 0x26D4:0xE                          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk13                                                 1B35:2071  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk13:
        call LoadFromThunk
        jmp 0x2E70:0x1CF0                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk14                                                 1B35:207B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk14:
        call LoadFromThunk
        jmp 0x2047:0x281A                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk15                                                 1B35:2085  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk15:
        call LoadFromThunk
        jmp 0x2047:0x2FA4                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk16                                                 1B35:208F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk16:
        call LoadFromThunk
        jmp 0x2047:0x252E                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk17                                                 1B35:2099  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk17:
        call LoadFromThunk
        jmp 0x2CF8:0x1388                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk18                                                 1B35:20A3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk18:
        call LoadFromThunk
        jmp 0x2425:0x4EA                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk19                                                 1B35:20AD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk19:
        call LoadFromThunk
        jmp 0x2425:0xA20                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk20                                                 1B35:20B7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk20:
        call LoadFromThunk
        jmp 0x2519:0x1A7E                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk21                                                 1B35:20C1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk21:
        call LoadFromThunk
        jmp 0x2425:0x2CE                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk22                                                 1B35:20CB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk22:
        call LoadFromThunk
        jmp 0x2E70:0xA                          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk23                                                 1B35:20D5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section FADES4.OVL.
;-----------------------------------------------------------------------------
OvlThunk23:
        call LoadFromThunk
        jmp 0x3358:0                            ; load paragraph, relocated
        dw 11                                   ; FADES4.OVL
;-----------------------------------------------------------------------------
; OvlThunk24                                                 1B35:20DF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk24:
        call LoadFromThunk
        jmp 0x1F9D:0xC                          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk25                                                 1B35:20E9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk25:
        call LoadFromThunk
        jmp 0x22D3:0x262                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk26                                                 1B35:20F3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk26:
        call LoadFromThunk
        jmp 0x2E70:0x9FE                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk27                                                 1B35:20FD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk27:
        call LoadFromThunk
        jmp 0x1F9D:0x580                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk28                                                 1B35:2107  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk28:
        call LoadFromThunk
        jmp 0x2E70:0x964                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk29                                                 1B35:2111  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk29:
        call LoadFromThunk
        jmp 0x26D4:0x180                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk30                                                 1B35:211B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk30:
        call LoadFromThunk
        jmp 0x2E70:0x2054                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk31                                                 1B35:2125  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk31:
        call LoadFromThunk
        jmp 0x2E70:0x11EC                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk32                                                 1B35:212F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk32:
        call LoadFromThunk
        jmp 0x2E70:0xF22                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk33                                                 1B35:2139  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk33:
        call LoadFromThunk
        jmp 0x23A3:4                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk34                                                 1B35:2143  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk34:
        call LoadFromThunk
        jmp 0x2E70:0x1B6A                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk35                                                 1B35:214D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk35:
        call LoadFromThunk
        jmp 0x2E70:0x1EEC                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk36                                                 1B35:2157  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk36:
        call LoadFromThunk
        jmp 0x2E70:0x16DE                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk37                                                 1B35:2161  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk37:
        call LoadFromThunk
        jmp 0x2E70:0x18E2                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk38                                                 1B35:216B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk38:
        call LoadFromThunk
        jmp 0x2E70:0x18A6                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk39                                                 1B35:2175  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk39:
        call LoadFromThunk
        jmp 0x2E70:0x1BA6                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk40                                                 1B35:217F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk40:
        call LoadFromThunk
        jmp 0x2E70:0x144A                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk41                                                 1B35:2189  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk41:
        call LoadFromThunk
        jmp 0x2E70:0x1594                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk42                                                 1B35:2193  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk42:
        call LoadFromThunk
        jmp 0x2E70:0x1A26                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk43                                                 1B35:219D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk43:
        call LoadFromThunk
        jmp 0x22B3:0x62E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk44                                                 1B35:21A7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk44:
        call LoadFromThunk
        jmp 0x2528:4                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk45                                                 1B35:21B1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk45:
        call LoadFromThunk
        jmp 0x1E45:0xA                          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk46                                                 1B35:21BB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk46:
        call LoadFromThunk
        jmp 0x1E45:0                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk47                                                 1B35:21C5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk47:
        call LoadFromThunk
        jmp 0x2CAA:8                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk48                                                 1B35:21CF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk48:
        call LoadFromThunk
        jmp 0x25DD:6                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk49                                                 1B35:21D9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk49:
        call LoadFromThunk
        jmp 0x2248:0x62A                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk50                                                 1B35:21E3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk50:
        call LoadFromThunk
        jmp 0x2248:0x608                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk51                                                 1B35:21ED  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk51:
        call LoadFromThunk
        jmp 0x2248:0x5E6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk52                                                 1B35:21F7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk52:
        call LoadFromThunk
        jmp 0x2248:0x5C4                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk53                                                 1B35:2201  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk53:
        call LoadFromThunk
        jmp 0x2248:0x5A2                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk54                                                 1B35:220B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk54:
        call LoadFromThunk
        jmp 0x2248:0x580                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk55                                                 1B35:2215  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk55:
        call LoadFromThunk
        jmp 0x2248:0x55E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk56                                                 1B35:221F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk56:
        call LoadFromThunk
        jmp 0x2248:0x53C                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk57                                                 1B35:2229  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk57:
        call LoadFromThunk
        jmp 0x2248:0x51A                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk58                                                 1B35:2233  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk58:
        call LoadFromThunk
        jmp 0x2248:0x4F8                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk59                                                 1B35:223D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk59:
        call LoadFromThunk
        jmp 0x2248:0x4D6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk60                                                 1B35:2247  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk60:
        call LoadFromThunk
        jmp 0x2248:0x4B4                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk61                                                 1B35:2251  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk61:
        call LoadFromThunk
        jmp 0x2248:0x492                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk62                                                 1B35:225B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk62:
        call LoadFromThunk
        jmp 0x2248:0x470                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk63                                                 1B35:2265  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk63:
        call LoadFromThunk
        jmp 0x2248:0x44E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk64                                                 1B35:226F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk64:
        call LoadFromThunk
        jmp 0x2248:0x42C                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk65                                                 1B35:2279  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk65:
        call LoadFromThunk
        jmp 0x2CF8:0x10A4                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk66                                                 1B35:2283  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk66:
        call LoadFromThunk
        jmp 0x2CF8:0xFCE                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk67                                                 1B35:228D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk67:
        call LoadFromThunk
        jmp 0x2CF8:0xF98                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk68                                                 1B35:2297  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk68:
        call LoadFromThunk
        jmp 0x2CF8:0xFB2                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk69                                                 1B35:22A1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk69:
        call LoadFromThunk
        jmp 0x2C1E:4                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk70                                                 1B35:22AB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk70:
        call LoadFromThunk
        jmp 0x1E45:0x108                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk71                                                 1B35:22B5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk71:
        call LoadFromThunk
        jmp 0x1E45:0xFE                         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk72                                                 1B35:22BF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk72:
        call LoadFromThunk
        jmp 0x2CF8:0x1754                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk73                                                 1B35:22C9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk73:
        call LoadFromThunk
        jmp 0x2CF8:0x171E                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk74                                                 1B35:22D3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk74:
        call LoadFromThunk
        jmp 0x2CF8:0x16E8                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk75                                                 1B35:22DD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk75:
        call LoadFromThunk
        jmp 0x2CF8:0x16B2                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk76                                                 1B35:22E7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk76:
        call LoadFromThunk
        jmp 0x2CF8:0x167C                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk77                                                 1B35:22F1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk77:
        call LoadFromThunk
        jmp 0x2CF8:0x1646                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk78                                                 1B35:22FB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk78:
        call LoadFromThunk
        jmp 0x2CF8:0x1206                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk79                                                 1B35:2305  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk79:
        call LoadFromThunk
        jmp 0x2CF8:0x15CC                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk80                                                 1B35:230F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk80:
        call LoadFromThunk
        jmp 0x2CF8:0x1550                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk81                                                 1B35:2319  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk81:
        call LoadFromThunk
        jmp 0x2CF8:0x14D4                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk82                                                 1B35:2323  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk82:
        call LoadFromThunk
        jmp 0x2CF8:0x1466                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk83                                                 1B35:232D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk83:
        call LoadFromThunk
        jmp 0x215A:0x79E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk84                                                 1B35:2337  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk84:
        call LoadFromThunk
        jmp 0x2047:0x2C90                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk85                                                 1B35:2341  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk85:
        call LoadFromThunk
        jmp 0x2047:0x2706                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk86                                                 1B35:234B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk86:
        call LoadFromThunk
        jmp 0x2047:0x25F2                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk87                                                 1B35:2355  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk87:
        call LoadFromThunk
        jmp 0x2047:0x25EE                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk88                                                 1B35:235F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk88:
        call LoadFromThunk
        jmp 0x2047:0x2A60                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk89                                                 1B35:2369  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk89:
        call LoadFromThunk
        jmp 0x2047:0x2FA0                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk90                                                 1B35:2373  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk90:
        call LoadFromThunk
        jmp 0x2248:0xC                          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk91                                                 1B35:237D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk91:
        call LoadFromThunk
        jmp 0x2248:0x14                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk92                                                 1B35:2387  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk92:
        call LoadFromThunk
        jmp 0x2248:0x1E                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk93                                                 1B35:2391  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk93:
        call LoadFromThunk
        jmp 0x2248:0x64C                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk94                                                 1B35:239B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk94:
        call LoadFromThunk
        jmp 0x2248:0x656                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk95                                                 1B35:23A5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk95:
        call LoadFromThunk
        jmp 0x2B26:0x52                         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk96                                                 1B35:23AF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk96:
        call LoadFromThunk
        jmp 0x1E45:0x65E                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk97                                                 1B35:23B9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk97:
        call LoadFromThunk
        jmp 0x1E45:0x654                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk98                                                 1B35:23C3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk98:
        call LoadFromThunk
        jmp 0x26D4:0x12                         ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk99                                                 1B35:23CD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk99:
        call LoadFromThunk
        jmp 0x278C:6                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk100                                                1B35:23D7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk100:
        call LoadFromThunk
        jmp 0x2E70:0xD0A                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk101                                                1B35:23E1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk101:
        call LoadFromThunk
        jmp 0x2E18:0xA                          ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk102                                                1B35:23EB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk102:
        call LoadFromThunk
        jmp 0x1E45:0x25C                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk103                                                1B35:23F5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk103:
        call LoadFromThunk
        jmp 0x1E45:0xFD2                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk104                                                1B35:23FF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk104:
        call LoadFromThunk
        jmp 0x2E42:0x1DE                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk105                                                1B35:2409  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk105:
        call LoadFromThunk
        jmp 0x2E42:0x1994                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk106                                                1B35:2413  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk106:
        call LoadFromThunk
        jmp 0x2062:0xE                          ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk107                                                1B35:241D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MOVIE.OVL.
;-----------------------------------------------------------------------------
OvlThunk107:
        call LoadFromThunk
        jmp 0x3357:0x192                        ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; OvlThunk108                                                1B35:2427  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MOVIE.OVL.
;-----------------------------------------------------------------------------
OvlThunk108:
        call LoadFromThunk
        jmp 0x3357:0x30E                        ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; OvlThunk109                                                1B35:2431  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MOVIE.OVL.
;-----------------------------------------------------------------------------
OvlThunk109:
        call LoadFromThunk
        jmp 0x3349:0                            ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; OvlThunk110                                                1B35:243B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MOVIE.OVL.
;-----------------------------------------------------------------------------
OvlThunk110:
        call LoadFromThunk
        jmp 0x3357:0x6C8                        ; load paragraph, relocated
        dw 6                                    ; MOVIE.OVL
;-----------------------------------------------------------------------------
; OvlThunk111                                                1B35:2445  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk111:
        call LoadFromThunk
        jmp 0x2047:0x20E4                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk112                                                1B35:244F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk112:
        call LoadFromThunk
        jmp 0x2047:8                            ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk113                                                1B35:2459  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk113:
        call LoadFromThunk
        jmp 0x2446:0x6A                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk114                                                1B35:2463  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk114:
        call LoadFromThunk
        jmp 0x2095:8                            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk115                                                1B35:246D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk115:
        call LoadFromThunk
        jmp 0x1EAE:0x44                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk116                                                1B35:2477  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk116:
        call LoadFromThunk
        jmp 0x1E45:0                            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk117                                                1B35:2481  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk117:
        call LoadFromThunk
        jmp 0x1E45:0x47C                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk118                                                1B35:248B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk118:
        call LoadFromThunk
        jmp 0x26D4:0x29F2                       ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk119                                                1B35:2495  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk119:
        call LoadFromThunk
        jmp 0x2528:0x426                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk120                                                1B35:249F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk120:
        call LoadFromThunk
        jmp 0x2E70:0x968                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk121                                                1B35:24A9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk121:
        call LoadFromThunk
        jmp 0x23AD:0x46                         ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk122                                                1B35:24B3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk122:
        call LoadFromThunk
        jmp 0x25B2:0x18F4                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk123                                                1B35:24BD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk123:
        call LoadFromThunk
        jmp 0x22B3:0x558                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk124                                                1B35:24C7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk124:
        call LoadFromThunk
        jmp 0x22B3:0x390                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk125                                                1B35:24D1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk125:
        call LoadFromThunk
        jmp 0x22B3:0x1C8                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk126                                                1B35:24DB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk126:
        call LoadFromThunk
        jmp 0x22B3:0                            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk127                                                1B35:24E5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section GAME.OVL.
;-----------------------------------------------------------------------------
OvlThunk127:
        call LoadFromThunk
        jmp 0x1E7E:0x88A                        ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; OvlThunk128                                                1B35:24EF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk128:
        call LoadFromThunk
        jmp 0x215A:0x6AC                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk129                                                1B35:24F9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk129:
        call LoadFromThunk
        jmp 0x215A:0x56A                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk130                                                1B35:2503  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk130:
        call LoadFromThunk
        jmp 0x215A:0x428                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk131                                                1B35:250D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk131:
        call LoadFromThunk
        jmp 0x215A:0x2E6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk132                                                1B35:2517  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk132:
        call LoadFromThunk
        jmp 0x1F9C:0                            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk133                                                1B35:2521  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk133:
        call LoadFromThunk
        jmp 0x1E45:0x598                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk134                                                1B35:252B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk134:
        call LoadFromThunk
        jmp 0x2007:0x1BC                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk135                                                1B35:2535  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk135:
        call LoadFromThunk
        jmp 0x2425:0x374                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk136                                                1B35:253F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk136:
        call LoadFromThunk
        jmp 0x2B26:0x3C4                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk137                                                1B35:2549  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk137:
        call LoadFromThunk
        jmp 0x2B26:0x19C                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk138                                                1B35:2553  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk138:
        call LoadFromThunk
        jmp 0x2B26:0x2B0                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk139                                                1B35:255D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk139:
        call LoadFromThunk
        jmp 0x2CF8:0xE                          ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk140                                                1B35:2567  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk140:
        call LoadFromThunk
        jmp 0x256C:0xE8                         ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk141                                                1B35:2571  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section GAME.OVL.
;-----------------------------------------------------------------------------
OvlThunk141:
        call LoadFromThunk
        jmp 0x1E7E:0xA94                        ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; OvlThunk142                                                1B35:257B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk142:
        call LoadFromThunk
        jmp 0x251E:0x38                         ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk143                                                1B35:2585  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk143:
        call LoadFromThunk
        jmp 0x1F9C:0x1B4                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk144                                                1B35:258F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk144:
        call LoadFromThunk
        jmp 0x1F9C:0x72                         ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk145                                                1B35:2599  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk145:
        call LoadFromThunk
        jmp 0x2581:0xE                          ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk146                                                1B35:25A3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk146:
        call LoadFromThunk
        jmp 0x21A1:8                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk147                                                1B35:25AD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk147:
        call LoadFromThunk
        jmp 0x2306:0x2B6                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk148                                                1B35:25B7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk148:
        call LoadFromThunk
        jmp 0x226F:0xDAA                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk149                                                1B35:25C1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section MENUS.OVL.
;-----------------------------------------------------------------------------
OvlThunk149:
        call LoadFromThunk
        jmp 0x2E70:0xE36                        ; load paragraph, relocated
        dw 0                                    ; MENUS.OVL
;-----------------------------------------------------------------------------
; OvlThunk150                                                1B35:25CB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk150:
        call LoadFromThunk
        jmp 0x1ECB:8                            ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk151                                                1B35:25D5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk151:
        call LoadFromThunk
        jmp 0x2A1B:4                            ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk152                                                1B35:25DF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk152:
        call LoadFromThunk
        jmp 0x2CB7:0x134E                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk153                                                1B35:25E9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk153:
        call LoadFromThunk
        jmp 0x2CB7:0x1442                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk154                                                1B35:25F3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk154:
        call LoadFromThunk
        jmp 0x2305:0xC                          ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk155                                                1B35:25FD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk155:
        call LoadFromThunk
        jmp 0x1ECB:0x332                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk156                                                1B35:2607  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk156:
        call LoadFromThunk
        jmp 0x2A57:0x2152                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk157                                                1B35:2611  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk157:
        call LoadFromThunk
        jmp 0x2CB7:0x9FA                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk158                                                1B35:261B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk158:
        call LoadFromThunk
        jmp 0x2CB7:0xC28                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk159                                                1B35:2625  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk159:
        call LoadFromThunk
        jmp 0x2139:0x1430                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk160                                                1B35:262F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk160:
        call LoadFromThunk
        jmp 0x25B2:0x208A                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk161                                                1B35:2639  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk161:
        call LoadFromThunk
        jmp 0x2139:0x15EC                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk162                                                1B35:2643  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk162:
        call LoadFromThunk
        jmp 0x22D3:0x1E2                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk163                                                1B35:264D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk163:
        call LoadFromThunk
        jmp 0x2A57:0x1080                       ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk164                                                1B35:2657  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk164:
        call LoadFromThunk
        jmp 0x2A57:0xFDE                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk165                                                1B35:2661  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk165:
        call LoadFromThunk
        jmp 0x1F31:0xBA6                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk166                                                1B35:266B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk166:
        call LoadFromThunk
        jmp 0x1F31:0xB9E                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk167                                                1B35:2675  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section LP.OVL.
;-----------------------------------------------------------------------------
OvlThunk167:
        call LoadFromThunk
        jmp 0x25B2:0x574                        ; load paragraph, relocated
        dw 1                                    ; LP.OVL
;-----------------------------------------------------------------------------
; OvlThunk168                                                1B35:267F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk168:
        call LoadFromThunk
        jmp 0x2351:0x4A6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk169                                                1B35:2689  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk169:
        call LoadFromThunk
        jmp 0x2351:0x3D0                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk170                                                1B35:2693  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk170:
        call LoadFromThunk
        jmp 0x2351:0x28E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk171                                                1B35:269D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk171:
        call LoadFromThunk
        jmp 0x2351:0x14C                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk172                                                1B35:26A7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk172:
        call LoadFromThunk
        jmp 0x2351:0xA                          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk173                                                1B35:26B1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk173:
        call LoadFromThunk
        jmp 0x2425:0                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk174                                                1B35:26BB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section FADES12.OVL.
;-----------------------------------------------------------------------------
OvlThunk174:
        call LoadFromThunk
        jmp 0x3358:0                            ; load paragraph, relocated
        dw 19                                   ; FADES12.OVL
;-----------------------------------------------------------------------------
; OvlThunk175                                                1B35:26C5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk175:
        call LoadFromThunk
        jmp 0x2248:0xEC                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk176                                                1B35:26CF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk176:
        call LoadFromThunk
        jmp 0x2248:0x28                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk177                                                1B35:26D9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk177:
        call LoadFromThunk
        jmp 0x2095:0xC0                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk178                                                1B35:26E3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk178:
        call LoadFromThunk
        jmp 0x2095:0x180                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk179                                                1B35:26ED  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk179:
        call LoadFromThunk
        jmp 0x25E5:2                            ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk180                                                1B35:26F7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk180:
        call LoadFromThunk
        jmp 0x25E5:0x11A                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk181                                                1B35:2701  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk181:
        call LoadFromThunk
        jmp 0x25E5:0x3B6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk182                                                1B35:270B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk182:
        call LoadFromThunk
        jmp 0x25E5:0x232                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk183                                                1B35:2715  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk183:
        call LoadFromThunk
        jmp 0x25E5:0x52E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk184                                                1B35:271F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk184:
        call LoadFromThunk
        jmp 0x26BE:0xA                          ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk185                                                1B35:2729  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk185:
        call LoadFromThunk
        jmp 0x26BE:0xEC                         ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk186                                                1B35:2733  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk186:
        call LoadFromThunk
        jmp 0x26BE:0x1C6                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk187                                                1B35:273D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk187:
        call LoadFromThunk
        jmp 0x26BE:0x2C0                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk188                                                1B35:2747  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk188:
        call LoadFromThunk
        jmp 0x26BE:0x3BA                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk189                                                1B35:2751  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk189:
        call LoadFromThunk
        jmp 0x26BE:0x49E                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk190                                                1B35:275B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk190:
        call LoadFromThunk
        jmp 0x26BE:0x598                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk191                                                1B35:2765  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk191:
        call LoadFromThunk
        jmp 0x26BE:0x67A                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk192                                                1B35:276F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section STATS.OVL.
;-----------------------------------------------------------------------------
OvlThunk192:
        call LoadFromThunk
        jmp 0x26BE:0x7C2                        ; load paragraph, relocated
        dw 2                                    ; STATS.OVL
;-----------------------------------------------------------------------------
; OvlThunk193                                                1B35:2779  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk193:
        call LoadFromThunk
        jmp 0x2CD2:0x1640                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk194                                                1B35:2783  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk194:
        call LoadFromThunk
        jmp 0x2CD2:0x14DC                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk195                                                1B35:278D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk195:
        call LoadFromThunk
        jmp 0x2164:0xCB0                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk196                                                1B35:2797  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk196:
        call LoadFromThunk
        jmp 0x2164:0x1D6                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk197                                                1B35:27A1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk197:
        call LoadFromThunk
        jmp 0x2164:0xCDC                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk198                                                1B35:27AB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk198:
        call LoadFromThunk
        jmp 0x2CD2:0x534                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk199                                                1B35:27B5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk199:
        call LoadFromThunk
        jmp 0x2CD2:0x4BA                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk200                                                1B35:27BF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk200:
        call LoadFromThunk
        jmp 0x2519:0x2EC2                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk201                                                1B35:27C9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk201:
        call LoadFromThunk
        jmp 0x2519:0x38EC                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk202                                                1B35:27D3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk202:
        call LoadFromThunk
        jmp 0x2519:0x3762                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk203                                                1B35:27DD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk203:
        call LoadFromThunk
        jmp 0x2519:0x31E4                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk204                                                1B35:27E7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk204:
        call LoadFromThunk
        jmp 0x2519:0x303C                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk205                                                1B35:27F1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk205:
        call LoadFromThunk
        jmp 0x2519:0x295E                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk206                                                1B35:27FB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk206:
        call LoadFromThunk
        jmp 0x2519:0x28DC                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk207                                                1B35:2805  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk207:
        call LoadFromThunk
        jmp 0x2519:0xAF0                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk208                                                1B35:280F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk208:
        call LoadFromThunk
        jmp 0x2164:0x650                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk209                                                1B35:2819  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk209:
        call LoadFromThunk
        jmp 0x2164:0x3AA                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk210                                                1B35:2823  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk210:
        call LoadFromThunk
        jmp 0x2519:0x2396                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk211                                                1B35:282D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk211:
        call LoadFromThunk
        jmp 0x28BB:0x1E08                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk212                                                1B35:2837  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk212:
        call LoadFromThunk
        jmp 0x2519:0x2294                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk213                                                1B35:2841  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk213:
        call LoadFromThunk
        jmp 0x2519:0x2162                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk214                                                1B35:284B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk214:
        call LoadFromThunk
        jmp 0x2519:0x2142                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk215                                                1B35:2855  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk215:
        call LoadFromThunk
        jmp 0x2CD2:0x11D0                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk216                                                1B35:285F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk216:
        call LoadFromThunk
        jmp 0x2CD2:0x10B0                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk217                                                1B35:2869  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk217:
        call LoadFromThunk
        jmp 0x2C24:0xA1C                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk218                                                1B35:2873  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk218:
        call LoadFromThunk
        jmp 0x2519:0x20F8                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk219                                                1B35:287D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk219:
        call LoadFromThunk
        jmp 0x2519:0x1C22                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk220                                                1B35:2887  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk220:
        call LoadFromThunk
        jmp 0x2519:0x1960                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk221                                                1B35:2891  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk221:
        call LoadFromThunk
        jmp 0x2519:0x111C                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk222                                                1B35:289B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk222:
        call LoadFromThunk
        jmp 0x2519:0x11BE                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk223                                                1B35:28A5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk223:
        call LoadFromThunk
        jmp 0x2519:0xE04                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk224                                                1B35:28AF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk224:
        call LoadFromThunk
        jmp 0x2519:0xC76                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk225                                                1B35:28B9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk225:
        call LoadFromThunk
        jmp 0x2519:0xEDC                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk226                                                1B35:28C3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk226:
        call LoadFromThunk
        jmp 0x2519:0xE2C                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk227                                                1B35:28CD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk227:
        call LoadFromThunk
        jmp 0x2519:0xA62                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk228                                                1B35:28D7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk228:
        call LoadFromThunk
        jmp 0x2519:0x888                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk229                                                1B35:28E1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk229:
        call LoadFromThunk
        jmp 0x2519:0x92A                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk230                                                1B35:28EB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk230:
        call LoadFromThunk
        jmp 0x2519:0x716                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk231                                                1B35:28F5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk231:
        call LoadFromThunk
        jmp 0x2519:0x630                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk232                                                1B35:28FF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk232:
        call LoadFromThunk
        jmp 0x2519:0x4B0                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk233                                                1B35:2909  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk233:
        call LoadFromThunk
        jmp 0x2519:0x35A                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk234                                                1B35:2913  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk234:
        call LoadFromThunk
        jmp 0x2519:0x114                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk235                                                1B35:291D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk235:
        call LoadFromThunk
        jmp 0x2519:0                            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk236                                                1B35:2927  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk236:
        call LoadFromThunk
        jmp 0x2519:0x3A1E                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk237                                                1B35:2931  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk237:
        call LoadFromThunk
        jmp 0x237D:0x23E                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk238                                                1B35:293B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk238:
        call LoadFromThunk
        jmp 0x2C24:0x2E                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk239                                                1B35:2945  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk239:
        call LoadFromThunk
        jmp 0x2C24:2                            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk240                                                1B35:294F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk240:
        call LoadFromThunk
        jmp 0x2E42:0x1B8E                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk241                                                1B35:2959  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk241:
        call LoadFromThunk
        jmp 0x2E42:0x2C30                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk242                                                1B35:2963  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk242:
        call LoadFromThunk
        jmp 0x2C24:0x38                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk243                                                1B35:296D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk243:
        call LoadFromThunk
        jmp 0x226F:0xCE6                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk244                                                1B35:2977  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk244:
        call LoadFromThunk
        jmp 0x1F9C:0x1FC                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk245                                                1B35:2981  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk245:
        call LoadFromThunk
        jmp 0x2137:4                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk246                                                1B35:298B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk246:
        call LoadFromThunk
        jmp 0x24DE:6                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk247                                                1B35:2995  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk247:
        call LoadFromThunk
        jmp 0x256C:4                            ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk248                                                1B35:299F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk248:
        call LoadFromThunk
        jmp 0x237D:0x3A6                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk249                                                1B35:29A9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk249:
        call LoadFromThunk
        jmp 0x2CD2:0xD46                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk250                                                1B35:29B3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk250:
        call LoadFromThunk
        jmp 0x2352:0x174                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk251                                                1B35:29BD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk251:
        call LoadFromThunk
        jmp 0x2083:0x512                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk252                                                1B35:29C7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk252:
        call LoadFromThunk
        jmp 0x2E42:0x2DD6                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk253                                                1B35:29D1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk253:
        call LoadFromThunk
        jmp 0x2352:0x5C                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk254                                                1B35:29DB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk254:
        call LoadFromThunk
        jmp 0x2352:0x1EE                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk255                                                1B35:29E5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk255:
        call LoadFromThunk
        jmp 0x2083:0x248                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk256                                                1B35:29EF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk256:
        call LoadFromThunk
        jmp 0x2E42:0x21E2                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk257                                                1B35:29F9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk257:
        call LoadFromThunk
        jmp 0x252F:0x348                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk258                                                1B35:2A03  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk258:
        call LoadFromThunk
        jmp 0x252F:0xE                          ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk259                                                1B35:2A0D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk259:
        call LoadFromThunk
        jmp 0x1F9C:0x4A0                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk260                                                1B35:2A17  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk260:
        call LoadFromThunk
        jmp 0x2425:0xB20                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk261                                                1B35:2A21  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk261:
        call LoadFromThunk
        jmp 0x317A:0xD92                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk262                                                1B35:2A2B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk262:
        call LoadFromThunk
        jmp 0x317A:0xF22                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk263                                                1B35:2A35  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk263:
        call LoadFromThunk
        jmp 0x317A:0x102                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk264                                                1B35:2A3F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk264:
        call LoadFromThunk
        jmp 0x278C:0x9C8                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk265                                                1B35:2A49  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section GAME.OVL.
;-----------------------------------------------------------------------------
OvlThunk265:
        call LoadFromThunk
        jmp 0x1F54:0x3FA                        ; load paragraph, relocated
        dw 3                                    ; GAME.OVL
;-----------------------------------------------------------------------------
; OvlThunk266                                                1B35:2A53  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk266:
        call LoadFromThunk
        jmp 0x2CD2:0x496                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk267                                                1B35:2A5D  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk267:
        call LoadFromThunk
        jmp 0x2E42:0x2F1E                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk268                                                1B35:2A67  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk268:
        call LoadFromThunk
        jmp 0x2E42:0x2F00                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk269                                                1B35:2A71  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk269:
        call LoadFromThunk
        jmp 0x2137:0x3D6                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk270                                                1B35:2A7B  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk270:
        call LoadFromThunk
        jmp 0x237D:0xF2                         ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk271                                                1B35:2A85  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk271:
        call LoadFromThunk
        jmp 0x237D:0xF6                         ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk272                                                1B35:2A8F  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk272:
        call LoadFromThunk
        jmp 0x2352:0x260                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk273                                                1B35:2A99  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk273:
        call LoadFromThunk
        jmp 0x1FAA:0xE                          ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk274                                                1B35:2AA3  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk274:
        call LoadFromThunk
        jmp 0x2352:0x19C                        ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk275                                                1B35:2AAD  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section INIT.OVL.
;-----------------------------------------------------------------------------
OvlThunk275:
        call LoadFromThunk
        jmp 0x256C:0x12E                        ; load paragraph, relocated
        dw 4                                    ; INIT.OVL
;-----------------------------------------------------------------------------
; OvlThunk276                                                1B35:2AB7  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk276:
        call LoadFromThunk
        jmp 0x2E42:0x2D00                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk277                                                1B35:2AC1  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk277:
        call LoadFromThunk
        jmp 0x2038:0x16                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk278                                                1B35:2ACB  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk278:
        call LoadFromThunk
        jmp 0x2E42:0x15BC                       ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk279                                                1B35:2AD5  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk279:
        call LoadFromThunk
        jmp 0x2E42:0x26                         ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk280                                                1B35:2ADF  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section AI.OVL.
;-----------------------------------------------------------------------------
OvlThunk280:
        call LoadFromThunk
        jmp 0x2038:8                            ; load paragraph, relocated
        dw 5                                    ; AI.OVL
;-----------------------------------------------------------------------------
; OvlThunk281                                                1B35:2AE9  RTLink
; Overlay thunk: near call LoadFromThunk, far jump, section split across the end of
; this file and the RTLink runtime.
;-----------------------------------------------------------------------------
OvlThunk281:
        call LoadFromThunk
        db 0xEA, 0x78, 0x04, 0x52               ; far jump continues in the RTLink runtime
