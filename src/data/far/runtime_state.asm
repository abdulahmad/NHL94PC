; Far data, paragraph 3996h, 368 bytes: the floating-point emulator's data. fp_emulator.asm loads DS from
; EmuDataSeg on every entry, so its bare operands are offsets here.
FpErrHandler:                                   ; dword; far error handler set by FpSetHandler (0 = none)
        dd 0
Fp87Present:                                    ; byte; 1 when a real 8087 does the work
        db 0
        db 0
FpUserCw:                                       ; word; the control word as the program set it
        dw 0
FpUserStatus:                                   ; word; exception flags gathered for FpGetStatus
        dw 0
FpEmuCw:                                        ; word; the control word the emulator works with
        dw 0
FpEmuStatus:                                    ; word; the emulated status word (high byte: C3-C0)
        dw 0
FpStackBase:                                    ; word; FpStackTop when the emulated stack is empty
        dw FpStack
FpStackTop:                                     ; word; the emulated ST, 12-byte registers growing upward
        dw 0
FpStackLimit:                                   ; word; FpStackTop when all 14 registers are in use
        dw FpStack + 14 * 12
FpMachineMode:                                  ; word; 0 under DOS (real mode); other modes go through the
                                                ; OS/2 style calls
        dw 0
FpOpStatus:                                     ; word; exceptions raised by the current instruction, also
                                                ; the 8087's status word after fnstsw
        dw 0
        dw 0
FpTemp:                                         ; dword; scratch control word and fistp result
        dd 0
FpSavedVectors:                                 ; dword; INT 34h-3Eh as they were before FpHookVectors
        times 11 dd 0
FpTemp0:                                        ; 12-byte scratch register (also a temp real for fstp)
        times 12 db 0
FpSavedSs:                                      ; word; SS when FpInit ran
        dw 0
FpProbeWord:                                    ; word; FpInit's 8087 detection scratch word
        dw 0
FpTemp1:                                        ; 12-byte scratch register for the series routines
        times 12 db 0
FpTemp2:                                        ; 12-byte scratch register for the series routines
        times 12 db 0
FpTemp3:                                        ; 12-byte scratch register for the series routines
        times 12 db 0
FpTemp4:                                        ; 12-byte scratch register for the series routines
        times 12 db 0
FpTemp5:                                        ; 12-byte scratch register for the series routines
        times 12 db 0
FpResultPtr:                                    ; word; the register an arithmetic routine writes
        dw 0
FpDivisor:                                      ; 8-byte mantissa of the divisor in FpDivMantissa
        times 8 db 0
FpRemExp:                                       ; word; fprem's exponent difference still to reduce
        dw 0
FpRemFlag:                                      ; word; 1 when fprem stopped before it finished
        dw 0
FpSignalMode:                                   ; word; set by FpSetMode; 0 makes FpException treat
                                                ; invalid operations as already handled
        dw 1
FpNextByte:                                     ; byte; the opcode byte after the emulated instruction
        db 0
FpExitVector:                                   ; word; FpEmuChain, or FpEmuChainEsc in other modes
        dw 0
FpStack:                                        ; the emulated register stack: 14 registers of 12 bytes
        times 14 * 12 db 0
        times 31 db 0
