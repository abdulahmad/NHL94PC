;	Segment build for data/far/team_choice_text.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
str_StatisticsType		equ	0x4E8
str_Standings_3		equ	0x4FA
str_TeamsSortedBy		equ	0x508
str_PlayersSortedBy		equ	0x51A
str_GoaliesSortedBy		equ	0x52E
str_StatisticsType_9		equ	0x722
str_ReturnTo		equ	0x8F6
TradeShowStatsThunk		equ	0x2021
MenuP2ControlsExhThunk		equ	0x21B1
MenuP1ControlsExhThunk		equ	0x21BB
MenuReturnToLineEditorThunk		equ	0x2369
DrawLeagueSetDlgSelThunk		equ	0x253F
MenuShowLeagueSettingsThunk		equ	0x2549
MenuShowLeagueSettings2Thunk		equ	0x2553
TradeCancelThunk		equ	0x264D
TradeDoneThunk		equ	0x2657
TeamSelCancelThunk		equ	0x2661
TeamSelDoneThunk		equ	0x266B
CalReturnThunk		equ	0x2675
CalStandingsMenuThunk		equ	0x267F
%include "data/far/team_choice_text.asm"
