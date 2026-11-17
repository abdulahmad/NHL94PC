;	Segment build for data/far/season_titles.asm: sets its origin and the outside labels it uses (their values in the
;	full build; written by tools/make_stubs.py), then includes the file on its own (tools/verify_segment.py).
	bits	16
	org	0x0
OverlayThunks		equ	0x1FEF
StatsSelLeaguePlayoffsThunk		equ	0x1FF9
StatsSelPlayoffModeThunk		equ	0x2003
StatsSelNhlPlayoffsThunk		equ	0x26C5
StatsSelNhlSeasonThunk		equ	0x26CF
%include "data/far/season_titles.asm"
