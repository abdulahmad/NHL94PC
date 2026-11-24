; The rink objects: the player sort objects, the puck, the doors and the referee.
sortobj0_Xpos2:                                 ; sort object 0 (sortobj0), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj0_Ypos2:                                 ; sort object 0 (sortobj0), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
sortobj0_position:                              ; sort object 0 (sortobj0), field +1Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 42
CwdExciteLvl:                                   ; crowd excitement level; used by AI
        resb 1
sortobj0_pflags2:                               ; sort object 0 (sortobj0), field +45h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj0_47:                                    ; sort object 0 (sortobj0), field +47h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1467
sortobj12_Xpos2:                                ; sort object 12 (sortobj12), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj12_Ypos2:                                ; sort object 12 (sortobj12), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 6
sortobj12_Xvel:                                 ; sort object 12 (sortobj12), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj12_Yvel:                                 ; sort object 12 (sortobj12), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 116
sortobj13_Xpos2:                                ; sort object 13 (sortobj13), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
sortobj13_Ypos2:                                ; sort object 13 (sortobj13), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 6
sortobj13_Xvel:                                 ; sort object 13 (sortobj13), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
sortobj13_Yvel:                                 ; sort object 13 (sortobj13), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 114
puckstruct:                                     ; sort object 14 (puck), field +00h
        resb 2
puckXpos2:                                      ; sort object 14 (puck), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
puckYpos2:                                      ; puck sort object field +06h (the object starts 6 bytes
                                                ; before); used by AI
        resb 4
puckZpos2:                                      ; sort object 14 (puck), field +0Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckXvel:                                       ; sort object 14 (puck), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckYvel:                                       ; sort object 14 (puck), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
puckframe:                                      ; sort object 14 (puck), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 10
puck_1C:                                        ; sort object 14 (puck), field +1Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
puckasslist:                                    ; sort object 14 (puck), field +1Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
pucktemp1:                                      ; puck sort object temp1; used by AI
        resb 2
pucktemp2:                                      ; sort object 14 (puck), field +28h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 22
pucknopuck:                                     ; puck sort object nopuck field; used by AI
        resb 7
puckpflags2:                                    ; puck sort object pflags2; used by AI
        resb 3
puck_48:                                        ; sort object 14 (puck), field +48h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 56
doorstruct:                                     ; sort object 15 (door), field +00h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorXpos2:                                      ; sort object 15 (door), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorYpos2:                                      ; sort object 15 (door), field +06h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorZpos2:                                      ; sort object 15 (door), field +0Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorXvel:                                       ; sort object 15 (door), field +0Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorYvel:                                       ; sort object 15 (door), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
doorframe:                                      ; sort object 15 (door), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
doortemp1:                                      ; sort object 15 (door), field +26h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doortemp2:                                      ; sort object 15 (door), field +28h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 16
door_38:                                        ; sort object 15 (door), field +38h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 12
doorpflags:                                     ; sort object 15 (door), field +44h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
doorpflags3:                                    ; sort object 15 (door), field +46h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
door_48:                                        ; sort object 15 (door), field +48h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 56
refstruct:                                      ; sort object 16 (ref), field +00h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
refXpos2:                                       ; sort object 16 (ref), field +02h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
refYpos2:                                       ; referee sort object field +06h; used by AI
        resb 6
refXvel:                                        ; referee x velocity; used by AI
        resb 2
refYvel:                                        ; sort object 16 (ref), field +0Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 4
refframe:                                       ; sort object 16 (ref), field +12h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
refposition:                                    ; sort object 16 (ref), field +1Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
ref_1C:                                         ; referee sort object field +1Ch; used by AI
        resb 2
refasslist:                                     ; referee assignment list; used by AI
        resb 8
reftemp1:                                       ; referee temp1; used by AI
        resb 4
reftemp3:                                       ; referee temp3; used by AI
        resb 2
reftemp4:                                       ; sort object 16 (ref), field +2Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 2
reftemp5:                                       ; sort object 16 (ref), field +2Eh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 8
ref_36:                                         ; sort object 16 (ref), field +36h; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 20
ref_4A:                                         ; sort object 16 (ref), field +4Ah; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1
ref_4B:                                         ; sort object 16 (ref), field +4Bh; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 1
ref_4C:                                         ; sort object 16 (ref), field +4Ch; sort objects are 80h
                                                ; bytes from SortCords; used by AI
        resb 52
