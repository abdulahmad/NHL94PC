; The sound set-up: song and effect banks, driver and file names, and the sound device table.
SongBuf1:                                       ; far pointer (offset) to a song buffer loaded by
                                                ; SetSoundDevice; used by MENUS
        db 0x00, 0x00
SongBuf1Seg:                                    ; its segment; used by MENUS
        db 0x00, 0x00
SongBuf2:                                       ; far pointer (offset) to the second song buffer; used by
                                                ; MENUS
        db 0x00, 0x00
SongBuf2Seg:                                    ; its segment; used by MENUS
        db 0x00, 0x00
SongBuf3:                                       ; far pointer (offset) to the third song buffer; used by MENUS
        db 0x00
        db 0x00
SongBufs:                                       ; further song buffer pointer; used by MENUS
        times 2 db 0
SongSlots:                                      ; far pointers of the 16 loaded songs; sound_config unloads
                                                ; each
        times 64 db 0
SfxBankOff:                                     ; effects bank, offset; used by PlaySoundEffect
        dw 0x0000
SfxBankSeg:                                     ; effects bank, segment; used by PlaySoundEffect
        dw 0x0000
SfxBank2Off:                                    ; second effects bank, offset; used by PlaySoundEffect
        dw 0x0000
SfxBank2Seg:                                    ; second effects bank, segment; used by PlaySoundEffect
        db 0x00, 0x00
SoundDriverLoaded:                              ; -1 once SetSoundDevice has loaded a driver, else 0; used by
                                                ; MENUS
        db 0x00, 0x00
str_30Bgp:                                      ; string '30.BGP'; used by MENUS
        db '30.BGP', 0x00, 0x00
str_Scn:                                        ; string '.SCN'; used by MENUS
        db '.SCN', 0x00, 0x00
str_Pat:                                        ; string '.PAT'; used by MENUS
        db '.PAT', 0x00, 0x00
str_Tim:                                        ; string '.TIM'; used by MENUS
        db '.TIM', 0x00, 0x00
str_Pcff03d:                                    ; string 'PCFF%03d'; used by MENUS
        db 'PCFF%03d', 0x00, 0x00
        db 'PC', 0x00, 0x00
str_Pcbeep_2:                                   ; string 'PCBEEP'; used by MENUS
        db 'PCBEEP', 0x00, 0x00
        db 'SB', 0x00, 0x00
str_Sbdac:                                      ; string 'SBDAC'; used by MENUS
        db 'SBDAC', 0x00
        db 'YM', 0x00, 0x00
str_Adlib:                                      ; string 'ADLIB'; used by MENUS
        db 'ADLIB', 0x00
        db 'MT', 0x00, 0x00
str_Mt32:                                       ; string 'MT32'; used by MENUS
        db 'MT32', 0x00, 0x00
        db 'NL', 0x00, 0x00
str_Pcbeep:                                     ; string 'PCBEEP'; used by MENUS
        db 'PCBEEP', 0x00
str_Sound:                                      ; string 'sound'; used by MENUS
        db 'sound', 0x00
str_Dbox_8:                                     ; string 'dbox'; used by MENUS
        db 'dbox', 0x00, 0x00
str_Kms_3:                                      ; string '.KMS'; used by MENUS
        db '.KMS', 0x00
str_Slapshot_2:                                 ; string 'SLAPSHOT'; used by MENUS
        db 'SLAPSHOT', 0x00
str_Cfg_5:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Slapshot:                                   ; string 'SLAPSHOT'; used by MENUS
        db 'SLAPSHOT', 0x00
str_Kms_2:                                      ; string '.KMS'; used by MENUS
        db '.KMS', 0x00
str_Mt32hock_2:                                 ; string 'MT32HOCK'; used by MENUS
        db 'MT32HOCK', 0x00
str_Cfg_4:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Mt32hock:                                   ; string 'MT32HOCK'; used by MENUS
        db 'MT32HOCK', 0x00
str_Cfg_3:                                      ; string '.CFG'; used by MENUS
        db '.CFG', 0x00
str_Snd_2:                                      ; string 'SND'; used by MENUS
        db 'SND', 0x00
str_Emmcopybuf:                                 ; string 'emmcopybuf'; used by MENUS
        db 'emmcopybuf', 0x00
SoundDevChoice:                                 ; sound device byte kept by SetSoundDevice; used by MENUS
        db 0x00
CrowdChannel:                                   ; crowd noise channel; used by Crowd_Noise, CrowdNoiseOff
        db 0x00, 0x00
SoundDevTable:                                  ; sound device table (device bit, driver ...) searched by
                                                ; SetSoundDevice; used by LP, MENUS
        db 0x10, 0x00, 0x01, 0x00, 0x04, 0x00, 0x02, 0x00, 0x08, 0x00
