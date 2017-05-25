;;; This is HP41 mainframe resurrected from list file output. QUAD 8
;;;
;;; REV.  6/81A
;;; Original file CN8B
;;;

#include "hp41cv.h"

              .SECTION QUAD8

; * HP41C mainframe microcode addresses @20000-21777
; *

              .public CLRPGM
              .public CLRREG
              .public DELLIN
              .public DELNNN
              .public ERR110
              .public ERR120
              .public ERROR
              .public GENLNK
              .public GSUBS1
              .public GTFEN1
              .public GTFEND
              .public GTLINK
              .public GTLNKA
              .public INSSUB
              .public MOVREG
              .public PACKE
              .public PACKN
              .public PAK200
              .public PAKEND
              .public PAKSPC
              .public PKIOAS
              .public PTBYTA
              .public PTBYTP
              .public PTLINK
              .public PTLNKA
              .public PTLNKB
              .public PUTPC
              .public PUTPCA
              .public PUTPCF
              .public PUTPCX
              .public SKPDEL
              .public UPLINK
              .public XBST
              .public XCOPY
              .public XDELET
              .public XPACK
              .public XSST

; *
; * PACK - pack memory including I/O area and key assignment area
; *
; * PACKN - normal packing subroutine
; * PACKE - fatal packing, after packing would say "TRY AGAIN"
; *         exits to error instead of returning
; * XPACK - set pushflag then normal packing
; *
; * USES A,B,C,M,N,G,ST[9:0], three level sub.
; * During packing uses M,N as counter
; * M[3:0] - next packed byte addr
; * M[7:4] - last packed END or ALBL addr
; * N[3:0] - last picking up byte addr
; *
; * Exits via decompile entries DCPL00 or DCPLRT.
; * Eventually returns (except PACKE) with chip 0 enabled and
; * status set 0 up.
; *
XPACK:
PACKN:        s9=     0             ; normal packing entry
              goto    PACK_
PACKE:        s9=     1             ; fatal packing entry
PACK_:        gosub   MSG           ; say "PACKING"
              xdef    MSGWR
              gosub   RSTMS0        ; enable chip 0 and clr MSGFLG
              gosub   PKIOAS        ; pack I/O buffer area
              c=0     w
              m=c                   ; indicate start from chain END
              s4=     0
              s7=     1
              gosub   GTFEND        ; get final END
              gosub   STBT31        ; reset pack bit
              data=c
              goto    PAK108
PAK100:       gosub   UPLINK
              b=a     wpt
              c=c+1   s             ; is this an "END"
              gonc    PAK105        ; yes
PAK102:       ?c#0    x             ; reach chain END ?
              goc     PAK100        ; not yet
              goto    PAK110
PAK105:       c=a     wpt           ; save 1st byte addr of end in N
              n=c
              gosub   INCAD2        ; bypass the link
              c=c-1   s
              rcr     12            ; C[1:0] _ third byte
              gosub   STBT30        ; reset the pack bit
              gosub   PTBYTA
              c=n                   ; get addr of END
              acex    wpt
PAK108:       gosub   GTLINK
              goto    PAK102
PAK120:       gosub   FSTIN         ; get top mem addr -1
              c=0     w             ; packing start from top
              goto    PAK115
PAK110:       ?s8=1                 ; does 1st PGM need packing ?
              goc     PAK120        ; yes
              c=m
              ?c#0    wpt           ; any PGM needs packing ?
              golnc   DCPLRT        ; none of the PGM needs packing
                                    ; exit via DCPLRT in decompile
              a=c     wpt           ; A[3:0] _ starting addr
              rcr     10            ; C[7:4] _ starting addr
              gosub   INCAD2        ; point to third byte of END
PAK115:       gosub   INCADA        ; point to next packing addr
              c=a     wpt
              m=c                   ; set the two addrs in M
              gosub   DECADA        ; back up one byte
              b=a     wpt
; * Decide whether we need to adjust the PC while packing
              gosub   GETPC
              ?s10=1                ; are we in ROM?
              goc     PAK117        ; yes, don't touch PC at all
              c=m                   ; C _ addr to start packing
              ?a<c    x             ; PC<start addr?
              goc     PAK118        ; yes, need to adjust PC
              ?a#c    x             ; PC>start addr?
              goc     PAK117        ; yes, don't touch PC
              ?a<c    pt            ; PC<start addr?
              goc     PAK118        ; yes, need to adjust PC
              ?a#c    pt            ; PC>start addr?
              gonc    PAK118        ; no, must adjust PC
PAK117:       a=0     wpt           ; leave the PGMPC alone
PAK118:       acex
              rcr     10            ; C[7:4] _ old PC
              c=b     wpt
              n=c
PAK130:       s8=     0             ; remember last line not a D.E.

PAK200:       c=n                   ; C[3:0] _ starting pick up addr
              a=c     wpt
PAK210:       b=a     wpt
              c=n
              c=b     wpt
              n=c
              gosub   NXBYTA        ; pick up next byte
              rcr     12            ; check if it is a null ?
              ?c#0    pt
              goc     PAK220        ; not a null
              ?c#0    xs
              gonc    PAK210        ; skip a null
PAK220:       c=c-1   pt            ; is it a row 0 FC ?
              goc     PAK250        ; yes
              c=c-1   PT            ; is it a row 1 FC ?
              gonc    PAK250        ; no
              c=c+c   xs            ; is column # <= 7 ?
              gonc    PAK230        ; yes, it is a D.E.
              c=c+c   xs            ; is column # <= 11 ?
              gonc    PAK230        ; yes, it is a D.E.
              ?c#0    xs            ; is it a CHS ?
              goc     PAK250        ; no
PAK230:       ?s8=1                 ; previous line a D.E. ?
              gonc    PAK240        ; no
              c=m                   ; load next packed addr
              a=c     wpt
              c=0     x
              gosub   PTBYTA        ; store a null between D.E.
              gosub   INCADA        ; point to next packed addr
              c=m
              acex    wpt
              m=c
PAK240:       s8=     1             ; remember this line is D.E.
              goto    PAK260
PAK250:       s8=     0             ; remember this line not a D.E.
PAK260:       c=n
              a=c     wpt           ; A[3:0] _ possible new PC
              rcr     4             ; C[3:0] _ old PC
              ?a<c    x             ; pass old PC already ?
              goc     PAK280        ; yes, set new PC
              ?a#c    x             ; same reg ?
              goc     PAK265        ; no, not close to PC yet
              ?a<c    pt            ; pass PC byte ?
              goc     PAK280        ; yes, set new PC
              ?a#c    pt            ; same byte ?
              gonc    PAK280        ; yes, set new PC
PAK265:       gosub   NXLDEL        ; get next line
              c=n                   ; C[3:0] _ last pick up addr
              acex    wpt           ; C[3:0] _ end pick up addr
              n=c                   ; N[3:0] _ end pick up addr
PAK270:       gosub   NXBYTA        ; pick up next byte
              bcex    wpt           ; save the byte in B
              c=m                   ; C[3:0] _ next packed addr
              dadd=c
              pt=     1
              gosub   PTBYTP        ; pack one byte
              c=m
              c=c-1   pt
              gonc    PAK275
              c=c-1   pt
              c=c-1   pt
              c=c-1
PAK275:       c=c-1   pt
              m=c
              c=n                   ; C[3:0] _ end picking addr
              ?a#c    wpt           ; picked up last byte already ?
              goc     PAK270        ; no
              golong  PAK200
PAK280:       c=0     x
              rcr     10
              n=c                   ; set old PC to very small
              b=a     wpt
              c=m
              a=c     wpt           ; get next packing addr
              gosub   DECADA
              gosub   PUTPCX        ; set new PC
              abex    wpt
              goto    PAK265
; *
; * PAKEND - this is final part of the pack routine. When the
; *   packing reached the final END, it would branch to here to
; *   generate a new final END instead of packing it. The reason
; *   is that the final END has to be right-justified in the reg.
; *
PAKEND:       spopnd
              c=n                   ; load the .END. addr
              dadd=c
              c=data                ; load the .END.
              pt=     0
              g=c                   ; save last byte of .END. in G
              c=m                   ; get addr of last packed reg
              dadd=c                ;   check if enough room in this
              a=c                   ;   reg. for a three-byte .END.
              c=data
              b=a                   ; save the addr in B
              asr                   ; A.XS _ last byte's position
              pt=     1             ; clear unused byte at tail
PKEND1:       a=a-1   xs            ; this byte used ?
              goc     PKEND2        ; yes
              a=a-1   xs
              inc pt                ; point to next higher byte
              inc pt
              goto    PKEND1
PKEND4:       a=c     pt            ; put .END. in last packed reg
              goto    PKEND3
PKEND2:       c=0     wpt           ; clear unused bytes
              data=c                ; put last reg back
              pt=     3             ; check how many bytes unused
              abex    wpt           ; get last byte's addr
              lc      4             ; at least need 3 unused bytes
              pt=     3
              ?a<c    pt            ; check last byte position
              gonc    PKEND4        ; there is enough room there
              acex    x             ; not enough room in last reg
              c=c-1   x             ;   for a .END., we have to put it
              dadd=c                ;   to next reg.
              a=c     wpt           ; save new .END. addr in A
              c=0     w             ; clear next reg first
              data=c
PKEND3:       c=m                   ; let GENLNK put the link in
              rcr     4             ; C[3:0] _ prev. END/ALBL addr
              acex    wpt           ; C[3:0] _ new .END. addr
              gosub   GENLNK
PKEND5:       dadd=c                ; put last byte of .END. in place
              c=data
              pt=   0
              c=g
              data=c
; *
; * Now clear all reg's between new .END. and old .END.
; *
              c=0     x
              dadd=c                ; enable chip 0
              c=regn  13            ; C.X _ old chain head
              acex    x             ; C.X _ new chain head
              regn=c  13
              b=0     w
PKEND6:       ?a#c    x             ; all done ?
              golnc   DCPL00        ; yes - decompile and exit
              c=c-1   x
              dadd=c
              bcex    w
              data=c
              bcex    w
              goto    PKEND6
; *
; * GTFEND - load final end
; *
GTFEND:       c=0     x
              dadd=c
              c=regn  13            ; load chain head
GTFEN1:       pt=     3
              lc      4
              dadd=c
              pt=     3
              a=c     wpt
              c=data
              rtn
; *
; * PAKSPC
; *
; * Special pack logic - a sub-branch from next line routine
; * pack calls NXLDEL to figure out how many bytes in next line,
; * but NXLDEL would send it back to here if it encounters an
; * ALBL or an END. The special pack logic here will generate a
; * new link for each ALBL or END, but not for the final END. It
; * will branch again to PAKEND, allowing it to take care of the
; * final END.
; *
PAKSPC:       gosub   GTLINK
              c=c+1   s             ; is it an END ?
              goc     PKSPC1        ; no, is an ALBL
              c=c+c   s             ; check for final END
              c=c+c   s
              c=c+c   s
              golc    PAKEND        ; is a final END
PKSPC1:       c=m                   ; C[3:0] _ next packing addr
              a=c     wpt
              rcr     4             ; C[3:0] _ previous END or ALBL addr
              acex    wpt
              gosub   GENLNK
              rcr     10
              gosub   INCAD2
              acex    wpt
              m=c
PKSPC3:       c=n
              a=c     wpt
              gosub   INCAD2
              c=a     wpt
              n=c
              gosub   NXBYTA
              rcr     12
              c=c+1   pt
              golc    NXLTX
              rtn
; *
; * PKIOAS - pack I/O buffer area & key assignment area at bottom
; *          of program memory.
; * Assumes chip 0 enabled
; * USES A,B,C,M,N. returns with chip 0 disabled
; * 2 sub levels deep
; *
; * For flowchart of PKIOAS, see DRC's lab notebook #00004 P.26
; *
PKIOAS:       c=regn  13            ; load chain head
              bcex    x             ; save chain head in B.X
              c=0     w
              ldi     0xc0          ; addr of chip 12 reg 0
              m=c                   ; M[2:0] _ current stack addr
              n=c                   ; N[2:0] _ current checking addr
              goto    PKASN3
PKM10:        dadd=c                ; enable checking reg.
              c=data                ; load the checking reg.
              c=c+1   s             ; is a key assignment reg. ?
              gonc    PKIO10        ; no, try to pack I/O area
              pt=     1
              ?c#0    wpt           ; keycode in REG.[1:0] ?
              goc     PKASN1        ; yes
              rcr     6
              ?c#0    wpt           ; keycode in REG.[7:6] ?
              gonc    PKASN2        ; no, pack this reg.
PKASN1:       gosub   MOVREG
              goto    PKASN3
PKASN2:       gosub   CLRREG
PKASN3:       c=b     x             ; load chain head
              a=c     x
              c=n
              ?a#c    x             ; reached chain head ?
              goc     PKM10         ; not yet
              rtn
; * Note there is at least one state to be had by moving the logic
; * at PKASN3 ahead of PKM10.  The use of B.M instead of N[11:10]
; * to store the buffer length in the PKIO15 path might result in
; * saving another state or two.
; *
PKIO10:       c=c-1   s             ; restore the reg.
              ?c#0    w             ; reached empty area ?
              rtn nc                ; yes, we are done
              bcex    s             ; check I/O buffer
              pt=     10
              g=c                   ; G _ buffer length
              c=n
              c=g                   ; N[11:10] _ buffer length
              n=c
              pt=     1
PKIO20:       c=n
              rcr     10            ; C.[1:0] _ buffer length
              c=c-1   wpt           ; done with this buffer ?
              goc     PKASN3        ; yes
              rcr     4
              n=c                   ; put the updated length back
              gosub   CLRREG
              ?b#0    S             ; is this buffer being used ?
              gsubc   PUTREG        ; yes. put reg back.
              goto    PKIO20
              .fillto 0x155         ; preserve entry table
; *
; * CLRREG - clear an unused reg. in program memory
; *  This routine called by PKIOAS to clear an unused reg
; *  in I/O or in key assignment area.
; * N[3:0] = current checking reg's addr (the reg to be cleared)
; *
CLRREG:       c=n                   ; C.X _ current checking addr
              dadd=c
              c=c+1                 ; point to next checking reg.
              n=c
              c=data
              a=0
              goto    MOVR10
; *
; * MOVREG - move a reg. to another addr
; *  This routine called by PKIOAS for packing those unused regs
; * N[3:0] = addr of the reg to be moved
; * M[3:0] = destination addr
;    410
; * PUTREG - put a register back to the destination address, and
; * increment the destination address.
; * USES: A,C
; * IN: A = reg to be put back
; *     M.X = destination address
; * OUT: (A) is stored to data reg (M.X)
; *     DADD = M.X
; *     M.X is incremented by 1.
; *     A is clobbered.
; * ASSUMES: hexmode, no peripheral enabled.
; *
MOVREG:       gosub   CLRREG        ; clear the checking reg first
              .public PUTREG
PUTREG:       c=m
              dadd=c                ; enable the destination reg.
              c=c+1                 ; point to next destination reg
              m=c
MOVR10:       acex    w
              data=c
              rtn
; *
; * COPY - copy a program from ROM to RAM
; * Alpha string is in REG.9 right-justified. The routine will
; * search the string in ROM and start copying from top of
; * that program. If REG.9 has null string and in ROM mode, copy
; * the current PGM.
; * USES A,B,C CALLS ASRCH, MEMLFT.
; * Normal return to NFRKB. if not enough mem to store the PGM,
; * do nothing. Simply goto pack the mem and say try again.
; * DURING THE COPYING:
; * C[6:3] has ROM addr. B[5:3] has RAM addr. B[2:0] has the
; * remaining # of reg.'s to be copied.
XCOPY:        c=regn  9             ; get alpha string
              m=c
              ?c#0    w             ; nullstring ?
              gonc    CPY120        ; yes, start from PGM head
              gosub   ASRCH         ; do the alpha search
              ?c#0    w             ; find it ?
CPYNE:        golnc   ERRNE
CPY100:       ?s9=1                 ; user code ?
              goc     CPYNE         ; no, microcode
              ?s2=1                 ; ROM ?
              goc     CPY110        ; yes
              .public ERRRAM
ERRRAM:       gosub   ERROR
              xdef    MSGRAM        ; say RAM
CPY110:       pt=     3             ; get the PGM head
              gosub   ROMH05
              goto    CPY130
CPY120:       ?s10=1                ; are we in ROM ?
              gonc    ERRRAM        ; no, we are in RAM
              gosub   ROMHED        ; get PGM head

CPY130:       acex    w
              rcr     11            ; C.M _ PGM head addr
              cxisa                 ; get header word
              c=c-1   xs            ; check private
              c=c-1   xs
              c=c-1   xs
              goc     CPY140        ; not private
              .public ERRPR
ERRPR:        gosub   ERROR
              xdef    MSGPR
CPY140:       c=c-1   m             ; point to P-1
              bcex    m             ; save addr in B.M
              gosub   MEMLFT        ; how many reg left ?
              a=c     x             ; A.X _ # of reg left in mem
              c=b     m             ; see how many regs required
              a=c     m
              cxisa                 ; load # of regs required
              ?a<c    x             ; enough room for this PGM ?
              golc    PACKE         ; no, try to pack mem
              c=c-1   x
              bcex    x             ; save # of regs in B.X
              c=0     x
              dadd=c
              c=regn  13            ; load chain head
              dadd=c
              c=c-1   x             ; point to starting RAM addr
              rcr     11
              bcex    m             ; save RAM addr in B.M
              c=data                ; load final END
              cstex
              s5=     0             ; make it become local END
              cstex
              data=c
              acex    m             ; get ROM addr
              c=c+1   m             ; point to header word
              cxisa                 ; load # of bytes in 1st reg
              pt=     1
              c=c-1   pt
              a=c     pt            ; move counter to C.S
              rcr     12
              acex    pt
              rcr     2
CPY145:       a=0     w             ; pack 7 ROM words to 1 reg
CPY150:       c=c+1   m
              cxisa                 ; load a byte
              a=c     wpt
              c=c-1   s
              goc     CPY160        ; done with one reg.
              asl     w
              asl     w
              goto    CPY150
CPY160:       bcex    w
              rcr     3             ; C.X _ RAM addr
              dadd=c
              c=c-1   x
              bcex    w
              acex    w
              data=c
              bcex    w
              rcr     11            ; C.X _ # of reg remaining
              c=c-1   x
              goc     CPY170        ; all done
              bcex    w
              acex    w
              pt=     13
              lc      6
              pt=     1
              goto    CPY145

CPY170:       rcr     3
              c=c+1   x
              a=c     x             ; A.X _ new chain head addr
              c=0     x
              dadd=c
              c=regn  13
              acex    x
              regn=c  13
              pt=     3
              a=0     pt            ; set PC to byte 0
                                    ; of old chainhead register
              s10=    0             ; clear ROM flag
              gosub   PUTPCX
              gosub   DECMPL        ; decompile
NFRKBX:       golong  NFRKB

              .public TRGSET
TRGSET:       c=regn  14
              c=0     x
              rcr     2
              st=c
              s6=     0
              s7=     0
              c=n
              rtn
; *
; *
; * PATCH1 - post-release fix to DECAD and DECADA 9/21/78
; * DECAD is in QUAD 10.
; *
              .public PATCH1
PATCH1:       a=a+1   pt
              golnc   INCADA
              a=a+1
              rtn
; *
; * PATCH2 - post-release fix to CLRPGM found later in QUAD 8.
; * This patch allows clearing of private programs at the end of
; * program memory.
; * The S10=0 is another fix to allow clearing of RAM programs
; * when the program counter is pointing to ROM.
; *
              .public PATCH2
PATCH2:       s10=  0               ; clear ROM flag
              gosub   FIXEND        ; get the 3rd byte of the current END
              c=b     wpt
              cstex                 ; turn off the private bit.
              s6=     0
              cstex
              gosub   PTBYTM        ; put the 3rd byte back
              rcr     8             ; set up for CPGMHD
              a=c     wpt
              golong  CPGMHD        ; go to the top of the program and return

; *
; * PATCH3 - post-release fix to INSSUB found at the END of QUAD 8
; * This fix prevents data entry into private programs.
; *
              .public PATCH3
PATCH3:       ?s10=1                ; is this a ROM program?
              rtn nc                ; no, continue
              gosub   ERROR         ; yes, error out
              xdef    MSGROM
; *
; * PATCH5 - post-release fix to DEL NNN to make it work when LINE#=000
; *
              .public PATCH5
PATCH5:       c=c-1   x             ; dec line# & test for 000
              rtn nc                ; non zero - OK
              ?s5=1                 ; is this backarrow?
              goc     NFRKBX        ; yes, do nothing.
              c=0     x             ; must be DEL NNN.
                                    ; put line# back to 000
              rtn
              .fillto 0x200
; *
; * Uplink jump table here
; *
TABUPL:       c=data                ; get the first byte
              goto    UPLB0         ; special case
              c=data
              goto    UPLB1         ; another special case
              c=data
              goto    UPLB2
              c=data
              goto    UPLB3
              c=data
              goto    UPLB4
              c=data
              goto    UPLB5
UPLB6:        c=data
GBA5:         rcr     10            ; rotate link into place
              rtn
              .fillto 0x210
; * Get byte jump table here
TBLGBA:       c=data                ; 7 entry points (0,2,4,...,12)
              rtn
              c=data
              goto    GBA1
              c=data
              goto    GBA2
              c=data
              goto    GBA3
              c=data
              goto    GBA4
              c=data
              goto    GBA5
GBA6:         c=data
GBA6A:        rcr     12
              rtn
UPLB5:
GBA4:         rcr     8
              rtn
UPLB4:
GBA3:         rcr     6
              rtn
UPLB3:
GBA2:         rcr     4
              rtn
UPLB2:
GBA1:         rcr     2
              rtn
UPLB1:        b=a     x             ; retrieve register #
              bcex    wpt           ; save link (4 dig), get address in C
              c=c-1   x
              dadd=c
              c=data                ; get the third byte
              c=b     wpt
              rtn
UPLB0:        b=a     x             ; retrieve the register #
              bcex    x             ; save 2 digits of link, get add in C
              c=c-1   x
              dadd=c
              c=data                ; get 2nd and 3rd bytes
              c=b     x
              goto    GBA6A         ; put all 3 bytes in place
; * UPLINK - move up one link of the label chain
; * Given an address of the first byte of a link in A[3:0] in
; *- MM format, and the link at that address in C[2:0], returns
; *- the address of the next link in A and the next link in C in
; *- the same format as input. In addition, the byte following the
; *- next link is found in C[13:12].
; * Expects and returns PT=3
; * USES A[3:0], B[3:0] and C.
; * Leaves DADD#0.
; *
; * GTLINK - get a link. Given the address of a link in A[3:0]
; *- Returns the link in the same form as UPLINK.
; *
; * GTLNKA - same as gtlink, but expects address in C[3:0]
; *
UPLINK:       c=0     pt            ; create the new address
              c=c+c   wpt           ; expand the link
              c=c+c   wpt
              c=c+c   wpt
              c=c+1   pt            ; add 2 to byte number when doubled
              c=c+c   pt            ; prepare for base 14 add
              c=c+c   x
              goc     ULINK1
              csr     x
              goto    ULINK2
ULINK1:       csr     x
              c=c+1   xs
ULINK2:       c=a+c   wpt           ; form new address
              gonc    ULINK3
              c=c+1   x
              legal
              goto    GTLNKA        ; address ready
ULINK3:       c=c-1   pt
              c=c-1   pt            ; the address is ready
GTLNKA:       a=c     wpt           ; save the address
              dadd=c                ; select the correct register
              rcr     4             ; prepare the 7-way table
; * TABLE JUMP
              ldi     0x220         ; uplink table address
              rcr     10
              gotoc                 ; go get link
; * GTLINK HERe
GTLINK:       acex    wpt           ; put address in place
              goto    GTLNKA        ; go get link
; *
; * XBST - execute backstep
; * Mainline code to execute backstep function
; * ASSUMES status set 0 up. PRGM mode bit used.
; * USES 3 sub levels.
; *
XBST:         rcr     6             ; catalog set
              cstex
              ?s1=1
              golc    BSTCAT
              gosub   SSTBST
              gosub   BSTEP         ; back up one line
XBST1:        gosub   DFRST9        ; display step number until key up
              ?s3=1                 ; prog mode?
              golc    DRSY25        ; yes, don't put up new display
              golong  NFRKB1        ; done!
; *
; * XSST - execute single step
; * Assumes status set 0 up. PRGM mode bit used.
; *
XSST:         rcr     6             ; catalog mode
              cstex
              ?s1=1
              golc    SSTCAT
              gosub   SSTBST
              gosub   GETPC
              c=regn  15            ; also get the line number
              ?s3=1                 ; PRGM mode?
              gonc    XSSTR         ; no, run mode
              ?c#0    x             ; if the line number #0
              gsubc   NXLSST        ; go to the next line
              gosub   GETLIN        ; fix the line number
              ?s6=1                 ; top of prog?
              gonc    1$            ; no, do a simple increment
              c=0     x             ; yes, set line # to 1
1$:           c=c+1   x
              gonc    2$            ; if not valid, leave alone
              c=c-1   x
2$:           regn=c  15
              gosub   PUTPC         ; fix up PC
              goto    XBST1         ; done!
; * Run mode single step
XSSTR:        ?c#0    x             ; line 0?
              goc     XSSTR1        ; no, do nothing
              c=c+1   x             ; yes, move to line 1
              regn=c  15
XSSTR1:       gosub   DFKBCK        ; display line number
              ?s9=1                 ; keybd reset yet?
              gsubnc  NULTST        ; no
              gosub   GETLIN        ; increment the line number
              c=c+1   x
              regn=c  15
              gosub   SETSST        ; set SST bit
              golong  RUNNK         ; go do 1 instruction

; *
; * CLRPGM - clear program
; * This routine clears the program whose name is found in REG 9.
; * If REG 9 = null, then clear the program where the PC is
; *- currently pointing
; * USES A, B[3:0],C,M,N,PT,ST[9,7:0],4 sub levels.
; *
; * See DRC'S LAB NOTEBOOK #10422X P.106 for flowchart of CLRPGM
; *
CLRPGM:       c=regn  9             ; retrieve the name
              m=c                   ; save for ASRCH
              ?c#0                  ; label present?
              goc     CLRP1         ; yes, go find it
              ?s10=1                ; ROM flag?
              goc     XCLPX1        ; yes, do nothing
              gosub   GETPC         ; null string here, get current address.
CLRP2:        gosub   FLINK         ; find the end of the program
              gosub   PATCH2        ; this patch clears the private bit
              gosub   PUTPCL        ; store in PC & get line #
              s5=     1             ; delete the program END
              c=0                   ; set # lines to delete = FFF
              c=c-1   x
              s9=     1             ; set up for pack
              goto    CLRP3         ; go delete the program
CLRP1:        gosub   ASRCH         ; go do alpha search
              pt=     3
              ?c#0                  ; success?
              gonc    CLPERR        ; no, error exit
              ?s2=1                 ; label found in ROM?
              gonc    CLRP2         ; no, found in RAM.
CLPERR:       golong  ERRNE         ; error exit

; *
; * DELNNN - delete NNN instructions
; * This routine deletes NNN lines of program starting with
; *- the one pointed to by the PC.
; * The NNN argument is found in A[X].
; * DELNNN will not delete a program END statement.
; * In all other ways this function is like XDELET found below.
; *
; *
; * XDELET - execute delete line
; * Deletes 1 line from program memory starting with
; *- the byte pointed to by the PC +1. The PC is set
; *- to properly point to the preceding line.
; * Updates links if a chain element is deleted.
; * Also sets pack and decompile bits of the
; *- following END.
; * S6 set to 1 when an END is deleted
; * NOTE, will NOT delete the final END!
; * USES A,B,C,M,N,ST[9:0],PT
; *
; * See DRC'S LAB NOTEBOOK #10422X P.107 for flowchart of DELNNN and
; *     XDELET.
; *
DELNNN:       acex                  ; store # to delete -1 in N
              c=c-1   x
              goc     XDELEX        ; zero to delete, do nothing.
              s5=     0             ; don't delete an END.
              ?s3=1                 ; PRGM mode?
              gonc    XDELEX        ; no, don't do it.
              goto    XDELA         ; go delete.
XDELET:       s5=     1             ; delete ENDs.
              c=0                   ; delete 1 line
XDELA:        n=c                   ; store # of lines to delete -1
              ?s12=1                ; private?
              goc     XDELEX        ; yes - do nothing
XCLPX1:       ?s10=1                ; ROM flag?
              golc    INSSUB        ; yes, do nothing. display [ROM].
              gosub   GETPC         ; get starting address of delete
              c=regn  15            ; decrement line number if non zero
              gosub   PATCH5
              regn=c  15
              s9=     0             ; clear pack flag
              c=n
CLRP3:        s6=     0             ; clear END flag
XDELM1:       n=c                   ; store # of lines left to delete -1
              gosub   DELLIN        ; delete 1 line
              ?s6=1                 ; traversed an END?
              goc     XDELM2        ; yes. quit.
              c=n                   ; C[X]-1 = # left to delete
              c=c-1   x             ; done?
              gonc    XDELM1        ; no, go around again
XDELM2:       gosub   FLINKP
              rcr     4             ; save previous link address in C[6:3]
              acex    wpt
              rcr     10            ; put decompile bits in END
              gosub   FIXEND
              rcr     4             ; put A[3:0] back
              a=c     wpt
              ?s9=1                 ; go pack?
              golc    GTO_5         ; yes.
              gosub   GETLIN        ; back step if new line num. # 0.
              ?c#0    x             ; back step?
              gonc    XDELEX        ; no, line 0.
              c=m                   ; retrieve the current address
              gosub   BSTEPA        ; back step.
XDELEX:       golong  NFRKB         ; all done!

; *
; * SSTBST - logic common to SST and BST
; *
              .public SSTBST
SSTBST:       gosub   PRT15
              .public PR15RT        ; for the printer
PR15RT:
              gosub   RSTSEQ        ; clear 6 flags
              gosub   ANNOUT        ; update annunciators
              gosub   LINNUM        ; reconstruct privacy flag
              ?s12=1                ; privacy?
              goc     XDELEX        ; yes. golong NFRKB
              rtn

; * ERROR - error exit
; * Calling sequence:
; *   GOSUB ERROR
; *   XDEF  <MSGXXX>
; * Error routine performs :
; * 1. If error flag already set, reset it, rtn to NFRKB
; * 2. Unconditional reset dataentry flag, and others
; * 3. Display error message
; * 4. If program running, stop running and do a back step
; * 5. Always return to NFRKB, won't return to calling program
; *
; *
; * ERR110 - error exit simply decide to do a back step or not before
; *          returning to NFR. required status set 0 loading.
; *
              .public ERRSUB
ERRSUB:       gosub   RSTMS0        ; enable chip 0 and
                                    ; clear DATAENTRY flag
              s8=     1             ; tell MSG to set MSGFLAG
              sethex
              rcr     7
              st=c
              ?s2=1                 ; error flag ?
              rtn nc                ; no
              s2=     0             ; reset error flag
              c=st
              rcr     7
              regn=c  14
ERRTN:        goto    XDELEX

ERROR:        gosub   ERRSUB
              c=stk
              cxisa
              gosub   MSGE
ERR110:       ?s13=1                ; running ?
              goc     ERR120        ; yes
              ?s4=1                 ; SST ?
              gonc    ERR130        ; no
ERR120:       gosub   BSTEP
ERR130:
              gosub   STOPS         ; clear PAUSEFLAG & RUNNING
              gosub   LINNUM        ; guarantee valid line number
                                    ; for PARSE in PRGM mode
              goto    ERRTN
; *
; *
; * DELLIN - delete line from program memory
; * This routine deletes a line of code starting with the
; *- next byte after the one specified by A[3:0] in MM format.
; * Will NOT delete the final END.
; * Returns S6=1 if END deleted.
; * If a chain element is deleted, the previous link is updated
; *- to include the deleted link.
; * USES A[3:0],B,C,M,3 subroutine levels
; *
; * NOTE !!! This routine cannot be called from a subroutine
; *
DELLIN:       acex    wpt           ; save starting address
              a=c     wpt
              m=c
              s4=     1
              s7=     1
              gosub   NXLDEL        ; find the ending address
              c=m                   ; retrieve the starting address
              acex    wpt           ; and save the ending address
              m=c
              goto    DELLN1        ; zero out appropriate bytes
DELLN2:       c=0                   ; zero 1 byte
              gosub   INCADA        ; move there
              gosub   PTBYTA        ; put zeros in
DELLN1:       c=m                   ; retrieve the ending address
              ?a#c    wpt           ; done?
              goc     DELLN2        ; no, delete some more
              rtn                   ; all done

; *
; * PTLINK - put link
; * Puts C[3:0] into program memory at the address pointed to
; *- A[3:0] in MM format.
; * PT=3 expected and returned
; * USES B[3:0]
; * This routine mixed in with PTBYTA
; *
PTLINK:       acex    wpt           ; save bytes to store
PTLNKA:       b=a     wpt           ; in B
              dadd=c                ; wake up the right register
              a=c     wpt           ; restore A
              rcr     4             ; prepare for branch table (7)
; * Table jump
              ldi     0x283         ; put link table address
PTLNKB:       rcr     10            ; put address in position
              gotoc                 ; 7-way branch
; *
; * PTBYTA - put byte
; * Put the byte in C[1:0] into RAM at the address
; *- pointed to by A[3:0] in MM format.
; * PT=3 out.
; * USES B[1:0]
; *
PTBYTA:       acex                  ; save byte to store in B
              pt=     1             ; set up for 1-byte store
              b=a     wpt           ; save byte
              dadd=c                ; wake up the right reg.
              a=c                   ; restore A
PTBYTP:       rcr     4             ; prepare for table jump
; * Table jump
              ldi     0x280         ; put byte table address
              goto    PTLNKB
; *
; * PUTPC - put away the program counter
; * Places A[3:0] in MM format into the PC after converting
; *- to PC format by shifting A[3] right 1 bit if S10=0
; * PT=3 assumed and returned
; *
; * PUTPCF - same as PUTPC, but sets line# to FFF
; *
; * PUTPCX - same as PUTPCF except if running line# not set to FFF
; *
; * PUTPCD - same as PUTPC except calls DECAD before going to PUTPC
; * consequently uses 1 subroutine level
; *
              .public PUTPCD
PUTPCD:       gosub   DECAD
              goto    PUTPC

PUTPCX:       ?s13=1                ; running?
              goc     PUTPC         ; yes, don't set line# to FFF
PUTPCF:       c=0                   ; set line# to FFF
              dadd=c
              c=regn  15
              c=0     x
              c=c-1   x
              regn=c  15
PUTPC:        c=0     x
              dadd=c
PUTPCA:       c=regn  12            ; get PC
              acex    wpt
              a=c     wpt           ; new PC in place
              ?s10=1                ; ROM address?
              goc     PUTPC3        ; yes, no shift
              c=c+c   pt            ; shift 1 bit right
              gonc    PUTPC1
              c=c+1   pt
PUTPC1:       c=c+c   pt
              gonc    PUTPC2
              c=c+1   pt
PUTPC2:       c=c+c   pt
              gonc    PUTPC3
              c=c+1   pt
PUTPC3:       regn=c  12            ; put PC back
              rtn
; * Special delete and pack logic here
SKPDEL:       ?s4=1                 ; delete logic?
              golnc   PAKSPC        ; pack logic goes here
SKPDL:        gosub   INCADA        ; move inside link
              gosub   FLINKA        ; find various links
              acex    wpt
              a=c     wpt           ; restore address before link
              gosub   DECADA
              acex    wpt
              m=c                   ; save current and previous link addresses
              gosub   GTLINK        ; get the current link
              c=c+1   S             ; END?
              goc     SKPD7         ; no, ALPHA label.
              s6=     1             ; END, remember it.
              ?s5=1                 ; traverse the END? (delete)
              gonc    SKPD4         ; no, (DEL NNN)
              c=c-1   s             ; final END?
              c=c+c   s
              c=c+c   s
              c=c+c   s
              gonc    SKPD1         ; no, traverse the END
SKPD4:        c=stk                 ; this is a special case exit out
              rtn                   ; of DELLIN!!! watch out!!!
SKPD7:        c=m                   ; save M in B
              bcex
              gosub   INCAD2        ; check byte after text char.
              gosub   NXBYTA        ; get keycode
              pt=     1
              c=c-1   wpt           ; subtract 1
              goc     SKPD6         ; do nothing if 0 keycode
              a=c     x             ; position for bitmap subs.
              asl     x
              c=0
              dadd=c
              gosub   TBITMP        ; clear bit
              gosub   SRBMAP
SKPD6:        c=b                   ; restore B to M
              m=c
              pt=     3
              a=c     wpt
              gosub   INCADA        ; get address of link in A[3:0]
              gosub   GTLINK        ; get the link
SKPD1:        rcr     10            ; save the current link
              bcex                  ; fix previous link
              c=m                   ; get address of previous link
              rcr     4             ; position for GTLINK
              gosub   GTLNKA        ; get it
              bcex                  ; place the first link in A[3:0]
              rcr     4
              bcex
              abex    wpt
              ?a#0    x             ; end of chain special case
              goc     1$            ; not here
              c=0     x             ; put end of chain 1 link down
1$:           c=c+1   xs            ; base 14 add
              c=c+1   xs
              c=a+c   x             ; create new longer link
              goc     SKPD2
              c=c-1   xs
              c=c-1   xs
              gonc    SKPD3
SKPD2:        c=c+1   x             ; new link ready
SKPD3:        abex    wpt           ; put the new link back
              gosub   PTLINK
              c=m
              a=c     wpt           ; get address of byte before link
              s7=     0             ; traverse the link this time
              golong  NXLDEL        ; around we go again.

; *
; * GENLNK - generate link
; * Given 2 addresses in A[3:0](larger) and C[3:0](smaller),
; *- creates the necessary link to go up the chain from C to A.
; *- This link is stored in the C address in memory.
; * Assumes and returns PT=3.
; * USES A[3:0],B[3:0],M, and 1 sub level. C saved.
; * For the special case of A[3:0]=0, 0 is stored as the link.
; *
GENLNK:       m=c
              ?a#0    wpt           ; top of chain?
              goc     1$            ; no
              c=0     wpt           ; yes, create a zero link.
1$:           c=a-c   wpt           ; create link
              gonc    GENLK1
              c=c-1   x             ; fix up address
              c=c-1   pt
              c=c-1   pt            ; in the borrow case
GENLK1:       c=c+c   x             ; make compact link
              c=c+c   x
              c=c+c   x
              c=c+c   x
              gonc    1$
              c=c+1   pt
1$:           csr     wpt
              lc      12            ; create link char.
              pt=     3             ; put pointer back
              a=c     wpt           ; store link
              c=m
              gosub   PTLNKA
              c=m                   ; fix up
              rtn                   ; done
; *
; * INSSUB - insert subroutine
; * This subroutine sets up the calculator for an insert.
; * If the line number # 0 or the current line # END, then
; *- the PC is advanced past the current line, S9 is set to 1.
; *- and the line # is incremented by 1.
; * C[13:10] is saved in A[13:10].
; * USES A[3:0],B[3:0],C,ST[9,7:0].
; *
INSSUB:       gosub   PATCH3        ; this patch checks privacy for data entry
              ?s12=1                ; is this a private program?
              golc    ERRPR         ; yes, say PRIVATE.
INSUBA:       acex                  ; save C in A
              gosub   GETPC
              s9=     0             ; disable backstep in INBYT error
              c=regn  15            ; get line number
              ?c#0    x             ; non-zero line  number?
              gonc    INSUB1        ; no, don't SKPLIN, but INC LINNUM.
              gosub   SKPLIN        ; skip a line
              ?s6=1                 ; hit an END?
              goc     INSUB2        ; yes, don't increment LINNUM.
              s9=     1             ; enable backstep on error.
INSUB1:       gosub   GETLIN        ; increment line number
              c=c+1   x
              regn=c  15            ; store away again
INSUB2:       golong  PUTPC         ; put address away and return

; *
; * GOSUB0,GOSUB1,GOSUB2,GOSUB3 - gosub long within a 4k rom to an
; *- address within a specified 1k rom.
; * These routines are the same as GOSUB except instead of assuming that
; *- the destination address is within the current 1024-word rom, the
; *- destination rom is specified by the call. i.e. to gosub to a
; *- subroutine in ROM1 of a 4-ROM chip, one would use:
; *    GOSUB  GOSUB1
; *    XDEF   <NAME>
; *
; * WARNING!!! If you specify the wrong ROM, the call will go to the
; *- address you specify rather than the correct one. This is a painful
; *- error to find since it results in jumps to the middle of nowhere.
; *
; * Uses C plus 1 additional subroutine level temporarily.
; *
; * GOL0,GOL1,GOL2,GOL3 - golong to anywhere in a 4k ROM.
; * Same as GOLONG except destination 1k rom specified as in GOSUB[0-3]
; * Uses C plus 1 subroutine level temporarily.
; *
; * Internal subroutine for GOSUB[0-3] and GOL[0-3]
; *
              .public GOL0
              .public GOSUB0
              .public GOL1
              .public GOSUB1
              .public GOL2
              .public GOSUB2
              .public GOL3
              .public GOSUB3
GSUBS1:       cxisa                 ; get 10 LSB of address plus 00
              csr     m             ; prepare to concatenate 12 bits to
              csr     m             ; top 4 bits of gosub address
              csr     m
              c=c+c                 ; align so that a mantissa increment
              c=c+c                 ; will change bit 10 of the final address
              rtn
GOL0:         c=stk                 ; get calling address
              goto    GSB0A         ; go to it (in ROM 0)
GOSUB0:       c=stk                 ; get calling address
              c=c+1   m             ; increment past argument
              stk=c                 ; put back for subroutine return
              c=c-1   m             ; decrement to get argument
              legal
GSB0A:        gosub   GSUBS1        ; prepare address
              goto    GSBQ0         ; finish up
GOL1:         c=stk
              goto    GSB1A
GOSUB1:       c=stk
              c=c+1   m
              stk=c
              c=c-1   m
              legal
GSB1A:        gosub   GSUBS1
              goto    GSBQ1
GOL2:         c=stk
              goto    GSB2A
GOSUB2:       c=stk
              c=c+1   m
              stk=c
              c=c-1   m
              legal
GSB2A:        gosub   GSUBS1
              goto    GSBQ2
GOL3:         c=stk
              goto    GSB3A
GOSUB3:       c=stk
              c=c+1   m
              stk=c
              c=c-1   m
              legal
GSB3A:        gosub   GSUBS1
GSBQ3:        c=c+1   m             ; select ROM 3 of chip
GSBQ2:        c=c+1   m             ; select ROM 2 of chip
GSBQ1:        c=c+1   m             ; select ROM 1 of chip
GSBQ0:        rcr     12            ; move address almost into place
              c=c+c                 ; align destination address on
              c=c+c                 ; digit boundaries.
              gotoc                 ; go.
; *
; * GSB000,GSB256,GSB512,GSB768 - fast absolute gosub
; * These four entry points to the same routine provide a means
; *- for fast 2-word gosubs in port addressed microcoded plug-in
; *- ROMs. The subroutine called must have its first word located
; *- on a local 256(DEC) boundary and the gosubs referencing the
; *- subroutine must be located within that 256-word block.
; * I.E. a subroutine could be located starting at location 512
; *- (1000 OCT) in some ROM and be called with a single 2-word
; *- gosub [ gosub GSB256 ] anywhere between locations 512 and 767.
; *
; * BEWARE!!! - This routine is dumb. If you call GSB256 from location
; *- 700 it will not go to 256 but to 512 as the labels are for
; *- programming convenience only. Be careful when you use these routines.
; *
; * Uses only C[6:2] plus 1 subroutine level temporarily.
; *
              .public GSB000
              .public GSB256
              .public GSB512
              .public GSB768
GSB000:
GSB256:
GSB512:
GSB768:       c=stk                 ; get the address
              stk=c                 ; restore the return address
              rcr     2             ; zero the last 8 bits
              c=0     x
              rcr     12            ; restore address to gotoc spot
              gotoc                 ; go do it
