;	Segment build for lib/msc_runtime.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
NullStartup4		equ	0x4
NullStartup6		equ	0x6
_main		equ	0x8
CurPage		equ	0x74DC
TopOfStack		equ	0x8516
ExitRoutine		equ	0x8518
DgroupTop		equ	0x851A
OldInt0Vec		equ	0x8542
OldInt0VecSeg		equ	0x8544
__psp		equ	0x8556
DosMajor		equ	0x8558
_osfile		equ	0x855F
ArgCount		equ	0x8573
ArgVector		equ	0x8575
EnvVector		equ	0x8577
MathVecSet		equ	0x8580
MathVecNum		equ	0x8581
MathVecOld		equ	0x8582
StackOverflowFn		equ	0x8586
StackLimit		equ	0x858A
AtexitPtr		equ	0x8694
RandSeed		equ	0x8696
RandSeedHigh		equ	0x8698
MsgBannerHook		equ	0x86B2
MsgBannerHookSeg		equ	0x86B4
LastStream		equ	0x880A
CflushCount		equ	0x8871
FltCvtFn		equ	0x8876
CropZerosFn		equ	0x887A
ForceDecPtFn		equ	0x8882
PositiveFn		equ	0x888A
FloatMode		equ	0x8A1C
FloatPrecision		equ	0x8A1E
FloatFlag		equ	0x8A20
FpStatusByte		equ	0x8ABA
InitHook		equ	0x8AE2
DebugSignature		equ	0x8AE4
DebugWriteHook		equ	0x8AE6
DebugExitHook		equ	0x8AE8
DebugTermHook		equ	0x8AEA
FpHook		equ	0x8AF4
FpHookCount		equ	0x8AF6
FpEnvArg1		equ	0x8AF8
FpEnvArg2		equ	0x8AFC
StrBufPtr		equ	0x9096
StrBufCnt		equ	0x9098
StrBufBase		equ	0x909A
StrBufFlag		equ	0x909C
FloatArgPtr		equ	0x909E
FltOutFlags		equ	0x90A8
FltOutFlags1		equ	0x90A9
FltOutExp		equ	0x90AA
%include "lib/msc_runtime.asm"
