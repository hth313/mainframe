;;; This is HP41 mainframe resurrected from list file output. QUAD 7
;;;
;;; REV.  6/81A
;;; Original file CN7B
;;;

#include "mainframe.h"

              .section QUAD7

; * HP41C mainframe microcode addresses @16000-17777

              .public GTACOD
              .public TOGSHF
              .public TGSHF1
; ************************************************
; * Nut message table & message routine          *
; ************************************************
              .public MSG
              .public MSGA
              .public MSGAD
              .public MSGDE
              .public MSGE
              .public MSGML
              .public MSGNE
              .public MSGNL
              .public MSGNO
              .public MSGOF
              .public MSGPR
              .public MSGRAM
              .public MSGROM
              .public MSGTA
              .public MSGWR
              .public MSGX
              .public MSGYES

              .fillto 3             ; put spare at beginning
; *
; * PATCH9 - post-release fix to SIGMA+ an SIGMA- to get old X
; * preserved in LastX.
; *
              .public PATCH9
PATCH9:       c=n                   ; get new X
              golong  XCLX1         ; go update X

; *
; * PATCH6 - post-release fix to CHKADR to prevent wraparound when
; * physical register address carries into the 10th or 11th bits.
; * With this patch, CHKADR will accept physical register addresses
; * up thru 511 only (9 bits only).
; *
              .public PATCH6
PATCH6:       s9=     1             ; remember error exit to ERRNE
              a=0     XS
              a=a+1   XS
              ?a<c    XS            ; 511<reg address?
              golc    ERRNE         ; yes - no such reg

              dadd=c                ; address the register
              golong  P6RTN

; *
; * Message table
; *
              .con    0x101         ; A
              .con    0x0c          ; L
              .con    0x10          ; P
              .con    0x08          ; H
              .con    0x01          ; A
              .con    0x20
              .con    0x04          ; D
              .con    0x01          ; A
              .con    0x14          ; T
MSGAD:        .con    0x01          ; A
              .con    0x104         ; D
              .con    0x01          ; A
              .con    0x14          ; T
              .con    0x01          ; A
              .con    0x20
              .con    0x05          ; E
              .con    0x12          ; R
              .con    0x12          ; R
              .con    0x0f          ; O
MSGDE:        .con    0x12          ; R
              .con    0x10d         ; M
              .con    0x05          ; E
              .con    0x0d          ; M
              .con    0x0f          ; O
              .con    0x12          ; R
              .con    0x19          ; Y
              .con    0x20
              .con    0x0c          ; L
              .con    0x0f          ; O
              .con    0x13          ; S
MSGML:        .con    0x14          ; T
              .con    0x10e         ; N
              .con    0x0f          ; O
              .con    0x0e          ; N
              .con    0x05          ; E
              .con    0x18          ; X
              .con    0x09          ; I
              .con    0x13          ; S
              .con    0x14          ; T
              .con    0x05          ; E
              .con    0x0e          ; N
MSGNE:        .con    0x14          ; T
              .con    0x10e         ; N
              .con    0x15          ; U
              .con    0x0c          ; L
MSGNL:        .con    0x0c          ; L
              .con    0x110         ; P
              .con    0x12          ; R
              .con    0x09          ; I
              .con    0x16          ; V
              .con    0x01          ; A
              .con    0x14          ; T
MSGPR:        .con    0x05          ; E
              .con    0x10f         ; O
              .con    0x15          ; U
              .con    0x14          ; T
              .con    0x20
              .con    0x0f          ; O
              .con    0x06          ; F
              .con    0x20
              .con    0x12          ; R
              .con    0x01          ; A
              .con    0x0e          ; N
              .con    0x07          ; G
MSGOF:        .con    0x05          ; E
              .con    0x110         ; P
              .con    0x01          ; A
              .con    0x03          ; C
              .con    0x0b          ; K
              .con    0x09          ; I
              .con    0x0e          ; N
MSGWR:        .con    0x07          ; G
              .con    0x114         ; T
              .con    0x12          ; R
              .con    0x19          ; Y
              .con    0x20
              .con    0x01          ; A
              .con    0x07          ; G
              .con    0x01          ; A
              .con    0x09          ; I
MSGTA:        .con    0x0e          ; N
              .con    0x119         ; Y
              .con    0x05          ; E
MSGYES:       .con    0x13          ; S
              .con    0x10e         ; N
MSGNO:        .con    0x0f          ; O
              .con    0x112         ; R
              .con    0x01          ; A
MSGRAM:       .con    0x0d          ; M
              .con    0x112         ; R
              .con    0x0f          ; O
MSGROM:       .con    0x0d          ; M
; *
; * MSG - send a message to LCD display
; * Calling MSG with S8 set, MSGFLAG
; * will be set so the display won't be refreshed by display refresh
; * logic. Otherwise, the display will be refreshed.
; * CALLING SEQUENCE:
; *     GOSUB  MSGA
; *     XDEF   <MSGXXX>
; * MSG - set S8 automatically, then drop to MSGA
; * MSGX -  plug-in ROM can call MSGX to display the message in ROM
; *         If S8= 1, GOSUB PRT6, blink LCD, set message flag
; *         If S8= 0, don't print or set message flag
; *     IN: C[6:3]= address of first character of message
; *    OUT: If S8= 1: SS0 UP, msg flag set, chip 0 enabled, C= REG 14
; *         If S8= 0: chip 0 enabled
; *   USES: If S8= 1: A,C,G,N,ST[7:0], active PT, 2 additional sub levels
; *         If S8= 0: A,C, active PT, 1 additional sub level
; * ASSUME: hexmode
; *
; * Message table format:
; * Every char in the message costs a 10-bit word to store it.
; * Entry of each message pointing last char of the message. The
; * MSG routine works backward, it picks up last char first and shifts
; * it from right end to the display, then picks up next last one until
; * done with the 1st char which has bit 8 set.
; * Char in the message table is in LCD form.
; *
MSG:          s8=     1
MSGA:         c=stk                 ; !!! doesn't work in DEC mode !!!!!
              sethex
              cxisa
              c=c+1   m
              stk=c                 ; point to P+2
MSGE:         rcr     11
              pt=     6             ; point to MSG entry
              lc      1             ; in QUAD 7
              lc      12
MSGX:         a=c     w
              gosub   CLLCDE
              acex    w
MSG100:       cxisa                 ; load a char
              c=c-1   m             ; point to next char
              a=c     x
              c=0     xs
              srsabc
              ?a#0    xs            ; is this the last char?
              gonc    MSG100        ; no

              .public MSG105        ;   called from Timer ROM
MSG105:       gosub   ENCP00        ; enable chip 0
              ?s8=1
              rtn nc
              gosub   PRT6
; * To conserve subroutine levels, the printer pops its return off
; * the stack and does a golong back to MSG110
              .public MSG110        ; for the printer
MSG110:       golong  MSGDLY        ; delay for viewing msg

                                       ; and set MSGFLG
; * Status set 0 is up from MSGDLY

              .public SIGMA
              .public STATCK
              .public CHSA
              .public BRT140
              .public BRT200
              .public CHSA1
              .public BRT160
              .public BRT290
              .public TRCS10
              .public TOREC
              .public ADD1
              .public ADD2
              .public TRG240
SIGMA:        gosub   STATCK
              c=regn  2
SIGMA1:       cnex
              c=n
              a=c     w
              ?s4=1
              gonc    SIGMA2
              gosub   GETX
              goto    SIGMA3
SIGMA2:       gosub   GETY
SIGMA3:       gosub   CHSA
              gosub   ADD2
              c=n
              a=c
              gsblng  MP2_10
              gosub   CHSA
              ?s4=1
              gonc    SIGMA4
              gosub   GETXSQ
              goto    SIGMA5
SIGMA4:       gosub   GETYSQ
SIGMA5:       gosub   ADD1
              c=0     x
              dadd=c
              c=regn  3
              ?s4=1
              goc     SIGMA6
              s4=     1
              goto    SIGMA1
SIGMA6:       a=c     w
              c=regn  2
              gsblng  MP2_10
              gosub   CHSA
              gosub   GETXY
              gosub   ADD1
              a=0     w
              a=a+1   pt
              gsubnc  CHSA
              gosub   GETN
              gosub   ADD2
              cnex
              c=0     w
              dadd=c
              c=regn  3             ; get old X
              regn=c  4             ; update LastX
              golong  PATCH9

; ******************************************************
; * This subroutine checks all stat registers for
; * alpha data. It starts at the highest address
; * and works down through the other five registers.
; ******************************************************
STATCK:       gosub   SUMCHK        ; CX=adr n, B=n
              pt=     6
              bcex
DOCHK:        gosub   CHK_NO_S      ; is this number?
              sethex                ; yes
              bcex                  ; get adr
              c=c-1   x
              dadd=c                ; adr register
              bcex                  ; save adr
              c=data                ; get nxt reg
              dec pt                ; count down
              ?pt=    0
              gonc    DOCHK         ; no
              c=0
              dadd=c
              goto    GET1
; *******************************************************
CHSA:         ?s5=1
              rtn nc
CHSA1:        acex    s
              c=-c-1  s
              acex    s
              rtn
ADD1:         gsblng  AD1_10
              goto    STOVF
ADD2:         gsblng  AD2_10
STOVF:        gsblng  OVFL10
              data=c
              pt=     12
              rtn
              .public GETN
              .public GETX
              .public GETXSQ
              .public GETY
              .public GETYSQ
              .public GETXY
              .public XBAR
GETN:         dec pt
GETXY:        dec pt
GETYSQ:       dec pt
GETY:         dec pt
GETXSQ:       dec pt
GETX:         sethex
              c=0
              dadd=c
              c=regn  13
              rcr     11
GETADD:       c=c+1   x
              inc pt
              ?pt=    13
              gonc    GETADD
              c=c-1   x
              dadd=c
              c=data
GET1:         setdec
              pt=     12
              rtn
XBAR:         gosub   STATCK
              gosub   GETY
              gosub   XBAR_
              cnex
              gosub   GETX
XBAR_:        a=c     w
              gosub   GETN
              bcex    w
              c=0     w
              dadd=c
              bcex    w
              golong  DV2_10
              .public XBAR
              .public SD
SD:           s5=     0
              gosub   STATCK
              gosub   GETYSQ
STDEV1:       a=c     w
              gosub   GETN
              gsblng  MP2_10
              gsblng  STSCR_
              ?s5=1
              goc     STDEV4
              gosub   GETY
              goto    STDEV5
STDEV4:       gosub   GETX
STDEV5:       a=c
              gsblng  MP2_10
              c=-c-1  s
              acex    s
              gsblng  RCSCR_
              gsblng  AD2_13
              gosub   GETN
              gsblng  DV1_10
              gsblng  STSCR_
              gosub   GETN
              b=0     w
              bcex    m
              a=c     w
              gsblng  SUBONE
              gsblng  RCSCR_
              gsblng  X_BY_Y13
              ?c#0    s
              golc    ERROF
              gsblng  SQR13
              ?s5=1
              rtn c
              cnex
              s5=     1
              gosub   GETXSQ
              goto    STDEV1
              .public BRT100
              .public TOPOL
              .public TRC30
              .public BRTS10
              .public TRG430
              .public TRG100
TOPOL:        c=n
              ?c#0    m
              gonc    TOPOL2
              ?c#0    s
              gonc    TOPOL1
              s7=     1
              s0=     1
              c=0     s
TOPOL1:       cnex
              a=c     w
              gosub   MP2_10        ; calc X^2
              gosub   STSCR
              c=regn  2
              a=c     w
              gosub   MP2_10        ; calc Y^2
              gosub   RCSCR
              gosub   AD2_13        ; calc X^2+Y^2
              gosub   SQR13         ; calc SQR(X^2+Y^2)
              cnex
              a=c     w
              c=regn  2
              acex    w
              gosub   DV2_10
              ?c#0    m
              goc     BRT110
              a=0     w
              goto    BRT110
BRTS10:       ?s0=1
              goc     BRTS20
              s0=     1
              rtn
BRTS20:       s0=     0
              rtn
TOPOL2:       acex    w
              s7=     1
              ?c#0    s
              gonc    TOPOL4
              s6=     1
TOPOL4:       c=0     s
              cnex
              c=n
              ?c#0    m
              rtn nc
TOPOL3:       a=0     w
              goto    BRT301
BRT120:       gosub   BRTS10
              goto    TOPOL3
BRT100:       b=0     w
              a=c     w
              abex    m
BRT110:       ?c#0    s
              gonc    BRT130
              s6=     1
              ?s2=1
              gonc    BRT130
              ?s0=1
              gonc    BRT130
              s0=     0
              s7=     1
              s6=     0
BRT130:       pt=     12
              acex    x
              a=c     x
              c=c+c   x
              golc    BRT140
BRT150:       ?a#0    x
              goc     BRT170
              c=b     w
              ?b#0    w
              gonc    TOPOL3
              pt=     12
              c=c-1   pt
              ?c#0    w
              goc     BRT170
              ?s1=1
              goc     BRT120
              gsblng  TRC10
              a=0     w
              a=a-1   x
              acex    w
              golong  BRT200
BRT170:       ?s1=1
              golc    ERR0
BRT160:       gsblng  ONE_BY_X13
              gosub   BRTS10
BRT290:       abex    w
              c=b     w
              pt=     12
              c=0     m
              c=0     s
BRT300:       c=c+1   x
              ?c#0    x
              gonc    BRT310
              c=c+1   s
              dec pt
              ?pt=    6
              gonc    BRT300
              bcex    w
BRT301:       golong  BRT200
BRT310:       cmex
              c=0     w
              c=c+1   s
              csr     w
              goto    BRT340
BRT320:       acex    w
              cmex
              c=c+1   pt
              a=c     s
              cmex
BRT330:       bsr     w
              bsr     w
              a=a-1   s
              gonc    BRT330
              a=0     s
              a=a+b   w
              acex    w
BRT340:       b=a     w
              a=a-c   w
              gonc    BRT320
              cmex
              c=c+1   s
              cmex
              abex    w
              asl     w
              dec pt
              ?pt=    6
              gonc    BRT340
              bcex    w
              gsblng  DIV120
              abex    w
              cmex
              c=0     x
              pt=     7
BRT350:       bcex    w
              gosub   TRC30
              bcex    w
              goto    BRT370
BRT360:       a=a+b   w
BRT370:       c=c-1   pt
              gonc    BRT360
              asr     w
              c=0     pt
              ?c#0    m
              gonc    BRT190
              inc pt
              goto    BRT350
BRT140:       ?s1=1
              gonc    BRT141
              gsblng  STSCR
              gsblng  ADDONE
              gsblng  EXSCR
              gsblng  SUBONE
              gsblng  RCSCR
              gsblng  MP2_13
              a=0     s
              gsblng  SQR13
              c=n
              c=0     s
              cmex
              c=m
              c=0     x
              gsblng  X_BY_Y13
              acex    x
              a=c     x
              c=c+c   x
              golnc   BRT160
BRT141:       golong  BRT290
BRT180:       inc pt
BRT190:       c=c-1   x
              ?pt=    12
              gonc    BRT180
BRT200:       c=0     s
              gsblng  SHF10
              ?s0=1
              gonc    BRT220
              c=-c-1  s
              acex    s
              gsblng  PI_BY_2
              gsblng  AD2_13
BRT220:       ?s7=1
              gonc    BRT240
              gsblng  PI_BY_2
              gsblng  AD2_13
BRT240:       ?s4=1
              goc     BRT250
              gsblng  PI_BY_2
              a=a+1   x
              a=a+1   x
              nop
              gsblng  DV2_13
              ?s5=1
              goc     BRT250
              c=0     w
              pt=     12
              c=c-1   x
              lc      9
              gsblng  MP1_10
BRT250:       ?s6=1
              gonc    BRT260
              c=-c-1  s
BRT260:       ?s2=1
              rtn c
              cnex
              rtn
TRC30:        c=0     w
              c=c-1   w
              c=0     s
              ?pt=    12
              goc     TRC90
              ?pt=    11
              goc     TRC50
              ?pt=    10
              goc     TRC60
              ?pt=    9
              goc     TRC70
              ?pt=    8
              goc     TRC80
              pt=     0
TRC35:        lc      7
TRC40:        pt=     7
              rtn
TRC90:        pt=     10
              lc      6
              lc      6
              lc      8
              lc      6
              lc      5
              lc      2
              lc      4
              lc      9
              lc      1
              lc      1
              lc      6
TRC91:        pt=     12
              rtn
TRCS10:       lc      6
              ?pt=    0
              gonc    TRCS10
              goto    TRC35
TRC50:        pt=     8
              gosub   TRCS10
              pt=     0
              lc      5
              pt=     4
              lc      8
              pt=     11
              rtn
TRC60:        pt=     6
              gosub   TRCS10
              pt=     0
              lc      9
              pt=     10
              rtn
TRC70:        pt=     4
              gosub   TRCS10
              pt=     9
              rtn
TRC80:        pt=     2
              gosub   TRCS10
              pt=     8
              rtn
TOREC:        s2=     1
              s1=     1
              acex    w
TRG100:       a=0     w
              b=0     w
              acex    m
              ?c#0    s
              gonc    TRG130
              s7=     1
              ?s1=1
              gonc    TRG110
              ?s0=1
              gonc    TRG120
TRG110:       s6=     1
TRG120:       c=0     s
TRG130:       bcex    w
              ?s4=1
              golc    TRG240
              ?s5=1
              gonc    TRG135
              acex    w
              a=c     w
              csr     w
              a=a-c   w
TRG135:       c=0     w
              pt=     12
              lc      4
              lc      5
              bcex    w
              c=c-1   x
              ?c#0    xs
              goc     TRG140
              c=c-1   x
              gonc    TRG140
              c=c+1   x
              asr     w
TRG140:       bcex    w
TRG150:       cmex
              c=m
              c=c+c   w
              c=c+c   w
              c=c+c   w
              csr     w
              bcex    w
              ?c#0    xs
              goc     TRG180
TRG155:       a=a-b   w
              gonc    TRG155
              a=a+b   w
              asl     w
              c=c-1   x
              gonc    TRG155
              c=0     w
              bcex    w
              c=m
              c=c+c   w
              ?s4=1
              gonc    TRG160
              asr     w
              csr     w
TRG160:       bcex    w
TRG170:       a=a-b   w
              gonc    TRG190
              a=a+b   w
TRG180:       bcex    w
              c=m
              bcex    w
              ?s4=1
              gonc    TRG270
              ?c#0    x
              goc     TRG260
              asl     w
              goto    TRG270
TRG190:       ?s0=1
              goc     TRG220
              s0=     1
TRG200:       ?s6=1
              goc     TRG210
              s6=     1
              goto    TRG170
TRG210:       s6=     0
              goto    TRG170
TRG220:       s0=     0
              ?s1=1
              gonc    TRG200
              ?s7=1
              gonc    TRG230
              s7=     0
              goto    TRG170
TRG230:       s7=     1
              goto    TRG170
TRG240:       gsblng  TRC10
              goto    TRG150
TRG250:       abex    w
              a=a-b   w
              nop
              gosub   BRTS10
              goto    TRG280
TRG260:       c=c+1   x
TRG270:       ?c#0    xs
              goc     TRG280
              a=a-b   w
              gonc    TRG250
              a=a+b   w
TRG280:       c=c-1   x
              nop
              gsblng  SHF10
              ?s4=1
              goc     TRG300
              c=m
              c=c+c   w
              c=c-1   x
              nop
              gsblng  DV1_10
              gsblng  PI_BY_2
              gsblng  MP2_13
TRG300:       cmex
              acex    w
              a=c     w
              c=c+1   x
              gonc    TRG310
              abex    w
              asl     w
              goto    TRG330
TRG305:       dec pt
              ?pt=    6
              goc     TRG315
TRG310:       c=c+1   x
              gonc    TRG305
              abex    w
TRG330:       c=0     w
TRG340:       bcex    w
              gosub   TRC30
              bcex    w
              goto    TRG800
TRG810:       c=c+1   s
TRG800:       a=a-b   w
              gonc    TRG810
              a=a+b   w
              dec pt
              csr     w
              asl     w
              ?pt=    6
              gonc    TRG340
              cmex
              asr     w
              asr     w
              c=0     w
              pt=     12
              lc      1
              cmex
              pt=     0
              lc      6
              lc      6
              goto    TRG370
TRG350:       asr     wpt
              asr     wpt
TRG360:       a=a-1   s
              gonc    TRG350
              a=0     s
              cmex
              acex    w
              c=a-c   w
              a=a+b   w
              cmex
TRG370:       b=a     w
              a=c     s
              c=c-1   pt
              gonc    TRG360
              acex    w
              asl     m
              acex    w
              ?c#0    m
              gonc    TRG400
              c=c-1   s
              c=c-1   x
              a=0     s
              asr     w
              goto    TRG370
TRG315:       c=m
              ?s2=1
              goc     TRG430
              ?s0=1
              gonc    TRG430
              gsblng  ONE_BY_X13
              goto    TRG430
TOREC1:       c=n
              cmex
              c=m
              c=0     x
              gsblng  X_BY_Y13
              cnex
              gsblng  RCSCR
              gsblng  MP2_13
              ?s0=1
              gonc    TOREC2
              cnex
TOREC2:       ?s7=1
              gonc    TOREC3
              c=-c-1  s
TOREC3:       cnex
              goto    TRG500
TRG400:       c=0     s
              cmex
              acex    w
              c=m
              a=a-1   w
              ?s2=1
              goc     TRG415
              ?s0=1
              goc     TRG420
TRG415:       c=-c    x
              abex    w
TRG420:       ?b#0    m
              gonc    TRG440
              cmex
              gsblng  DIV15
TRG430:       ?s1=1
              gonc    TRG500
              gsblng  STSCR
              gsblng  RCSCR
              gsblng  MP2_13
              gsblng  ADDONE
              gsblng  SQR13
              ?s2=1
              goc     TOREC1
              gsblng  ONE_BY_X13
TRG500:       ?s6=1
              rtn nc
              c=-c-1  s
              rtn
TRG440:       c=0     w
              pt=     12
              c=c-1   wpt
              c=0     xs
              a=c     w
              b=a     w
              ?s1=1
              rtn nc
              goto    TRG430
              nop                   ; PRESERVE ENTRY POINT ADDRESSES
              .public TODEC
              .public TOOCT
; ********************************************
; *   IF S4=1, THEN DOING TO DECIMAL         *
; *   IF S4=0, THEN DOING TO OCTAL           *
; ********************************************
TOOCT:        gsblng  INTFRC
              ?c#0    m
              golc    ERR0
              c=n
              ?s4=1
              goc     TODEC
              a=c     w
              a=0     s
              c=0     w
              pt=     12
              c=c-1   x
              lc      3
              gsblng  AD2_10
              c=0     w
              lc      1
              lc      0
              lc      7
              lc      3
              lc      7
              lc      4
              lc      1
              lc      8
              lc      2
              lc      4
              pt=     0
              lc      9
              gsblng  DV1_10
              ?c#0    xs
              golnc   ERR0
              sel q
              pt=     8
              sel p
              pt=     0
              abex    w
              goto    TOOCT2
TOOCT1:       asr     w
TOOCT2:       c=c+1   x
              gonc    TOOCT1
              c=0     w
              acex    w
TOOCT3:       c=c+c   w
              c=c+c   w
              c=c+c   w
              asl     w
              rcr     13
              sel p
              acex    pt
              sel q
              csr     w
              dec pt
              ?pt=    12
              gonc    TOOCT3
              goto    TODEC6
TODEC:        pt=     0
              c=0     pt
              ?c#0    x
              golc    ERR0
              c=n
TODEC1:       c=c+1   pt
              goc     TODEC2
              csr     m
              goto    TODEC1
TODEC2:       acex    w
              a=a-1   pt
              c=0     w
              b=0     w
              pt=     12
              lc      8
              pt=     12
              bcex    w
TODEC7:       ?a<b    pt
              goc     TODEC4
              golong  ERR0
TODEC3:       c=c+1   w
TODEC4:       a=a-1   pt
              gonc    TODEC3
              a=a-1   x
              goc     TODEC5
              c=c+c   w
              c=c+c   w
              c=c+c   w
              asl     m
              goto    TODEC7
TODEC5:       acex    w
TODEC6:       c=n
              c=0     wpt
              pt=     1
              lc      1
              lc      2
              golong  SHF10

; *
; * GTACOD - get alphacode[keycode]
; * Gets the alphamode default function table entry for the
; * current key.  Used by NAMEA and stk sections of PARSE.
; * ENTRY CONDITIONS: chip 0 on, logical keycode in N[2:1]
; * USES A.X and C.
; * Returns alphacode[keycode] in C.X
; *
GTACOD:       c=n
              a=c     x
              c=0
              ldi     0x155
              rcr     12
              c=a+c   x
              rcr     12
              cxisa
              rtn

; *
; * TOGSHF - toggle shift flag
; *
; * USES C and 1 subroutine level.  Leaves chip 0 enabled.
; *
; * TGSHF1 - same as TOGSHF except requires chip 0 enabled on entry.
; *
TOGSHF:       gosub   ENCP00
TGSHF1:       c=regn  14
              rcr     2
              cstex                 ; put up SS1
              ?s0=1                 ; shift?
              goc     TOG10         ; yes
              s0=     1             ; no. set shift.
              goto    TOG20
TOG10:        s0=     0             ; clear shift
TOG20:        cstex
              rcr     12
              regn=c  14
              rtn
              .public APND_
              .public APND10
              .public APNDDG
APND_:        ldi     45
APND10:       pt=     0
APND15:       g=c
              sel p
              golong  APNDNW
APNDDG:       c=m
              inc pt
              lc      3
              goto    APND15

; * Reserve 2 words at the end of CN7 for chip 1 checksum and
; * trailer.
              .fillto 0x3fe
REVLV1:       .con    6             ; REV level= F
CKSUM1:       .con    0

