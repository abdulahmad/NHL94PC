; The announcer's sentence pieces, speech file names and speech buffers.
str_SS:                                         ; string '%s.%s'; used by SayHighlightIntro,
                                                ; SayPlayoffResult, SayScoringPeriod ...
        db '%s.%s', 0x00
str_ByMsc:                                      ; string 'by.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'by.msc', 0x00, 0x00
str_AtMsc:                                      ; string 'at.msc'; used by SayPenalty, OpenPlayByPlaySpeech
        db 'at.msc', 0x00, 0x00
str_AndMsc:                                     ; string 'and.msc'; used by SayPenalty, SayGoal,
                                                ; OpenPlayByPlaySpeech
        db 'and.msc', 0x00
str_FromtheMsc:                                 ; string 'fromthe.msc'; used by SayPlayerFrom
        db 'fromthe.msc', 0x00
str_FromMsc:                                    ; string 'from.msc'; used by SayPlayerFrom
        db 'from.msc', 0x00, 0x00
str_MinuteMsc:                                  ; string 'minute.msc'; used by SayPenalty
        db 'minute.msc', 0x00, 0x00
str_MinutesMsc:                                 ; string 'minutes.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'minutes.msc', 0x00
str_SecondMsc:                                  ; string 'second.msc'; used by SayPenalty
        db 'second.msc', 0x00, 0x00
str_SecondsMsc:                                 ; string 'seconds.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'seconds.msc', 0x00
str_PenaltyMsc:                                 ; string 'penalty.msc'; used by SayPenalty,
                                                ; OpenPlayByPlaySpeech
        db 'penalty.msc', 0x00
str_GoalsMsc:                                   ; string 'goals.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'goals.msc', 0x00
str_AssistedMsc:                                ; string 'assisted.msc'; used by SayGoal, OpenPlayByPlaySpeech
        db 'assisted.msc', 0x00, 0x00
str_OneminMsc:                                  ; string 'onemin.msc'; used by SayOneMinuteLeft,
                                                ; OpenPlayByPlaySpeech
        db 'onemin.msc', 0x00, 0x00
str_2minsOff:                                   ; string '2mins.off'; used by OpenPlayByPlaySpeech
        db '2mins.off', 0x00
str_NumberMsc:                                  ; string 'number.msc'; used by SayPenalty, SayPlayerFrom,
                                                ; SayGoal ...
        db 'number.msc', 0x00, 0x00
        db 'easports.int', 0x00, 0x00
        db 'nhl.int', 0x00
        db 'of.bar', 0x00, 0x00
str_NumberBar:                                  ; string 'number.bar'; used by SayPlayoffTonight
        db 'number.bar', 0x00, 0x00
str_DivisionBar:                                ; string 'division.bar'; used by SayPlayoffResult,
                                                ; SayPlayoffTonight
        db 'division.bar', 0x00, 0x00
str_ConfBar:                                    ; string 'conf.bar'; used by SayPlayoffResult,
                                                ; SayPlayoffTonight
        db 'conf.bar', 0x00, 0x00
str_FinalBar:                                   ; string 'final.bar'; used by SayPlayoffResult,
                                                ; SayPlayoffTonight
        db 'final.bar', 0x00
str_SemiBar:                                    ; string 'semi.bar'; used by SayPlayoffResult,
                                                ; SayPlayoffTonight
str_SemiBar_2:                                  ; string 'semi.bar'; used by AI
        db 'semi.bar', 0x00, 0x00
str_AndBar:                                     ; string 'and.bar'; used by SayHighlightIntro,
                                                ; SayTonightIntro, SayPlayoffTonight
        db 'and.bar', 0x00
str_BetweenBar:                                 ; string 'between.bar'; used by SayPlayoffTonight
        db 'between.bar', 0x00
str_GamenumBar:                                 ; string 'gamenum.bar'; used by SayPlayoffResult,
                                                ; SayPlayoffTonight
        db 'gamenum.bar', 0x00
str_EasportsBar:                                ; string 'easports.bar'; used by SayTonightIntro,
                                                ; SayPlayoffTonight
        db 'easports.bar', 0x00, 0x00
str_PeriodBar:                                  ; string 'period.bar'; used by SayScoringPeriod
        db 'period.bar', 0x00, 0x00
str_TonightBar:                                 ; string 'tonight.bar'; used by SayTonightIntro,
                                                ; SayPlayoffTonight
        db 'tonight.bar', 0x00
str_GamebtwnBar:                                ; string 'gamebtwn.bar'; used by SayHighlightIntro,
                                                ; SayTonightIntro
        db 'gamebtwn.bar', 0x00, 0x00
        db 'presents.int', 0x00, 0x00
        db 'hockey.int', 0x00, 0x00
str_ImrbarrInt:                                 ; string 'imrbarr.int'; used by SayGoodnight
        db 'imrbarr.int', 0x00
str_GoodniteInt:                                ; string 'goodnite.int'; used by SayGoodnight
        db 'goodnite.int', 0x00, 0x00
str_LineupsInt:                                 ; string 'lineups.int'; used by SayLineups
        db 'lineups.int', 0x00
        db 'elsewher.int', 0x00, 0x00
        db 'tonight.int', 0x00
str_TakeynowBar:                                ; string 'takeynow.bar'; used by SayHighlightIntro
        db 'takeynow.bar', 0x00, 0x00
str_HighliteBar:                                ; string 'highlite.bar'; used by SayHighlightIntro
        db 'highlite.bar', 0x00, 0x00
str_OvertimeBar:                                ; string 'overtime.bar'; used by SayPlayoffResult
        db 'overtime.bar', 0x00, 0x00
str_HavewonBar:                                 ; string 'havewon.bar'; used by SayPlayoffResult
        db 'havewon.bar', 0x00
str_ScoringBar:                                 ; string 'scoring.bar'; used by SayScoringPeriod
        db 'scoring.bar', 0x00
str_ThegameBar:                                 ; string 'thegame.bar'; used by SayScoringPeriod
        db 'thegame.bar', 0x00
str_OtBar:                                      ; string 'ot.bar'; used by SayScoringPeriod
        db 'ot.bar', 0x00, 0x00
str_TheotBar:                                   ; string 'theot.bar'; used by SayScoringPeriod
        db 'theot.bar', 0x00
str_TonightMsc:                                 ; string 'tonight.msc'; used by SayPlayerFrom
        db 'tonight.msc', 0x00
SpeechTickCount:                                ; speech timer ticks; used by SpeechTimerTick, SpeechInit
        dw 0x0000
SpeechSampleBusy:                               ; a sample is playing; used by SpeechTimerTick, SpeechInit,
                                                ; ShutdownSpeech ...
        db 0x00, 0x00
SpeechMemOff:                                   ; speech memory block, offset; used by SpeechInit,
                                                ; MoveMemBlock
        dw 0x0000
SpeechMemSeg:                                   ; speech memory block, segment; used by SpeechInit,
                                                ; MoveMemBlock
        dw 0x0000
SpeechOn:                                       ; speech system initialised; used by SpeechTimerTick,
                                                ; SpeechInit, ShutdownSpeech ...
        dw 0x0000
str_Speechbuf:                                  ; string 'speechbuf'; used by InitSpeechSlots
        db 'speechbuf', 0x00
str_Sentence:                                   ; string 'sentence'; used by SpeechInit
        db 'sentence', 0x00
str_SpeechBank:                                 ; string 'speech bank'; used by SpeechInit
        db 'speech bank', 0x00
str_SampleMemMan:                               ; string 'sample mem man'; used by SpeechInit
        db 'sample mem man', 0x00
str_Pause:                                      ; string 'pause'; used by MakePauseSample
        db 'pause', 0x00
str_Off:                                        ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_2minsS:                                     ; string '2mins.%s'; used by GameLengthSampleName
        db '2mins.%s', 0x00
str_Off_2:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_5minsS:                                     ; string '5mins.%s'; used by GameLengthSampleName
        db '5mins.%s', 0x00
str_Off_3:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_10minsS:                                    ; string '10mins.%s'; used by GameLengthSampleName
        db '10mins.%s', 0x00
str_Off_4:                                      ; string 'off'; used by GameLengthSampleName
        db 'off', 0x00
str_GamemisS:                                   ; string 'gamemis.%s'; used by GameLengthSampleName
        db 'gamemis.%s', 0x00
str_SmytheBar:                                  ; string 'smythe.bar'; used by DivisionSampleName
        db 'smythe.bar', 0x00
str_NorrisBar:                                  ; string 'norris.bar'; used by DivisionSampleName
        db 'norris.bar', 0x00
str_AdamsBar:                                   ; string 'adams.bar'; used by DivisionSampleName
        db 'adams.bar', 0x00
str_PatrickBar:                                 ; string 'patrick.bar'; used by DivisionSampleName
        db 'patrick.bar', 0x00
str_CampbellBar:                                ; string 'campbell.bar'; used by DivisionSampleName
        db 'campbell.bar', 0x00
str_WalesBar:                                   ; string 'wales.bar'; used by DivisionSampleName
        db 'wales.bar', 0x00
str_StanleyBar:                                 ; string 'stanley.bar'; used by DivisionSampleName
        db 'stanley.bar', 0x00
str_EaNhlInt:                                   ; string 'ea_nhl.int'; used by SayNhlIntro
        db 'ea_nhl.int', 0x00
str_EaNhlInt_2:                                 ; string 'ea_nhl.int'; used by SayNhlIntro
str_EaNhlInt_3:                                 ; string 'ea_nhl.int'; used by AI
        db 'ea_nhl.int', 0x00
str_ElsenhlInt:                                 ; string 'elsenhl.int'; used by SayElseNhl
        db 'elsenhl.int', 0x00
str_ElsenhlInt_2:                               ; string 'elsenhl.int'; used by SayElseNhl
        db 'elsenhl.int', 0x00
str_Rnk:                                        ; string 'rnk'; used by SayHighlightIntro
        db 'rnk', 0x00
str_Awa:                                        ; string 'awa'; used by SayHighlightIntro
        db 'awa', 0x00
str_Hom:                                        ; string 'hom'; used by SayHighlightIntro
        db 'hom', 0x00
str_Awa_2:                                      ; string 'awa'; used by SayPlayoffResult
        db 'awa', 0x00
str_Bar:                                        ; string 'bar'; used by SayPlayoffResult
        db 'bar', 0x00
str_Bar_2:                                      ; string 'bar'; used by SayScoringPeriod
        db 'bar', 0x00
str_Rnk_2:                                      ; string 'rnk'; used by SayTonightIntro
        db 'rnk', 0x00
str_Awa_3:                                      ; string 'awa'; used by SayTonightIntro
        db 'awa', 0x00
str_Hom_2:                                      ; string 'hom'; used by SayTonightIntro
        db 'hom', 0x00
str_Rnk_3:                                      ; string 'rnk'; used by SayPlayoffTonight
        db 'rnk', 0x00
str_Awa_4:                                      ; string 'awa'; used by SayPlayoffTonight
        db 'awa', 0x00
str_Hom_3:                                      ; string 'hom'; used by SayPlayoffTonight
        db 'hom', 0x00
str_Bar_3:                                      ; string 'bar'; used by SayPlayoffTonight
        db 'bar', 0x00
str_Cty:                                        ; string 'cty'; used by SayPenalty
        db 'cty', 0x00
str_Bru:                                        ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_2:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Off_5:                                      ; string 'off'; used by SayPenalty
        db 'off', 0x00
str_Bru_3:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_4:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_5:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Bru_6:                                      ; string 'bru'; used by SayPenalty
        db 'bru', 0x00
str_Cty_2:                                      ; string 'cty'; used by SayPlayerFrom
        db 'cty', 0x00
str_Msc:                                        ; string 'msc'; used by SayPlayerFrom
        db 'msc', 0x00
str_Bru_7:                                      ; string 'bru'; used by SayPlayerFrom
        db 'bru', 0x00
str_Bru_8:                                      ; string 'bru'; used by SayPlayerFrom
        db 'bru', 0x00
str_Cty_3:                                      ; string 'cty'; used by SayGoal
        db 'cty', 0x00
str_Bru_9:                                      ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_10:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_11:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_12:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_13:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Bru_14:                                     ; string 'bru'; used by SayGoal
        db 'bru', 0x00
str_Xrbarr2Viv:                                 ; string 'xrbarr2.viv'; used by OpenStudioSpeech
        db 'xrbarr2.viv', 0x00
str_Xbruce2Viv:                                 ; string 'xbruce2.viv'; used by OpenPlayByPlaySpeech
        db 'xbruce2.viv', 0x00
str_Cty_4:                                      ; string 'cty'; used by OpenPlayByPlaySpeech
        db 'cty', 0x00
str_Cty_5:                                      ; string 'cty'; used by OpenPlayByPlaySpeech
        db 'cty', 0x00
