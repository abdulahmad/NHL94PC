; NHL 94 PC structure field offsets: the player structure (SortCords entries) and the team structure (hmshots,
; awshots), with the 93G/94G names. Equates only; operands keep their displacement size, so the bytes do not change.
; Offsets come from the 94PC code (setplayer copies the roster bytes in order from 49h; updateplayers saves Xpos/Ypos/
; Zpos to 64h/68h/6Ch; check4bench and defaultsprites_0 write SCnum, newpos/newpnum, tmptr/optmptr) matched against
; NHL95PC src/inc/structs.inc (same C source): below 48h the layout is the same; 95PC's 54h-69h block is 48h-5Dh
; here (no puckdist/puckdir/passlane), and tmptr/optmptr are near pointers (2 bytes), so OldXpos.. move down 10h.
; A 16.16 field (size d) is read as words: Name (fraction) and Name+2 (integer).

; ---- player structure
Xpos       equ 0x00  ; size d
Ypos       equ 0x04  ; size d
Zpos       equ 0x08  ; size d
Xvel       equ 0x0C  ; size w
Yvel       equ 0x0E  ; size w
Zvel       equ 0x10  ; size w
frame      equ 0x12  ; size w
impactp    equ 0x14  ; size w
limpact    equ 0x16  ; size w
impact     equ 0x18  ; size w
position   equ 0x1A  ; size w
assnum     equ 0x1C  ; size w
asslist    equ 0x1E  ; size b
temp1      equ 0x26  ; size w
temp2      equ 0x28  ; size w
temp3      equ 0x2A  ; size w
temp4      equ 0x2C  ; size w
temp5      equ 0x2E  ; size w
Wallcos    equ 0x30  ; size w
Wallsin    equ 0x32  ; size w
facedir    equ 0x36  ; size w
SPA        equ 0x38  ; size w
SPAnum     equ 0x3A  ; size w
SPAcnt     equ 0x3C  ; size w
nopuck     equ 0x3E  ; size w
newpos     equ 0x42  ; size b
newpnum    equ 0x43  ; size b
pflags     equ 0x44  ; size b
pflags2    equ 0x45  ; size b
pnum       equ 0x47  ; size b
attribute  equ 0x49  ; size b
weight     equ 0x4A  ; size b
legstr     equ 0x4B  ; size b
legspd     equ 0x4C  ; size b
aioff      equ 0x4D  ; size b
aidef      equ 0x4E  ; size b
shotspd    equ 0x4F  ; size b
shotacc    equ 0x50  ; size b
passacc    equ 0x51  ; size b
rostnum    equ 0x52  ; size b
spodds     equ 0x53  ; size b
stickhand  equ 0x54  ; size b
endurance  equ 0x55  ; size b
aggress    equ 0x56  ; size b
checking   equ 0x58  ; size b
handed     equ 0x59  ; size b
radiusx    equ 0x5A  ; size w
radiusy    equ 0x5C  ; size w
SCnum      equ 0x5E  ; size w
tmptr      equ 0x60  ; size w
optmptr    equ 0x62  ; size w
OldXpos    equ 0x64  ; size d
OldYpos    equ 0x68  ; size d
OldZpos    equ 0x6C  ; size d

; ---- team structure (hmshots / awshots): only fields with clear evidence
tmline     equ 0x16  ; current line (93G/94G tmline, same offset)
tmlines    equ 0xBE  ; line table (95PC tmlines: getlinee / setpersonel read it)
tmroster   equ 0xD0  ; roster pointer, 28h bytes per player (setplayer: imul 28h, status byte 4 = on ice)
tmsort     equ 0xD4  ; first SortCords entry of the team (95PC tmsort)
