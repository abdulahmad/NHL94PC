; The C run-time's data.
TopOfStack:                                     ; stack pointer at startup; used by MscStartup
        dw 0x0000
ExitRoutine:                                    ; near routine errors leave through (_exit); used by __cintDIV
        dw 0x068E
DgroupTop:                                      ; top offset of DGROUP; used by MscStartup
        db 0x00, 0x00
NearHeapDesc:                                   ; near heap descriptor (segment, flags, start, rover, end);
                                                ; used by MscStartup, _nmalloc, _nfree
        db 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_CFileInfo:                                  ; string '_C_FILE_INFO='; used by InitRuntime
        db '_C_FILE_INFO=', 0x00
OldInt0Vec:                                     ; saved INT 0 vector; used by InitRuntime, ExitRestore
        dw 0x0000
OldInt0VecSeg:                                  ; saved INT 0 vector, segment; used by InitRuntime
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
errno:                                          ; dosMapErr stores the translated C error here; used by
                                                ; DosMapErr, WriteStderr, _dos_getdiskfree
        db 0x00, 0x00
_umaskval:                                      ; file permission mask applied by open; used by the open
                                                ; routine
        db 0x00, 0x00, 0x00, 0x00
__psp:                                          ; startup stores the incoming DS (the PSP) here and later
                                                ; reads the environment segment from it; used by MscStartup,
                                                ; InitRuntime, HeapGrow
        dw 0x0000
DosMajor:                                       ; DOS major version; used by _sopen, DosMapErr
        db 0x00, 0x00, 0x00
_doserrno:                                      ; dosMapErr stores the raw DOS error here; used by DosMapErr
        db 0x00, 0x00
_nfile:                                         ; highest C handle
        dw 0x0014
_osfile:                                        ; _C_FILE_INFO nibbles are stored here and the IOCTL loop sets
                                                ; the device bit on handles 0 to 4; used by InitRuntime
        db 0x81, 0x81, 0x81, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
ArgCount:                                       ; argc; used by MscStartup
        dw 0x0000
ArgVector:                                      ; argv; used by MscStartup
        dw 0x0000
EnvVector:                                      ; environ; used by MscStartup
        db 0x00, 0x00, 0x7D, 0x85, 0xC9, 0x45, 0x00, 0x00, 0x00
MathVecSet:                                     ; a math error vector was installed; used by ExitRestore
        db 0x00
MathVecNum:                                     ; its interrupt number; used by ExitRestore
        db 0x00
MathVecOld:                                     ; its saved vector; used by ExitRestore
        db 0x00, 0x00, 0x00, 0x00
StackOverflowFn:                                ; alternate stack-overflow handler (FFFFh for none); used by
                                                ; __chkstk
        dd 0xFFFFFFFF
StackLimit:                                     ; lowest allowed stack pointer; used by __chkstk, _stackavail
        dw StackBottom + 0x100
        db 0x00
CharTypes:                                      ; character type table (bit 4: digit); used by
                                                ; NumberEntryDialog
        db '         (((((                  H', 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x10, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
        db 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x10, 0x10, 0x10, 0x10, 0x10
        db 0x10, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
        db 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x10, 0x10, 0x10, 0x10, 0x20
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00
str_ColonSpace:                                 ; string ': ', written by perror after the caller's text
        db ': ', 0x00
str_Newline:                                    ; string of one line feed, written by perror after the message
        db 0x0A, 0x00, 0x00
AtexitPtr:                                      ; next free atexit slot; used by atexit
        dw 0x90B8
RandSeed:                                       ; rand seed, low word; used by _srand, _rand
        dw 0x0001
RandSeedHigh:                                   ; rand seed, high word; used by _srand, _rand
        db 0x00, 0x00
FltCvtInit:                                     ; twelve words copied over FltCvtFn when floating point is
                                                ; linked in (near pointers of the float format helpers)
        dw FormatExp, 0x0000
        dw ScanPoint, 0x0000
        dw FormatFloat, 0x0000
        dw ScanFloat, 0x0000
        dw FloatLoad, 0x0000
        dw FormatExp2, 0x0000
MsgBannerHook:                                  ; far routine called before a runtime message; used by
                                                ; __FF_MSGBANNER
        db 0x00, 0x00
MsgBannerHookSeg:                               ; its segment; used by __FF_MSGBANNER
        db 0x00, 0x00
DosErrnoTable:                                  ; errno value for each DOS error code 0 to 13h; used by
                                                ; DosMapErr
        db 0x00, 0x16, 0x02, 0x02, 0x18, 0x0D, 0x09, 0x0C, 0x0C, 0x0C, 0x07, 0x08, 0x16, 0x16, 0xFF, 0x02
        db 0x0D, 0x12, 0x02, 0xFF
_iob:                                           ; stream table (8 bytes each: ptr, count, base, flag, file),
                                                ; stdin first; used by FlushAll
        dw StdinBuf, 0x0000, StdinBuf
        db 0x01, 0x00
_iob_stdout:                                    ; stdout entry of _iob; used by printf, _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01
_iob_stderr:                                    ; stderr entry of _iob; used by _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84, 0x03
_iob_stdprn:                                    ; stdprn entry of _iob; used by _flsbuf, _stbuf
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
StreamExtra:                                    ; extra stream records for the standard buffers; used by the
                                                ; EXE
        db 0x01, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        times 144 db 0
LastStream:                                     ; last stream record; used by FlushAll
        db 0x62, 0x87
StdoutBuf:                                      ; buffer pointer _stbuf gives stdout
        db 0x00, 0x00
StderrBuf:                                      ; buffer pointer _stbuf gives stderr
        db 0x00, 0x00
StdprnBuf:                                      ; buffer pointer _stbuf gives stdprn
        db 0x00, 0x00
OutputClassTable:                               ; _output state table: class of each format character from 20h
                                                ; to 78h, packed with the next state
        db 0x06, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x10, 0x00, 0x03, 0x06, 0x00, 0x06, 0x02, 0x10
        db 0x04, 'EEE', 0x05, 0x05, 0x05, 0x05, 0x05, 0x35, 0x30, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00
        db '  0PX', 0x07, 0x08, 0x00, '000WP', 0x07, 0x00, 0x00, '  ', 0x00, 0x00, 0x00, 0x00, 0x00, 0x08
        db '``````', 0x00, 0x00, 'ppxxxx', 0x08, 0x07, 0x08, 0x00, 0x00, 0x07, 0x00, 0x08, 0x08, 0x08, 0x00, 0x00
        db 0x08, 0x00, 0x08, 0x00, 0x00, 0x08
str_Null:                                       ; string '(null)', printed by _output for a null %s pointer
        db '(null)'
NullStrLen:                                     ; length of str_Null (6); used by _output
        db 0x06, 0x00, 0x00
_fmode:                                         ; default file mode; bit 15 (O_BINARY) makes open binary; used
                                                ; by the open routine
        db 0x00, 0x00
FltCvtFn:                                       ; float conversion routine; used by _output
        dd 0x0000162E
CropZerosFn:                                    ; drops trailing zeros; used by _output
        db 0x2E, 0x16, 0x00, 0x00
        db 0x2E, 0x16, 0x00, 0x00
ForceDecPtFn:                                   ; forces a decimal point; used by _output
        db 0x2E, 0x16, 0x00, 0x00
        db 0x2E, 0x16, 0x00, 0x00
PositiveFn:                                     ; checks the sign; used by _output
        db 0x2E, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
str_ErrNone:                                    ; message for errno 0: 'Error 0'
        db 'Error 0', 0x00
str_ErrBlank1:                                  ; empty message for errno 1
        db 0x00
str_ENOENT:                                     ; message for errno 2: 'No such file or directory'
        db 'No such file or directory', 0x00
str_ErrBlank3:                                  ; empty message for errno 3
        db 0x00
str_ErrBlank4:                                  ; empty message for errno 4
        db 0x00
str_ErrBlank5:                                  ; empty message for errno 5
        db 0x00
str_ErrBlank6:                                  ; empty message for errno 6
        db 0x00
str_E2BIG:                                      ; message for errno 7: 'Arg list too long'
        db 'Arg list too long', 0x00
str_ENOEXEC:                                    ; message for errno 8: 'Exec format error'
        db 'Exec format error', 0x00
str_EBADF:                                      ; message for errno 9: 'Bad file number'
        db 'Bad file number', 0x00
str_ErrBlank10:                                 ; empty message for errno 10
        db 0x00
str_ErrBlank11:                                 ; empty message for errno 11
        db 0x00
str_ENOMEM:                                     ; message for errno 12: 'Not enough core'
        db 'Not enough core', 0x00
str_EACCES:                                     ; message for errno 13: 'Permission denied'
        db 'Permission denied', 0x00
str_ErrBlank14:                                 ; empty message for errno 14
        db 0x00
str_ErrBlank15:                                 ; empty message for errno 15
        db 0x00
str_ErrBlank16:                                 ; empty message for errno 16
        db 0x00
str_EEXIST:                                     ; message for errno 17: 'File exists'
        db 'File exists', 0x00
str_EXDEV:                                      ; message for errno 18: 'Cross-device link'
        db 'Cross-device link', 0x00
str_ErrBlank19:                                 ; empty message for errno 19
        db 0x00
str_ErrBlank20:                                 ; empty message for errno 20
        db 0x00
str_ErrBlank21:                                 ; empty message for errno 21
        db 0x00
str_EINVAL:                                     ; message for errno 22: 'Invalid argument'
        db 'Invalid argument', 0x00
str_ErrBlank23:                                 ; empty message for errno 23
        db 0x00
str_EMFILE:                                     ; message for errno 24: 'Too many open files'
        db 'Too many open files', 0x00
str_ErrBlank25:                                 ; empty message for errno 25
        db 0x00
str_ErrBlank26:                                 ; empty message for errno 26
        db 0x00
str_ErrBlank27:                                 ; empty message for errno 27
        db 0x00
str_ENOSPC:                                     ; message for errno 28: 'No space left on device'
        db 'No space left on device', 0x00
str_ErrBlank29:                                 ; empty message for errno 29
        db 0x00
str_ErrBlank30:                                 ; empty message for errno 30
        db 0x00
str_ErrBlank31:                                 ; empty message for errno 31
        db 0x00
str_ErrBlank32:                                 ; empty message for errno 32
        db 0x00
str_EDOM:                                       ; message for errno 33: 'Math argument'
        db 'Math argument', 0x00
str_ERANGE:                                     ; message for errno 34: 'Result too large'
        db 'Result too large', 0x00
str_ErrBlank35:                                 ; empty message for errno 35
        db 0x00
str_EDEADLOCK:                                  ; message for errno 36: 'Resource deadlock would occur'
        db 'Resource deadlock would occur', 0x00
str_ErrUnknown:                                 ; message for errno 37: 'Unknown error'
        db 'Unknown error', 0x00
SysErrList:                                     ; sys_errlist: near pointers to the messages for errno 0 to
                                                ; 37; used by perror
        dw str_ErrNone
        dw str_ErrBlank1
        dw str_ENOENT
        dw str_ErrBlank3
        dw str_ErrBlank4
        dw str_ErrBlank5
        dw str_ErrBlank6
        dw str_E2BIG
        dw str_ENOEXEC
        dw str_EBADF
        dw str_ErrBlank10
        dw str_ErrBlank11
        dw str_ENOMEM
        dw str_EACCES
        dw str_ErrBlank14
        dw str_ErrBlank15
        dw str_ErrBlank16
        dw str_EEXIST
        dw str_EXDEV
        dw str_ErrBlank19
        dw str_ErrBlank20
        dw str_ErrBlank21
        dw str_EINVAL
        dw str_ErrBlank23
        dw str_EMFILE
        dw str_ErrBlank25
        dw str_ErrBlank26
        dw str_ErrBlank27
        dw str_ENOSPC
        dw str_ErrBlank29
        dw str_ErrBlank30
        dw str_ErrBlank31
        dw str_ErrBlank32
        dw str_EDOM
        dw str_ERANGE
        dw str_ErrBlank35
        dw str_EDEADLOCK
        dw str_ErrUnknown
SysNerr:                                        ; sys_nerr: number of messages in SysErrList (25h); used by
                                                ; perror
        db 0x25, 0x00
str_E000:                                       ; string 'e+000'; used by FloatBuf
        db 'e+000', 0x00
FloatMode:                                      ; float format mode; used by FloatBuf, FloatToStr, FloatWidth
                                                ; ...
        db 0x00, 0x00
FloatPrecision:                                 ; float precision; used by FloatWidth, FormatOne
        dw 0x0000
FloatFlag:                                      ; float format flag; used by FormatOne
        db 0x00, 0x00
FpErrDigits:                                    ; two ASCII digits per floating-point error code, '01' to
                                                ; '12'; used by FpError
        db '010203040506070809101112'
FpErrMsg:                                       ; counted string 'M61xx', the xx filled from FpErrDigits; used
                                                ; by FpError
        db 0x05, 'M61xx'
FpErrCode:                                      ; floating-point error code; used by FpError
        db 0x00, 0x00, 0x00, 0x00
str_SNAN:                                       ; counted string '1#SNAN' for printf
        db 0x06, '1#SNAN'
str_QNAN:                                       ; counted string '1#QNAN' for printf
        db 0x06, '1#QNAN'
str_INF:                                        ; counted string '1#INF' for printf
        db 0x05, '1#INF'
str_IND:                                        ; counted string '1#IND' for printf
        db 0x05, '1#IND'
FltResult:                                      ; conversion result block of HexConvert (sign, exponent, flag,
                                                ; digit pointer)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
FltValue:                                       ; copy of the double HexConvert converts
        db 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
FltDigits:                                      ; digit buffer of HexConvert
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        db 0x00, 0x00, 0x00, 0x00
CvtWork:                                        ; ten-byte work value of DoubleToDigits
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
CvtDigitCount:                                  ; digit count (or fixed-string flag) DoubleToDigits returns
        db 0x00
CvtDigits:                                      ; sixteen digits DoubleToDigits writes
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
str_CvtSNAN:                                    ; counted string '1#SNAN' DoubleToDigits returns for a
                                                ; signalling NaN
        db 0x06, '1#SNAN'
str_CvtQNAN:                                    ; counted string '1#QNAN' DoubleToDigits returns for a quiet
                                                ; NaN
        db 0x06, '1#QNAN'
str_CvtINF:                                     ; counted string '1#INF' DoubleToDigits returns for infinity
        db 0x05, '1#INF'
str_CvtIND:                                     ; counted string '1#IND' DoubleToDigits returns for indefinite
        db 0x05, '1#IND'
FpStatusWord:                                   ; coprocessor status word DoubleToDigits stores (FpStatusByte
                                                ; is its high byte)
        db 0x00
FpStatusByte:                                   ; floating-point status byte; used by _nmalloc
        db 0x00
FpSavedCw:                                      ; coprocessor control word saved by DoubleToDigits
        db 0x00, 0x00
FpRoundCw:                                      ; control word 1332h (round to nearest, 64-bit precision);
                                                ; DoubleToDigits copies the mask bits of FpSavedCw into its
                                                ; low byte
        db 0x32, 0x13, 0x00, 0x80, 0x66, 0x24, 0x00, 0x80, 0xE0, 0x37, 0x79, 0xC3, 0x41, 0x43, 0x00
AllocBlockSize:                                 ; near heap growth size in bytes (2000h), read by the heap
                                                ; allocator
        db 0x00, 0x20, 0x00, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0x43, 0xFF, 0xFF, 0xFF, 0xFF
        db 0xFF, 0xFF, 0xEF, 0x7F, 0x00, 0x00
InitHook:                                       ; near startup hook (0 skips); used by MscStartup
        dw 0x0000
DebugSignature:                                 ; D6D6h when a debugger hook is present; used by __cintDIV,
                                                ; __cexit, _read ...
        dw 0x0000
DebugWriteHook:                                 ; debugger write hook; used by _read, _write, _dos_write ...
        dw 0x058C
DebugExitHook:                                  ; debugger exit hook; used by __cintDIV
        dw 0x058C
DebugTermHook:                                  ; debugger termination hook; used by __cexit
        db 0x8C, 0x05, 0x00
        dw SortPairsTail, 0x1500
        db 0x34, 0x00, 0x00
FpHook:                                         ; floating-point hook; used by InitRuntime, ExitRestore
        dw FpMath
FpHookSeg:                                      ; segment of FpHook (the emulator), 0 when floating point is
                                                ; not linked in (the hooks are skipped); used by InitRuntime,
                                                ; ExitRestore
        dw 0x18B9
FpEnvArg1:                                      ; first floating-point hook argument; used by InitRuntime
        dw FpStack + 0xC0, 0x3996
FpEnvArg2:                                      ; second floating-point hook argument; used by InitRuntime
        dw FpError, 0x0000
InitTable:                                      ; C initializer table (one far pointer), run by InitRuntime
        dw CopyTemplate, 0x0000
PreTermTable:                                   ; C pre-terminator table (one far pointer), run by ExitCommon
        dw _flushall, 0x0000
TermTable:                                      ; C terminator table (empty: it ends where it starts); run by
                                                ; ExitCommon
