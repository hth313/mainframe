;;; This is HP41 mainframe resurrected from list file output. QUAD 10
;;;
;;; REV.  6/81A
;;; Original file CN10B
;;;

#include "mainframe.h"


              .SECTION QUAD10

; * HP41C mainframe microcode addresses @24000-25777
; *
              .public AVAIL
              .public AVAILA
              .public BKROM2
              .public BSTE
              .public BSTE2
              .public BSTEP
              .public BSTEPA
              .public DECAD
              .public DECADA
              .public FIXEND
              .public FLINK
              .public FLINKA
              .public FLINKM
              .public FLINKP
              .public GETPC
              .public GETPCA
              .public GTBYT
              .public GTBYTA
              .public GTBYTO
              .public GTONN
              .public GTO_5
              .public IN3B
              .public INBYT
              .public INBYT0
              .public INBYT1
              .public INBYTC
              .public INBYTP
              .public INCAD
              .public INCAD2
              .public INCADA
              .public INCADP
              .public INEX
              .public INLIN
              .public INLIN2
              .public INSLIN
              .public INSTR
              .public INTXC
              .public LINN1A
              .public LINNM1
              .public LINNUM
              .public NROOM3
              .public NXBYT3
              .public NXBYTA
              .public NXL1B
              .public NXL3B2
              .public NXLCHN
              .public NXLDEL
              .public NXLIN
              .public NXLIN3
              .public NXLINA
              .public NXLSST
              .public NXLTX
              .public PTBYTM
              .public PUTPCL
              .public SKPLIN

; * Put byte branch table
TBLPBA:       c=data                ; 7 entry points(0,2,4,...,12)
              goto    PBA0          ; byte 0
              c=data
              goto    PBA1          ; byte 1
              c=data
              goto    PBA2
              c=data
              goto    PBA3
              c=data
              goto    PBA4
              c=data
              goto    PBA5
PBA6:         c=data                ; byte 6
              rcr     12            ; rotate proper byte into position
              c=b     wpt           ; store 1 (or 2) byte(s)
              rcr     2             ; restore byte(s) to proper position
              goto    PBAEND        ; clean up
PBA5:         rcr     10
              c=b     wpt
              rcr     4
              goto    PBAEND
PBA4:         rcr     8
              c=b     wpt
              rcr     6
              goto    PBAEND
PBA3:         rcr     6
              c=b     wpt
              rcr     8
              goto    PBAEND
PBA2:         rcr     4
              c=b     wpt
              rcr     10
              goto    PBAEND
PBA1:         rcr     2
              c=b     wpt
              rcr     12
              goto    PBAEND
PBA0:         c=b     wpt           ; no rotation needed here
PBAEND:       data=c                ; restore register in memory
              pt=     3             ; restore pointer
              rtn                   ; done!
INB1:         rcr     2
              bcex    wpt
              rcr     12
              goto    INBEXA

              .public ERRDE
ERRDE:        gosub   ERROR
              xdef    MSGDE
              .fillto 0x30

; * Put link branch table
TBLPTL:       c=data                ; 7 entry points(0,2,4,...,12)
              goto    PTL0          ; special case on boundary
              c=data
              goto    PBA0
              c=data
              goto    PBA1
              c=data
              goto    PBA2
              c=data
              goto    PBA3
              c=data
              goto    PBA4
              c=data
              goto    PBA5
PBA6A:        goto    PBA6
              .fillto 0x40

; * Insert byte branch table
TBLINB:       c=data                ; insert byte branch table
              goto    INB0          ; on 16-word boundary
              c=data
              goto    INB1
              c=data
              goto    INB2
              c=data
              goto    INB3
              c=data
              goto    INB4
              c=data
              goto    INB5
INB6:         c=data                ; get register to insert into
              rcr     12            ; position byte of interest in C[1:0]
              bcex    wpt           ; exchange byte with byte in register
              rcr     2             ; put byte back into right position in reg.
INBEXA:       goto    INBEX         ; finish up
PTL0:         rcr     12            ; put first byte in
              c=b     pt
              c=b     xs
              rcr     2
              data=c
              acex    wpt           ; put second byte in
              a=c     wpt           ; the next register
              c=c-1
              dadd=c
              pt=     1
              goto    PBA6A
INB5:         rcr     10
              bcex    wpt
              rcr     4
              goto    INBEX
INB4:         rcr     8
              bcex    wpt
              rcr     6
              goto    INBEX
INB3:         rcr     6
              bcex    wpt
              rcr     8
              goto    INBEX
INB2:         rcr     4
              bcex    wpt
              rcr     10
              goto    INBEX
INB0:         bcex    wpt
INBEX:        ?b#0    wpt
              goc     INLIN
              data=c                ; put register back
              c=m                   ; increment ct by 1
              c=c+1   s
              acex                  ; restore registers
              c=0     x             ; wake up chip 0
              dadd=c
              rtn                   ; done
INLIN:        gosub   AVAIL         ; check if empty reg. available
NROOM:        ?c#0                  ; empty register?
              gonc    NROOM0        ; no, error exit
; * Insert assured here.
              gosub   FLINKM        ; find links to fix up chain
              gosub   FIXEND        ; fix up END
              rcr     4             ; fix up following link
              gosub   GTLNKA        ; get link
              ?c#0    x             ; top element of chain?
              gonc    1$            ; yes, do nothing
              c=c+1                 ; add 1 to register count
              legal
1$:           gosub   PTLINK        ; put link back
              c=m
              a=c     wpt
              rcr     1             ; put byte # in C[XS]
              pt=     1             ; set pt to top digit of the byte
              goto    INL1          ; specified by C[XS].
INL2:         c=c-1   xs
              inc pt
              inc pt
INL1:         c=c-1   xs
              gonc    INL2
              c=0                   ; fix up chainhead
              dadd=c
              c=regn  13
              c=c-1
              regn=c  13            ; put back
INL3:         c=c+1                 ; move registers down
              dadd=c
              bcex    x
              c=data
              bcex    x
              c=c-1   x
              dadd=c
              bcex    x
              data=c
              bcex    x
              c=c+1   x
              ?a#c    x             ; finished?
              goc     INL3          ; no, move another line.
              bcex    x             ; clean up
              acex
              data=c                ; store A temporarily
              c=0                   ; created null register
              acex    wpt           ; place nulls in beginning of register
              acex
              c=data                ; retrieve old A
              acex
              data=c                ; store last part of register
              c=m
              dadd=c
              c=data
              c=0     wpt           ; store last part of register with
              data=c                ; 1 or more nulls
              c=m                   ; go back and finish the insert
              golong  INBYT1
NROOM0:       c=m                   ; no room - error exit
              a=c     wpt           ; zero previously inserted steps
              goto    NROOM2
NROOM1:       gosub   DECADA
              c=0     x
              gosub   PTBYTM
              c=c-1   s             ; done?
              m=c
NROOM2:       ?c#0    s
              goc     NROOM1        ; no, zero out some more bytes.
              ?s9=1                 ; set running to assure back step
              gonc    NROOM3        ; if S9=1
              s13=    1
NROOM3:       golong  PACKE

; *
; * AVAIL - find an available register
; * This subroutine places chainhead-1 in A[X] and looks
; *- to see if chainhead-1 is available for use in inserting
; *- or in assigning. C[X] is returned as 0 if there is no room.
; *- If there is room, C[X] is returned as decimal 192.
; *- Nothing is assumed and PT is returned as 3
; * AVAILA - same as AVAIL except PT is not set and chip 0 assumed
; *- selected.
; *
AVAIL:        c=0
              pt=     3
              dadd=c
AVAILA:       c=regn  13            ; get chainhead address
              c=c-1
              dadd=c                ; select chainhead-1 register
              a=c     x             ; save address in A
              c=data                ; get the register
              ?c#0                  ; non-zero register?
              goc     AVAIL1        ; yes, error exit
              ldi     192           ; register existent?
              ?a<c    x
              rtn nc                ; yes, success exit
AVAIL1:       c=0                   ; failure exit
              rtn

; * BSTEP - back step
; * When called, assumes the program counter is pointing
; *- at an unknown line. This routine moves the program
; *- counter to a point at the byte just preceding the
; *- unknown line.
; * Works in ROM or RAM
; * Will back step past beginning of memory to END
; *- if line number = 1 or 0.
; * Assumes nothing
; * USES A,B[3:0],C,M,N,ST[7:0],3 sub levels
; *
; * Back around to end case of back step
BSTEP2:       ?s10=1                ; ROM flag?
              goc     BSTEP3        ; yes, do back step in ROM
              gosub   FLINKP        ; find the END of the program
              rcr     8
              a=c     wpt
                                    ; move back one byte
              gosub   PUTPCD        ; put PC there
              golong  LINNM1        ; calculate new line number and rtn
BSTEP:        gosub   LINNUM        ; get the line number
              c=c-1   x             ; 0?
              goc     BSTEP2        ; yes, go to END.
              ?c#0    x             ; 1?
              gonc    BSTEP2        ; yes, go to END.
              regn=c  15            ; no,  fix line number
BSTEP3:       gosub   GETPC         ; get program counter
              ?s10=1                ; ROM flag
              goc     BKROM         ; ROM-
              gosub   FLINK         ; RAM
BSTEPA:       cmex                  ; save addresses in M
              ?a#0    wpt           ; top of memory?
              goc     BST1          ; no
              gosub   FSTIN         ; yes - move to before first instruction
              goto    BST2
BST1:         gosub   DECADA        ; move to address before link
BST2:         gosub   GTBYTA        ; get byte
              rcr     12
              clr st                ; set up for NXLIN
              s4=     1
              goto    BSTML2        ; go find the end of the current line
; * Revised back step main loop
BSTML:        rcr     10            ; save previous 2 addresses
              c=b     wpt
              acex
              cmex                  ; get register back
              gosub   NXLIN         ; move up one line
BSTML2:       cmex
              b=a     wpt
              acex
              ?a<c    x             ; more?
              goc     BSTML         ; yes!
              ?a#c    x             ; same reg?
              goc     BSTML1        ; no, done
              ?a<c    PT            ; more?
              goc     BSTML         ; yes
              ?a#c    wpt           ; done?
              gonc    BSTML         ; no, don't quit on equal
BSTML1:       rcr     8             ; done-get old address
BSTE:         golong  BSTE2         ; put in PC

; * ROM back step here
BKROM:        rcr     11            ; put PC in place
              s8=     1             ; set GTONN bit
BKROM1:       cxisa                 ; get byte
              c=c-1   m             ; move to previous byte
              c=c-1   xs            ; starting byte?
              goc     BKROM1        ; no
              rcr     3             ; put in place
              c=c-1   s             ; begin?
              golnc   BKROM2        ; yes, goto line FFF of prog
              goto    BSTE          ; no, done!

; *
; * FIXEND - fix end
; *- Sets decompile and pack bits in an END specified
; *- by C[11:8]
; *- PT=3 in and out
; *- USES 1 sub level
; *  USES A[3:0],B[3:0],M
; *
FIXEND:       m=c                   ; save addresses
              rcr     8             ; get END address
              a=c     wpt
              gosub   INCAD2        ; get END byte
              gosub   GTBYTA
              pt=     0             ; put decompile and pack bits in END
              lc      15
PTBYTM:       gosub   PTBYTA
              c=m                   ; restore address
              rtn
; *
; * FLINK - find links
; * Given an address in MM form in C[3:0]
; * Returns the following in MM form:
; *
; * FLINKP - same as  FLINK except uses the PC as the input address
; *
; * FLINKA - same as FLINK except input address in A[3:0].
; *
; * A[3:0] - the address of the link preceding (higher reg #)
; *- the input address.
; * C[3:0] - the input address
; * C[7:4] - the address of the next link following the input
; *- address
; * C[11:8]- the address of the first END following the input
; *- address
; * M[2:0] AND M[13] - the link preceding the input address
; * note- if no link precedes the input address [top of memory]
; *- then A[3:0] and M set to 0
; * USES A[3:0],B[3:0],C[11:0],M,1 sub level
; * PT=3 on return
FLINKP:       gosub   GETPC         ; get program counter
FLINKA:       acex    wpt           ; move address to C
FLINK:        cmex
FLINKM:       gosub   GTFEND        ; get the final END
              rcr     2             ; put in place
              goto    FLINK2
FLINK1:       gosub   UPLINK        ; move up 1 link
FLINK2:       cmex                  ; retrieve addresses
              ?a<c    x             ; see if done
              goc     FLINK3        ; no way - try again
              ?a#c    x             ; check for same register case
              rtn c                 ; done!
              ?a<c    pt            ; check byte
              goc     FLINK3        ; try again
              ?a#c    pt            ; on link?
              rtn c                 ; all done if not equal
FLINK3:       rcr     4             ; go up another link
              b=a     wpt           ; put address in following link spot
              c=b     wpt
              rcr     10
              cmex                  ; check for END
              c=c+1   s
              goc     FLINK5        ; carry if alpha label
              cmex                  ; put address in following END spot
              rcr     8
              c=b     wpt
              rcr     6
              cmex
              s12=    0             ; clear privacy status bit
              c=c-1   s             ; restore END byte
              c=c+c   s             ; check private bit for this program
              c=c+c   s             ; is it 1?
              gonc    FLINK5        ; no, leave privacy reset
              s12=    1             ; yes, set privacy status
FLINK5:       ?c#0    x             ; check for end of chain
              goc     FLINK1        ; non-zero - try again
              a=0     wpt           ; fix up end of chain exit
              c=0
              cmex
              rtn
; *
; * GETPC - retrieves the PC after selecting chip 0 and creates
; *- the MM address form by doubling the byte number if the
; *- S10=0. The resulting MM address is
; *- stored in A[3:0]
; * GETPCA - same as GETPC except chip 0 assumed selected.
; * SETS PT=3
; * USES A[3:0],and C
; *
GETPC:        c=0
              dadd=c
GETPCA:       c=regn  12
              pt=     3
              ?s10=1
              goc     1$
              c=c+c   pt
1$:           a=c     wpt
              rtn
; *
; * GTONN - goto line NNN of the current program
; * Replaces the program counter with the address of
; *- the line specified by A[2:0]
; * FFF in A[2:0] means GTO..
; * USES A,B[3:0],C,N,M,P,Q,ST[7:0]
; *
GTONN:        pt=     3             ; restore pointer to MM place
              acex                  ; put line# in C
              ?c#0    x             ; goto 0?
              golnc   RTN30         ; yes, execute keyboard return
              c=0     m             ; clean up the register
              c=c+1   x             ; GTO..?
              goc     `GTO..`       ; yes.
              c=c+1   x             ; GTO. alpha?
              gonc    GTONN2        ; nope, go on
              ldi     0x1d          ; create goto alpha function code
              rcr     12            ; put in place
              s9=     0             ; clear alpha search bit
              golong  XROW1         ; go to the label
GTONN2:       c=c-1   x
              c=c-1   x             ; restore line number
              rcr     10            ; put in place
              s8=     1             ; set GTONN bit
              gosub   LINN1A        ; go do it
              golong  NFRC          ; return
`GTO..`:      c=regn  13            ; get chainhead address
              lc      4
              pt=     3             ; save for later
              a=c     wpt
              n=c
              gosub   GTLINK        ; is the previous link an END?
              ?c#0    x             ; is it the top of memory?
              goc     `GTO.4`       ; no, see if previous link is an END
              gosub   FSTIN         ; go to the top of memory
              goto    `GTO.2`       ; see if .END. is the first inst.
`GTO.4`:      gosub   UPLINK        ; get the link
              c=c+1   s             ; is it an alpha label?
              goc     `GTO.1`       ; yes, put an END in.
              gosub   INCAD2        ; go to the next instruction
`GTO.2`:      gosub   NXBYTA        ; find the address of the next line
              rcr     12            ; null?
              ?c#0    pt
              goc     `GTO.2A`
              ?c#0    xs
              gonc    `GTO.2`       ; yes, null, keep looking
`GTO.2A`:     c=n                   ; compare addresses
              ?a#c    wpt           ; same as the final END?
              gonc    `GTO.3`       ; yes, no insert needed.
; * Create new final END here
`GTO.1`:      gosub   AVAIL
              ?c#0                  ; is there room?
              golnc   PACKE         ; no, go pack!
              pt=     5             ; make new final END
              lc      12
              pt=     3
              ldi     0x120         ; link= 1 reg.
              data=c
              c=n                   ; fix old END
              dadd=c
              c=c-1   x             ; construct addr of new
              a=c     wpt           ;  final END and save in
; * A[3:0] for the PUTPCD call later on
; * Note C[3] here is 4, the MM byte count for the
; * first byte of the END.  N[3:0] was set up back at GTO..
              c=data                ; get old final END
              cstex                 ; turn off final END status bit
              s5=     0
              s2=     1             ; turn off pack bit
              cstex
              data=c                ; return
              c=0                   ; fix chainhead
              dadd=c
              c=regn  13
              c=c-1   x
              regn=c  13
`GTO.3`:      s10=    0             ; turn off the ROM flag
                                    ; fix PC
              gosub   PUTPCD
GTO_5:        gosub   PACKN         ; pack memory
              gosub   RTN30         ; make a zero line number
              golong  NFRPU         ; can't use a rtn here.

; * The GOLONG NFRPU is necessary here instead of a simple
; * return because we get here from CLP via DELLIN and DELLIN
; * uses up all the subroutine levels, pushing the NFRPU off
; * the top of the stack.
; *
; * GTBYT - get byte
; * Generalized routine for getting a byte out of ROM or RAM.
; * Gets the byte pointed to by A[3:0] in MM address form and
; * places it in C[1:0]
; * GTBYTA - same as GTBYT except RAM addresses only work.
; * USES A[3:0] and C
; *
GTBYT:        ?s10=1                ; ROM flag?
              gonc    GTBYTA        ; no, get RAM byte
GTBYTO:       acex                  ; yes, get ROM byte
              a=c
              rcr     11
              cxisa
              rtn                   ; done
; *
; * NXBYTA - get the next byte
; * Increments A[3:0] in MM format and returns the byte
; *- pointed to by this address in C[1:0].
; * ASSUMES PT=3 on entry
; * RAM ONLY!
; * Uses 1 sub level
; *
; * NXBYT3 - get the next 3rd byte
; * Same as NXBYTA except increments the address 3 bytes instead
; *- of 1 before getting the byte
; *
NXBYT3:       gosub   INCAD2
NXBYTA:       gosub   INCADA
; * Get a byte from RAM here
GTBYTA:       acex    wpt           ; get byte out of RAM
              a=c     wpt           ; set up table address
              dadd=c
              rcr     4
              ldi     0x221         ; table on 16-word boundary
; * Table jump
                                    ; table - get byte
              rcr     10
              gotoc                 ; 7-way branch

              .public CALDSP
CALDSP:       a=a-c   x             ; A[3:0]_PGMCTR-rel addr
              a=a-c   pt            ; -
              rtn nc
              goto    INC2
; *
; * INCAD - increment address
; * Increments ROM or RAM (MM form) address in A[3:0] in place.
; * INCADA - same as INCAD except assumes PT=3 and only RAM addresses.
; * INCADP - same as INCADA except set PT=3 on entry
; * INCAD2 - increment address by two bytes
; * Same as 2 calls to INCADA except faster.
; *
; * DECAD - DECADA  decrement address
; *-DECADA - assumes address is a RAM address
; *-DECAD - RAM or ROM
; *-Address expected in A[3:0] in MM format
; *-PT expected at 3 for DECADA, always returned at 3
DECAD:        pt=     3
              ?s10=1                ; ROM flag?
              goc     DECADB
DECADA:       a=a+1   pt
              a=a+1   pt
              a=a+1   pt
              legal
              golong  PATCH1        ; 0734 in QUAD 8
INCAD:        ?s10=1                ; ROM flag?
              goc     INCADB        ; yes, ROM increment.
INCADP:       pt=     3             ; no, RAM address to increment
              goto    INCADA
INCAD2:       a=a-1   pt            ; byte 0?
              goc     INC21         ; yes, go to next reg, byte 5
              a=a-1   pt            ; finish the first increment
INCADA:       a=a-1   pt            ; byte=0?
              goc     INC1          ; yes, go to next reg, byte 6
              a=a-1   pt            ; no, finish moving to next byte
              rtn                   ; done
INC21:        a=a-1   pt            ; 2 inc case, byte 5 desired
              a=a-1   pt
INC1:         a=a-1   pt            ; set C[PT] to 12 (byte 6)
INC2:         a=a-1   pt
              a=a-1   pt
DECADB:       a=a-1                 ; decrement register by 1
              rtn                   ; done
INCADB:       a=a+1                 ; ROM increment
              rtn                   ; done

; *
; * INBYT0 - insert a zero byte into memory
; * Conditions the same as INBYT except that G need not be
; *- specified.
; *
; * INBYTC - special INBYT entry where the byte to be inserted is
; *- found in C[1:0].
; *
; * INBYTP - same as INBYT except that the PT points to the
; *- last digit of the byte in C to be inserted.
; *
INBYT0:       c=0     x
INBYTC:       pt=     0
INBYTP:       g=c

; * INBYT - insert byte into program memory
; *- Increment A[3:0] in MM format and insert the byte in G into
; *- program memory at that location. Make space if necessary
; *- by increasing prog length by 1 register. Fix up chainhead,
; *- current program head and closest link. Also increment CT
; *- in A[13]. CT is used to keep track of the number of
; *- successful inserts in a line in case of running out of room.
; * Does not return if no room. The previous [CT] bytes set to 0
; *- If S9=1 then back step forced in error case.
; * Assumes nothing.
; * Returns chip 0 selected and PT=1
; * USES A[11:0],B[3:0],C[3:0],M,G,PT,S9,and 2 sub levels
; *
; * NOTE- INBYT0 must be located right above here.
; *
INBYT:        gosub   INCADP        ; move to right byte
              acex                  ; save address
              m=c
INBYT1:       dadd=c                ; wake up the right register
              rcr     4             ; do 7-way branch just like GTBYTA
              pt=     0
              c=g                   ; put byte to insert into B[1:0]
              bcex    x
              pt=     1             ; set pointer to insert 2 digits (1 byte)
              ldi     0x284
; * Table jump
              rcr     10
              gotoc
; *
; * INSLIN - insert line
; *  This routine inserts a line after the current line pointed to
; *- by the PC. Does not skip current line if the line is an END or
; *- the line number is 0.
; * Leaves the PC pointing to the new line and increments the line
; *- number by 1. If no room, the entire insert is ignored.
; * Digit or test entry not handled by this routine.
; * The line to be inserted has its first byte in C[13:12], the
; *- second byte, if needed, is in C[11:10]. Alpha operands are
; *- in register 9.
; * USES A,B,C,M,G,ST[9:0]
; *
INSLIN:       gosub   INSSUB        ; initialize
INLIN2:       b=a                   ; save bytes for later
              c=b                   ; get first byte ready for insert
              pt=     12
              g=c
              a=0     s             ; initialize CT to 0
              gosub   INBYT         ; insert 1 byte
              c=-c    s             ; decode number of bytes to insert
              c=c+c   s             ; 1-byte?
              gonc    IN2B          ; no, more decode
              c=c+1   s             ; line 1?
              c=c+1   s
              gonc    INEXA         ; no, done!
; * Alpha operands here
              gosub   INTXC         ; prepare text character
              gosub   INBYTC        ; insert text char.
              gosub   INSTR         ; output text string
              goto    INEXA         ; done!
IN2B:         c=c+c   s             ; 2-byte?
              golnc   IN3B          ; no, more decode
              ?c#0    s             ; row 12? (no row 11 codes)
              goc     IN2BA         ; no, rows 9-10
              pt=     12            ; check for LBL NN
              c=c+1   pt            ; LBL NN?
              gonc    IN2BB         ; no, more decode
              rcr     10            ; yes, check for short form
              c=c+1   x             ;  note-FF is illegal address
              pt=     1             ; 15 carried to 10?
              ?c#0    pt            ; or >15?
              goc     INN2B         ; yes, long form, normal 2-byte
              .public INSHRT
INSHRT:       gosub   PTBYTA        ; short form
INEXA:        goto    INEX          ; done!
IN2BB:        c=c+1   pt            ; C<>REG?
              goc     INN2B         ; yes, normal 2-byte
; * Links of the chain inserted here
              s8=     0             ; clear END bit
              c=c+1   PT            ; END?
              goc     1$            ; no, alpha label
              s8=     1             ; set END bit
1$:           gosub   INBYT0        ; put in byte for link
              ldi     15            ; put 0f in exp field
              ?s8=1                 ; END?
              gonc    INLNK1        ; no, alpha label
              gosub   INBYTC        ; output 0f (END byte)
              goto    INLNK2        ; go fix links
INLNK1:       gosub   INTXC         ; make text character
              c=c+1   x             ; count byte for keycode
              legal
              gosub   INBYTC        ; insert text count
              gosub   INBYT0        ; insert zero byte for keycode
              gosub   INSTR         ; insert string
INLNK2:       gosub   GETPC         ; fix links
              gosub   INCADA        ; point to first byte of new link
              gosub   FLINKA        ; find links
              gosub   GENLNK        ; fix current link
              rcr     4
              gosub   GENLNK        ; fix previous link
              ?s8=1                 ; if END, fix previous END
              gonc    INEX          ; no, done
              rcr     10            ; yes, put decompile bits
              gosub   FIXEND        ; in previous END
              a=c     wpt           ; move PC to end of "END"
              gosub   INCAD2
              gosub   PUTPC
              c=regn  15            ; set line # to 000
              c=0     x
              regn=c  15
INEX:         golong  NFRC          ; done
IN2BA:        c=c+c   s             ; separate rows 9 and 10
              ?c#0    s
              goc     IN2R9         ; row 9, more to do
INN2B:        c=b                   ; row 10, normal 2-byte
              pt=     10
              gosub   INBYTP        ; insert second byte
              goto    INEX          ; done
; * Row 9 here
IN2R9:        pt=     12
              c=c-1   pt            ; RCL?
              gonc    IN2STO        ; no, check for STO
              pt=     11            ; yes, check for short form
              ?c#0    pt            ; <16?
              goc     INN2B         ; no, long form.
              lc      2             ; yes, make short form
INRCLS:       rcr     10
INSHR2:       golong  INSHRT        ; insert it
IN2STO:       c=c-1   pt            ; STO?
              gonc    INN2B         ; no, standard 2-byte
              pt=     11            ; short form?
              ?c#0    pt
              goc     INN2B         ; no, long form
              lc      3
              goto    INRCLS        ; short form
; * 3-byte functions here
IN3B:         gosub   INBYT0        ; put out second byte for compile
              c=c+c   s             ; XEQ or GTO?
              ?c#0    s
              gonc    INN2B         ; XEQ-insert normal address
              rcr     10            ; check for short form
              c=c+1   x             ;  NOTE-FF is illegal
              pt=     1
              ?c#0    pt            ; short form?
              goc     INN2B         ; no, insert normal address
              lc      11            ; yes, short form
              gosub   DECAD         ; overwrite first byte
              goto    INSHR2
; *
; * INSTR - insert string
; * Given REG A in the proper format for INBYT, inserts a
; *- label string from REG 9 into program memory.
; * Uses the same registers as INBYT and in addition all
; *- of C.
; * Uses 3 sub levels. Returns PT=1
; *
INSTR:        c=regn  9             ; get the rest of the string
INSTR1:       ?c#0                  ; all done?
              rtn nc                ; yes, go back.
              gosub   INBYTC        ; no, insert another char.
              c=regn  9             ; shift out inserted char.
              csr
              csr
              regn=c  9
              goto    INSTR1        ; go around again
; *
; * INTXC - prepare test character for insert
; * Places a text character of the proper size in C[1:0]
; * which is needed to precede the text string in REG 9.
; * Uses only C[X] and M.
; *
INTXC:        ldi     0xf0          ; create text character
              acex                  ; place text char in A
              m=c                   ; save A for later
              c=regn  9             ; get text char
              goto    INTXC2
INTXC1:       a=a+1   x             ; add 1 to text char
              csr                   ; move to next char.
              csr
INTXC2:       ?c#0                  ; all done?
              goc     INTXC1        ; no, count some more.
              c=m                   ; done, put things back.
              acex                  ; restore A
              rtn                   ; done
; *
; * LINNUM - line number
; * When called either recalls the binary line number
; *- of the current line from register 15 or else computes it
; *- if the line number stored is invalid. In all cases the
; *- correct line number is returned in C[2:0]. If computed,
; *- the proper line number is stored.
; * Assumes chip 0 selected on input.
; * Works in ROM or RAM.
; * Uses 2 subroutine levels.
; * USES A,C,M,N,P,Q,B[3:0],ST[8:0], returns P selected if line number
; *- is computed.
LINNUM:       c=regn  15            ; get line number
              c=c+1   x             ; valid?
              goc     LINNM1        ; no, go compute it.
              c=c-1   x             ; restore the correct number
              rtn
LINNM1:       s8=     0             ; clear GTONN bit
BKROM2:       c=0
              c=c-1                 ; set target line# = FFF
LINN1A:       sel p                 ; compute line number in RAM
              pt=     4             ; set up pointers for later
              sel q
              n=c                   ; store target line#
              ?s10=1                ; ROM flag?
              goc     LINROM        ; yes, compute line# in ROM
              gosub   FLINKP        ; find the previous link
              ?s8=1                 ; GTONN?
              gonc    1$            ; no, use PC address
              rcr     8             ; yes, use end address as target
1$:           c=0     pq            ; prepare for line number in pq field
              cmex
              ?a#0    wpt           ; top of memory?
              gonc    LINNM5        ; yes, go to first inst.
              goto    LINNM2        ; no, go find it
LINNM3:       gosub   UPLINK        ; find previous END
LINNM2:       c=c+1   S             ; END?
              gonc    LINNM4        ; yes, move to final byte
              ?c#0    x             ; top of memory?
              goc     LINNM3        ; no, continue
LINNM5:       gosub   FSTIN         ; yes, position just before 1st inst.
              goto    LINNM6        ; go count lines.
LINNM4:       gosub   INCADA        ; END! set up for counting loop
              gosub   NXBYTA        ; position to last byte of END
              rcr     12
LINNM6:       clr st                ; set up for NXLIN
              s4=     1
              b=a     wpt           ; save counting address in B
              cmex                  ; store mem reg in C
              a=c                   ; get target address and line CT to A
              c=n                   ; retrieve the target line number
              c=b     wpt           ; merge with the counting address
; * Main counting loop
LINML:        n=c                   ; save the current address
              acex
              cmex                  ; save address, get steps
LINML1:       gosub   NXLIN         ; move to the next line
              cmex                  ; get address
              c=c+1   pq            ; add 1 to line count
              acex                  ; test for done
              ?a#c    pq            ; reached line NN
              gonc    LINML2        ; yes, GTONN exit.
              ?a<c    x             ; more?
              goc     LINML         ; yes.
              ?a#c    x             ; same register?
              goc     LINML2        ; no, done!
              ?a<c    pt            ; more?
              goc     LINML         ; yes
              ?a#c    pt            ; more? - don't stop on equal.
              gonc    LINML         ; yes
LINML2:       acex                  ; save number in C
              goto    LINEND        ; all done!
; * Calculate line number in ROM
LINROM:       gosub   ROMHED        ; A[3:0]=address of begin
              c=0                   ; prepare a zero mantissa
              acex    wpt           ; C=counting reg, A[3:0]=0
              m=c                   ; save counters in M
              a=a-1   wpt           ; set A[3:0]=FFFF
              ?s8=1                 ; GTONN?
              gsubnc  GETPC         ; no, get ending address
              c=n                   ; get ending line#
              acex    wpt           ; form target string
              cmex                  ; get ready for loop
              a=c                   ; put counting addresses in A
              s6=     0             ; clear END bit
              goto    LINRM4
LINRM2:       gosub   SKPLIN        ; move to the next line
              ?s6=1                 ; hit an END?
              goc     LINRM3        ; yes, done!
LINRM4:       a=a+1   pq            ; no, add 1 to line#
              c=m                   ; get targets
              ?a<c    pq            ; reached the line#?
              gonc    LINRM3        ; yes, done!
              ?a<c    wpt           ; reached the address?
              goc     LINRM2        ; no, try again.
LINRM3:       acex                  ; done!
              n=c                   ; save the address in N
LINEND:       rcr     4             ; put the new line# in A[X]
              a=c     x
              gosub   GETLIN        ; place number in register 15
              sel p                 ; select P for return
              pt=     3
              ?s12=1                ; private program?
              rtn c                 ; yes, return FFF.
              acex    x             ; put line number in place
              regn=c  15            ; put back
              c=n
BSTE2:        a=c     wpt
PUTPCL:       gosub   PUTPC         ; put the new address in the PC
              c=regn  15            ; get the line number
              rtn
; *
; * NXLIN - move to the next line
; * Special RAM program memory traversal subroutine
; * Given the address of the last byte of a line in MM format in
; *- A[3:0], and also in C, the register pointed to by A[2:0] is
; *- rotated so that the byte pointed to by A[3] is in C[3:2].
; * The routine returns A & C in the same format as they were
; *- input but referring to the next line in program memory.
; * NOTE- If the byte number=0 then C[3:2] is correct, but the
; *- rest of C may be from a different register on return. On
; *- input, C need not be specified.
; * Trailing nulls are treated as part of the current program step.
; * USES B[3:0]
; * PT=3 in and out
; *
; *
; * SKPLIN - skip a line
; * Given the address of the last byte of a program line
; *- in A[3:0] in MM format, returns the address of the
; *- last byte of the next line in A[3:0].
; * Nulls following the current line are properly skipped
; * The routine does nothing if the line to be skipped is
; *- an END.
; *
; * NXLSST - same as SKPLIN, but this entry will skip ENDs
; *- by going to step 1 of the current program.
; *
; * S6 set to 1 when encountering an END.
; * USES A[3:0],B[3:0],C,ST[7:0],1 sub level
; *
; * NXLDEL - a special entry point into NXLIN has been
; *- created for delete operations. This entry point
; *- expects S7=1 and goes on to the normal RAM line skipping
; *- logic. If a chain element is to be skipped, special
; *- delete logic is employed.
; * The previous link is enlarged to bridge the gap
; * if an END is to be deleted, set S5=0. otherwise all ENDs
; * are treated as the final END.
; * If the final END, return with the same address as input.
; *
NXLSST:       clr st                ; single step entry
              goto    NXLSS1
SKPLIN:       clr st
              s5=     1             ; set bit to back up on END
NXLSS1:       ?s10=1                ; ROM to skip?
              goc     SKPROM        ; yes go do it
NXLDEL:       gosub   NXBYTA        ; delete entry
              goto    NXLINA
; * ROM skip line here
SKPROM:       acex    wpt
              rcr     11
SKPR10:       c=c+1   m
              cxisa
              ?c#0    xs            ; 1st byte of new FC?
              gonc    SKPR10        ; no. skip this null.
SKPR20:       c=c+1   m             ; skip this byte
              cxisa
              c=c-1   xs            ; continuation byte?
              goc     SKPR20        ; yes
SKPR30:       c=c-1   m             ; must be 3rd byte of END
                                    ; or 1st byte of 2nd new FC
                                    ; back up one byte
              c=c-1   xs            ; was it 1st byte of 2nd FC?
              golc    ROMH35        ; yes
              s6=     1             ; mark the END
              ?s5=1                 ; stop at END?
              golnc   ROMHED        ; no. go to top
              c=c-1   m             ; back up 2nd byte
              legal
              goto    SKPR30        ; go back up 1 more & exit
; * NXLIN RAM traversal logic here
NXLIN:        a=a-1   pt            ; move to the next byte
              gonc    NXLIN1
              acex    wpt           ; get the next register
              c=c-1   pt            ; set byte no. to 6
              c=c-1   pt
              c=c-1   x             ; move to the next register
              dadd=c                ; get it
              a=c     wpt           ; save the new address
              c=data
              rcr     12            ; move byte 6 into byte 0 position
NXLIN1:       a=a-1   pt            ; finish changing the byte no.
NXLINA:       rcr     12            ; move new byte into position
              c=-c    pt            ; start decode
              c=c+c   pt            ; 1-byte?
              gonc    NXLIN2        ; no, more decode
NXL1B:        c=c+1   pt            ; 1-byte inst. here
              c=c+1   pt            ; row 1?
              rtn nc                ; no, all done!
              c=c+c   xs            ; dig 0-7?
              gonc    NXLDE         ; yes
              c=c+c   xs            ; dig 8-9, . ,EEX?
              gonc    NXLDE         ; yes
              ?c#0    xs            ; GTO ALPHA,XEQ ALPHA?
              goc     NXLIN         ; yes, get text
; * Digit entry here
NXLDE:        bcex    wpt           ; save the current byte in B
              c=b     wpt           ; restore C
              gosub   NXL3B2        ; get the next byte
              c=-c    pt            ; search for non-digit entry code
              c=c+c   pt            ; 1-byte FN?
              gonc    NXLDE2        ; no, back up 1 byte
              c=c+1   pt
              c=c+1   pt            ; row 1?
              gonc    NXLDE2        ; no, back up
              c=c+c   xs            ; dig 0-7?
              gonc    NXLDE         ; yes, keep going
              c=c+c   xs            ; dig 8-9, . ,EEX?
              gonc    NXLDE         ; yes, keep going
              ?c#0    xs            ; CHS?
              gonc    NXLDE         ; yes, keep going
NXLDE2:       gosub   DECADA        ; back up one byte
              rcr     2             ; restore the register
NXLTX1:       c=b     wpt           ; retrieve old byte
              rtn                   ; done!
; * 2-byte instructions here
NXLIN2:       c=c+c   pt            ; 2-byte?
              gonc    NXLIN3        ; nope, more decode
              ?c#0    pt            ; row 12?
              goc     NXL3B2        ; no, increment 1 byte
              c=c+1   xs            ; LBL NN?
              goc     NXL3B2        ; yes, simple increment
              c=c+1   xs            ; X<>NN?
              goc     NXL3B2        ; yes
NXLCHN:       ?s7=1                 ; delete?
              golc    SKPDEL        ; yes, special logic
              gosub   NXL3B2        ; get the third byte
              gosub   NXL3B2
              c=c+1   pt            ; alpha label?
              goc     NXLTX         ; yes, go do the text
              s6=     1             ; no, END - mark it
              ?s4=1                 ; normal case?
              rtn c                 ; yes, done!
              gosub   DECADA        ; restore address of 1st byte of link.
              gosub   DECADA
              ?s5=1                 ; SKPLIN?
              goc     NXLDE2        ; yes, back up
              gosub   GTLINK        ; no, single step
              golong  CPGMHD        ; go to the top of the program

; * 3-byte instructions here
NXLIN3:       c=c+c   pt            ; 3-byte?
              gonc    NXLIN4        ; no, more decode
              gosub   NXL3B2        ; increment the first byte
NXL3B2:       a=a-1   pt            ; increment 1 byte
              gonc    NXL2B1
              acex    wpt
              lc      12
              pt=     3
              c=c-1   x
              dadd=c
              a=c     wpt
              c=data
              rcr     10
              rtn
NXL2B1:       a=a-1   pt
              rcr     12
              rtn
; * Text and row 0 here
NXLIN4:       c=c+c   pt            ; text?
              goc     NXLTX         ; yes, go traverse it.
; * Row 0 here
NXLR0:        ?c#0    xs            ; short labels?
              rtn c                 ; yes, all done!
              golong  NXLIN         ; skip over nulls

; * Text here
NXLTX:        c=c-1   xs
              rtn c                 ; exit for function code F0
NXLTX2:       bcex    wpt           ; save byte count in B
              gosub   NXL3B2        ; move to the next char.
              bcex    wpt           ; retrieve remaining char count.
              c=c-1   xs            ; decrement the char count
              gonc    NXLTX2        ; done?
              goto    NXLTX1        ; yes, restore the C register

              .public GCPK04
              .public GCPK05
              .public GCPKC
              .public GCP112

; *  GCPKC - GET/CLEAR/PLACE keycode
; *- Depending upon the input conditions, this subroutine
; *- will get, clear or place a keycode in the ASN
; *- function table or program memory, whichever is
; *- applicable.
; *-
; *- GET- IN:  A[1:0]= logical keycode
; *-           status bit 1= 0
; *-      OUT: chip 0 selected
; *-           C[3:0]= corresponding function code if ROM
; *-                 = corresponding label address if RAM
; *-           S3= 1 implies C[3:0] is a RAM label address
; *-           (if digit 3 = 0 then function code is 1-byte
; *-            function code)
; *-
; *- CLEAR- IN:  A[1:0]= logical keycode
; *-             status bit 1 = 1
; *-        OUT: chip 0 selected
; *-
; *- PLACE- IN:  A[3:2]= logical keycode
; *-             A[1:0]= zero
; *-             B[3:0]= function code
; *-        OUT: S3=1 implies function was placed
; *- USES:  A,B,C,M,N,status bit 3
; *- USES:  1 subroutine level

GCPKC:        s3=     0             ; -
              c=regn  13            ; M_chainhead
              pt=     3
              lc      4             ; C[3:0]=final END addr
              m=c                   ; save final END addr in M
              pt=     3
              rcr     10
              c=b     wpt
              bcex    w             ; save .END. addr in B[7:4] too

              .public GCPKC0        ; search ALBLS from any link
GCPKC0:       ldi     191           ; C[2:0] _ 1ST reg
GCPK10:       c=c+1   x             ; -
              acex                  ; chainhead=reg?
              cmex                  ; -
              ?a#c    x             ; -
              gonc    GCPK04        ; yes, search ALBLS
              cmex                  ; restore regs
              acex                  ; -
              dadd=c                ; C_reg
              n=c                   ; -
              c=data                ; -
              c=c+1 s               ; end ASNs?
              gonc    GCPK05        ; yes
              c=c-1   s             ; -
              a=c     s             ; -
GCPK70:       pt=     1             ; initialize
              ?a#c    wpt           ; 1st keycode?
              gonc    GCPK80        ; yes
              rcr     6             ; 2nd keycode?
              ?a#c    wpt           ; -
              goc     GCPK20        ; nope
GCPK80:       ?a#0    wpt           ; place?
              goc     GCP100        ; nope
              pt=     3             ; -
              asr     wpt           ; C[1:0]_K.C.
              asr     wpt           ; -
              acex    x             ; -
              acex    xs            ; -
              rcr     2             ; place the function code
              c=b     wpt           ; -
              s3=     1             ; function placed
GCPK90:       rcr     6             ; restore register
              ?a#c    s             ; -
              gonc    1$            ; -
              rcr     6             ; -
1$:           data=c                ; restore register
              goto    GCP112        ; -
GCP100:       ?s1=1                 ; clear?
              gonc    GCP110        ; nope
              c=0     wpt           ; zero out keycode
              rcr     2             ; restore register
              goto    GCPK90        ; -
GCP110:       rcr     2             ; C[3:0]_function code
GCP112:       cmex                  ; select chip 0
              c=0     x             ; -
              dadd=c                ; -
              cmex                  ; -
              rtn                   ; return

GCPK20:       c=n                   ; increment to nxt reg
              goto    GCPK10        ; -

GCPK04:       cmex                  ; restore registers
              goto    GCPK06
GCPK05:       acex                  ; B[5:4]_K.C.
GCPK06:       rcr     10            ; -
              bcex                  ; -
              n=c                   ; save F.C. in N
              rcr     4             ; C[3:0]_chainhead
              pt=     3
              a=c     wpt
              gosub   GTLINK
GCPK15:       ?c#0    x             ; end of chain?
              gonc    GCPK55        ; yes, not found
              gsblng  UPLINK        ; get next link
              c=c+1   s             ; ALBL?
              gonc    GCPK15        ; nope
              rcr     10            ; save link & addr in M
              acex    wpt           ; -
              a=c                   ; -
              m=c                   ; -
              gsblng  INCAD2        ; get keycode byte
              gsblng  NXBYTA        ; -
              b=a     wpt           ; -
              pt=     1             ; correct K.C.?
              c=b     m             ; -
              rcr     4             ; -
              a=c     wpt           ; -
              rcr     10            ; -
              ?a#c    wpt           ; -
              goc     GCPK45        ; nope
GCPK25:       ?a#0    wpt           ; place?
              goc     GCPK28        ; no
              c=0     x             ; -
              pt=     3             ; -
GCPK55:       c=b     m             ; A[1:0]_K.C.
              dadd=c                ; -
              rcr     4             ; -
              a=c                   ; -
              c=n                   ; restore F.C.
              bcex                  ; -
              goto    GCP112        ; -
GCPK28:       ?s1=1                 ; get?
              gonc    GCPK35        ; yes
              c=0     x             ; clear K.C.
              abex                  ; -
              gsblng  PTBYTA        ; -
              goto    GCP112        ; -
GCPK35:       c=m                   ; C[3:0]_LBL addr
              s3=     1             ; RAM addr
              goto    GCP112        ; -

GCPK45:       pt=     3             ; prepare to get nxt link
              c=m                   ; -
              a=c     wpt           ; -
              rcr     4             ; -
              goto    GCPK15        ; -

              .public LEFTJ
; *
; * Left-justify LCD
; *
LEFTJ:        ldi     32            ; blank
              a=c     x
              pt=     1
LEFTJ1:       rabcl
              ?a#c    wpt
              gonc    LEFTJ1
              rabcr
              rtn
