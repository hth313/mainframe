;;; This is HP41 mainframe resurrected from list file output. QUAD 6
;;;
;;; REV.  6/81A
;;; Original file CN6B
;;;

#include "hp41cv.h"

              .SECTION QUAD6

; *****************************************************
; *   Nut math ROM 1                                  *
; * HP41C mainframe microcode addresses @14000-15777  *
; *****************************************************
; ******************************************************
; *      Common math entries                         ***
; *          If number is 2-10,                      ***
; *             then form is:                        ***
; *                A has 10-digit form               ***
; *                C has 10-digit form               ***
; *          If number is 1-10,                      ***
; *             then form is:                        ***
; *                A has SIGN and EXP                ***
; *                B has 13-digit mantissa           ***
; *                C has 10-digit form               ***
; *          If number is 2-13,                      ***
; *             then form is:                        ***
; *                A and B as in 1-10                ***
; *                M has SIGN and EXP                ***
; *                C has 13-digit mantissa           ***
; *                                                  ***
; *       ON EXIT, C has 10-digit form               ***
; *                A and B have 13-digit form        ***
; *                                                  ***
; ******************************************************

              .public AD1_10
              .public AD2_10
              .public AD2_13
              .public ADDONE
              .public DIV110
              .public DIV120
              .public DIV15
              .public DV1_10
              .public DV2_10
              .public DV2_13
              .public ERR0
              .public LN10
              .public LNC10_
              .public MP1_10
              .public MP2_10
              .public MP2_13
              .public MPY150
              .public NRM10
              .public NRM11
              .public NRM12
              .public NRM13
              .public ONE_BY_X10
              .public ONE_BY_X13
              .public SHF10
              .public SHF40
              .public SQR10
              .public SQR13
              .public SUBONE
              .public XLN1_PLUS_X
              .public XY_TO_X
              .public X_BY_Y13

ADDONE:       c=0     w
              goto    SUBON1
SUBONE:       c=0     w
              c=-c-1  s
SUBON1:       pt=     12
              lc      1
              goto    AD1_10
AD2_10:       b=0     w
              abex    m
AD1_10:       cmex                  ; these 2 states could
              c=m                   ;   be just "m=c"
              c=0     x
AD2_13:       b=0     s
              c=0     s
              cmex
              pt=     1
ADD10:        dec pt
              a=a+1   xs
              c=c+1   xs
              ?pt=    12
              gonc    ADD10
              bcex    w
              ?c#0    w
              gonc    ADD60
              cmex
              abex    w
              ?c#0    w
              gonc    ADD60
ADD30:        ?a<b    x
              goc     ADD65
ADD90:        cmex
              abex    w
              ?a<b    x
              goc     ADD30
ADD45:        acex    w
              cmex
              ?a<c    w
              gonc    ADD55
              cmex
              acex    w
              goto    ADD65
ADD55:        cmex
              acex    w
              cmex
              abex    w
ADD65:        a=a-b   s
              ?a#0    s
              gonc    ADD50
ADD40:        c=-c    w
              a=c     s
              ?a<b    x
              gonc    ADD50
              cmex
              rcr     13
              cmex
              abex    w
              a=a-1   x
              abex    w
ADD50:        ?a<b    x
              gonc    ADD60
              a=a+1   x
              csr     w
              acex    s
              a=c     s
              dec pt
              ?pt=    13
              gonc    ADD50
              c=0     w
ADD60:        acex    w
              c=m
              bcex    w
              a=a+b   w
              c=c-1   xs
              c=c-1   xs
              c=c-1   xs
              nop
              goto    MPY150
MP2_10:       b=0     w
              abex    m
MP1_10:       cmex
              c=m
              c=0     x
MP2_13:       b=0     s
              c=0     s
              cmex
              c=a+c   x
              c=a-c   s
              gonc    MPY110
              c=-c    s
MPY110:       a=0     w
              cmex
              pt=     13
MPY120:       inc pt
              asr     w
              goto    MPY140
MPY130:       a=a+b   w
MPY140:       c=c-1   pt
              gonc    MPY130
              ?pt=    12
              gonc    MPY120
              c=m
MPY150:       acex    w             ; ***ROUND, SHIFT AND NORMALIZE
              cmex
              c=m
MPY160:       ?c#0    s
              gonc    SHF40
              a=a+1   x
              csr     w
SHF40:        acex    w
SHF10:        pt=     12
              ?a#0    wpt
              goc     SHF20
NRM10:        bcex    w
NRM11:        acex    w
NRM12:        pt=     12
              a=c     w
              c=c+c   x
              gonc    NRM20
              c=c+1   m
              gonc    NRM20
              c=b     x
              c=c+1   x
              c=c+1   pt
NRM30:        c=b     s
              abex    w
              ?c#0    m
              rtn c
              c=0     w
              a=0     s
NRM40:        rtn
NRM20:        c=b     x
              goto    NRM30
NRM13:        abex    w
              goto    NRM11
SHF20:        ?a#0    pt
              goc     NRM10
              c=c-1   x
              asl     wpt
              goto    SHF20
ONE_BY_X10:   b=0     w
              bcex    m
              acex    w
ONE_BY_X13:   c=0     w
              cmex
              c=0     w
              pt=     12
              lc      1
X_BY_Y13:     bcex    w
              acex    w
              cmex
              acex    w
              goto    DV2_13
DV2_10:       b=0     w
              abex    m
DV1_10:       cmex
              c=m
              c=0     x
DV2_13:       b=0     s
              ?c#0    m
              gonc    ERR0
DIV100:       cmex
              c=a-c   x
              c=a-c   s
              gonc    DIV110
              c=-c    s
DIV110:       cmex
              c=0     s
              acex    w
              abex    w
DIV15:        ?a<b    W
              gonc    DIV120
              cmex
              asl     w
              c=c-1   x
              cmex
DIV120:       pt=     12
              c=0     w
              goto    DIV140
DIV130:       c=c+1   pt
DIV140:       a=a-b   w
              gonc    DIV130
              a=a+b   w
              asl     w
              dec pt
              ?pt=    13
              gonc    DIV140
              acex    w
              c=m
              golong  NRM10
SQR10:        b=0     w             ; ***square root
              bcex    M
              acex    w
SQR13:        ?a#0    s
              gonc    SQR20
ERR0:         golong  ERRDE         ; ***error exit
SQR20:        b=0     s
              c=b     w
              abex    w
              c=c+c   w
              c=c+c   w
              c=a+c   w
              bcex    w
              c=0     m
              a=c     w
              c=c+c   w
              c=c+c   x
              gonc    SQR30
              c=-c-1  m
SQR30:        a=a+c   w
              pt=     0
              ?a#0    pt
              goc     SQR50
              bsr     w
SQR50:        asr     w
              c=0     w
              abex    w
              pt=     13
              lc      5
              csr     w
              goto    SQR100
SQR60:        c=c+1   pt
SQR70:        a=a-c   w
              gonc    SQR60
              a=a+c   w
              asl     w
              ?pt=    0
              golc    NRM12
              dec pt
SQR100:       csr     wpt
              goto    SQR70
              .public XFT100
XFT120:       a=a-1   x
              gonc    XFT110
              goto    ERR0
XFT100:       ?c#0    s
              goc     ERR0
              ?c#0    xs
              goc     ERR0
              a=c     w
XFT110:       b=a     w
              pt=     3
              asl     w
              asr     wpt
              pt=     12
              ?a#0    wpt
              goc     XFT120
              a=a+1   x
              legal
              ?a<c    x
              gonc    XFT130
              c=c+1   xs
              rtn
XFT130:       c=0     w
              c=c+1   pt
              csr     w
              c=c+1   s
              bcex    w
XFT140:       ?b#0    pt
              gonc    XFT150
              bsr     wpt
              c=c+1   x
XFT150:       a=0     w
              a=a-c   pt
              gonc    XFT170
              asl     w
XFT160:       a=a+b   w
              gonc    XFT160
XFT170:       a=a-c   s
              gonc    XFT190
              asr     wpt
              a=a+1   w
              c=c+1   X
XFT180:       a=a+b   w
              gonc    XFT180
XFT190:       abex    wpt
              c=c-1   pt
              gonc    XFT140
              c=c-1   s
              gonc    XFT140
              asl     w
              b=a     x
              c=0     m
              c=0     s
              a=a+b   wpt
              a=a+c   w
              acex    m
              rtn
; ****************************************************
; *   Math scratch routines                          *
; *                                                  *
; *     STSCR stores S and 13-digit mantissa in      *
; *           REGN 9 and EXP in REGN 10, leaving     *
; *           A and B alone                          *
; *     RCSCR recalls math scratch into C and M,     *
; *           leaving A and B alone                  *
; *     EXSCR exchanges A and B with the math        *
; *           scratch registers, destroying C        *
; ****************************************************
              .public STSCR
              .public RCSCR
              .public EXSCR
              .public RCSCR_
              .public STSCR_
STSCR_:       c=0     w
              dadd=c
STSCR:        b=a     s
              c=b     w
              regn=c  9
              c=regn  10
              acex    x
              a=c     x
STSCR1:       regn=c  10
              rtn
EXSCR:        abex    s
              c=regn  9
              bcex    w
              regn=c  9
              c=regn  10
              acex    X
              abex    s
              goto    STSCR1
RCSCR_:       c=0
              dadd=c
RCSCR:        c=regn  9
              bcex    s
              cmex
              c=regn  10
              c=b     s
              cmex
              rtn
              .public INTFRC
              .public SINFR
              .public SINFRA
              .public MOD10
              .public DTOR
              .public RTOD
              .public LD90
              .public PI_BY_2
              .public TRC10
; *************************************************
; *     If S5=1, then routine INTFRC finds INT    *
; *     If S5=0, INTFRC finds fractional part     *
; *************************************************
INTFRC:       gosub   SINFR
              ?s5=1
              golnc   SHF10
              c=m
; * Next two states are a holdover from a version of INTFRC which
; * worked for 13-digit arithmetic.  Not necessary here.
              ?pt=    0
              goc     INT30
              dec pt
              c=0     wpt
INT30:        golong  NRM12
SINFR:        b=0     w
              bcex    m
              acex    w
SINFRA:       pt=     13
              c=b     w
              cmex
              abex    w
              c=b     w
              ?c#0    xs
              rtn c
              c=c+1   x
SINFR1:       ?c#0    x
              gonc    SINFR2
              c=c-1   X
              asl     w
              a=0     s
              dec pt
              ?a#0    w
              goc     SINFR1
SINFR2:       c=c-1   x
              rtn
MOD10:        a=a+1   xs
              ?c#0    m
              gonc    MOD5
              c=c+1   XS
              ?a#c    s
              gonc    MOD1
              s4=     1
MOD1:
              c=a-c   x
              gonc    MOD2
MOD5:         a=a-1   xs
              acex    w
              goto    MOD4
MOD2:         b=0     w
              cnex
              acex    s
              cnex
              a=0     s
              a=0     x
              bcex    m
MOD3:         a=a-b   w
              gonc    MOD3
              a=a+b   w
              asl     w
              c=c-1   x
              gonc    MOD3
              asr     w
              c=n
              gsblng  SHF10
MOD4:         ?s4=1
              rtn nc
              ?c#0    m
              rtn nc
              a=c     w
              c=regn  3
              golong  AD2_10
DTOR:         a=0
              gosub   PI_BY_2
              bcex    w
              c=n
              gsblng  MP1_10
              gosub   LD90
              golong  DV1_10
RTOD:         a=c
              gosub   LD90
              gsblng  MP2_10
              gosub   PI_BY_2
              golong  DV2_13
LD90:         c=0     w
              pt=     12
              c=c+1   x
              lc      9
              rtn
PI_BY_2:      c=0     w
              cmex
              gosub   TRC10
              c=c+c   w
              csr     w
              rtn
TRC10:        pt=     12
              c=0     w
              lc      7
              lc      8
              lc      5
              lc      3
              lc      9
              lc      8
              lc      1
              lc      6
              lc      3
              lc      3
              lc      9
              lc      7
              lc      5
              pt=     12
              rtn
              .public XTOHRS
              .public HMSMP
              .public HMSDV
; ************************************************
; *    If to H.MMSS, then S5=1                   *
; *    If to H.DDDD, then S5=0                   *
; ************************************************
XTOHRS:       ?c#0    m
              rtn nc
              a=c     w
              b=a     w
              c=c+1   x
              c=c+1   x
              a=c     x
              pt=     12
              a=a+c   x
              goc     HMS140
HMS110:       dec pt
              ?pt=    0
              gonc    HMS130
HMS120:       c=b     w
              rtn
HMS130:       c=c-1   x
              gonc    HMS110
HMS140:       c=0     w
              c=b     m
              ?s5=1
              gonc    HRS100
              inc pt
              ?pt=    13
              gonc    HMS150
              gosub   HMSMP
              goto    HMS160
HMS150:       inc pt
              gosub   HMSMP
              dec pt
HMS160:       dec pt
              legal
              gosub   HMSMP
              a=c     w
              c=b     w
HMS170:       golong  MPY150
HRS100:       a=0     w
              gosub   HMSDV
              inc pt
              ?pt=    13
              goc     HRS120
              inc pt
HRS120:       gosub   HMSDV
              asl     w
              a=a+c   w
              bcex    w
              goto    HMS170
HMSDV:        csr     wpt
              c=a+c   wpt
HMSMP:        a=c     wpt
              csr     wpt
              c=c+c   wpt
              c=c+c   wpt
              c=a-c   wpt
              ?s5=1
              gonc    HMSM20
              a=0     w
              a=c     X
              c=a+c   w
              c=0     X
              rtn
HMSM20:       a=a+c   wpt
              csr     wpt
              ?c#0    wpt
              goc     HMSM20
              rtn
              .public EXP710
              .public LN560
              .public PMUL
              .public LNSUB
              .public LNSUB_MINUS
              .public LNC20
              .public LNAP
              .public EXP10
              .public EXP13
              .public TEN_TO_X
              .public LNC10
              .public EXP500
              .public EXP400
              .public EXP720
LNSUB_MINUS:  c=-c-1  s
LNSUB:        abex    w
              b=a     w
              cmex
              c=m
LNSUB1:       asr     w
              ?a#0    w
              goc     LNSUB2
              c=m
              a=c     w
              rtn
LNSUB2:       c=c+1   x
              gonc    LNSUB1
              pt=     12
              a=a+1   pt
              abex    w
              golong  DIV15
EXP10:        b=0     w             ; ***exp(X)
              bcex    m
              acex    w
EXP13:        s3=     0
              ?a#0    s
              gonc    EXP110
              s3=     1
EXP110:       a=0     s
              a=0     m
              abex    w
              c=b     w
              c=c+c   x
              gonc    EXP200
              c=b     w
              ?a#0    s
              goc     EXP120
              pt=     13
EXP130:       dec pt
              ?pt=    5
              golc    EXP500
              c=c+1   x
              gonc    EXP130
EXP400:       gsblng  LNC20
              goto    EXP420
EXP200:       gosub   LNC10
              pt=     6
              goto    EXP220
EXP120:       abex    w
              a=a+1   x
              bsr     w
              goto    EXP110
EXP210:       c=c+1   m
EXP220:       a=a-b   w
              gonc    EXP210
              a=a+b   w
              asl     w
              c=c-1   x
              gonc    EXP230
              pt=     5
              ?c#0    pt
              gonc    EXP240
              c=c-1   pt
              ?c#0    pt
              goc     EXP300
              c=c+1   pt
EXP240:       pt=     12
              goto    EXP430
EXP230:       acex    w
              asl     m
              acex    w
              ?c#0    pt
              gonc    EXP220
EXP300:       c=0     w
              pt=     12
              c=c-1   wpt
              a=c     w
              pt=     2
              lc      1
              ?s3=1
              gonc    EXP700
              c=-c-1  x
EXP700:       abex    w
              a=c     w
EXP710:       ?s4=1
              gonc    EXP720
              gsblng  SUBONE
EXP720:       ?s7=1
              gonc    EXP730
              c=-c-1  s
              a=c     s
EXP730:       golong  NRM13
EXP410:       c=c+1   pt
EXP420:       a=a-b w
              gonc    EXP410
              a=a+b   w
              ?pt=    6
              goc     EXP510
              asl     w
              c=c-1   x
              dec pt
EXP430:       bcex    w
              goto    EXP400
EXP500:       bcex    w
EXP510:       ?s4=1
              gonc    EXP570
              gosub   LNAP
              acex    w
              abex    w
EXP570:       pt=     13
              lc      6
              pt=     5
EXP550:       ?c#0    m
              gonc    EXP600
              inc pt
EXP560:       ?c#0    pt
              gonc    EXP520
              c=c-1   pt
              b=a     w
              cmex
              c=m
              goto    EXP530
EXP520:       c=c+1   x
              asr     w
              c=c-1   s
              gonc    EXP550
              csr     w
              csr     w
              csr     w
              a=a+1   pt
              abex    w
              a=c     w
              ?s3=1
              gsubc   ONE_BY_X13
              goto    EXP710
EXP540:       bsr     w
EXP530:       c=c-1   s
              gonc    EXP540
              a=a+b w
              a=a+1   s
              c=m
              goto    EXP560
LNAP:         cmex
              c=m
              b=a     w
              bcex    w
              c=c+c   w
              c=c+c   w
              c=a+c   w
              abex    w
LNAP1:        csr     w
              ?c#0    w
              goc     LNAP2
              c=m
              acex    w
              rtn
LNAP2:        a=a+1   x
              gonc    LNAP1
              c=-c    w
              cmex
              c=c+1   x
              legal
              golong  DIV110
EXP600:       abex    w
              c=0     m
              c=0     s
              a=c     w
              ?s3=1
              gonc    EXP740
              gsblng  LNSUB_MINUS
EXP740:       ?s4=1
              goc     EXP750
              gsblng  ADDONE
EXP750:       golong  EXP720
LNC10_:       bcex    w
LNC10:        pt=     12
              lc      2
              lc      3
              lc      0
              lc      2
              lc      5
              lc      8
              lc      5
              lc      0
              lc      9
              lc      2
              lc      9
              lc      9
              lc      4
              goto    LNCEND
LNC20:        c=0     w
              ?pt=    12
              goc     LNC30
              c=c-1   m
              lc      4
              c=c+1   m
              ?pt=    10
              goc     LNC40
              ?pt=    9
              goc     LNC50
              ?pt=    8
              goc     LNC60
              ?pt=    7
              goc     LNC70
              ?pt=    6
              goc     LNC80
              pt=     0
              lc      3
              pt=     6
              goto    LNCEND
LNC30:        lc      6
              lc      9
              lc      3
              lc      1
              lc      4
              lc      7
              lc      1
              lc      8
              lc      0
              lc      5
              lc      6
              pt=     12
LNCEND:       bcex    w
              rtn
              nop                   ; PRESERVE ENTRY POINT ADDRESSES
LNC40:        lc      3
              lc      1
              lc      0
              lc      1
              lc      7
              lc      9
              lc      8
              lc      0
              lc      4
              lc      3
              lc      3
              pt=     11
              goto    LNCEND
LNC50:        pt=     8
              lc      3
              lc      3
              lc      0
              lc      8
              lc      5
              lc      3
              lc      1
              lc      6
              lc      8
              pt=     10
              goto    LNCEND
LNC60:        pt=     6
              lc      3
              lc      3
              lc      3
              lc      0
              lc      8
              lc      3
              lc      5
              pt=     9
              goto    LNCEND
LNC70:        pt=     4
              lc      3
              lc      3
              lc      3
              lc      3
              lc      1
              pt=     8
              goto    LNCEND
LNC80:        pt=     2
              lc      3
              lc      3
              lc      3
              pt=     7
              goto    LNCEND
XY_TO_X:      b=0     w
              bcex    m
              acex    w
              gosub   STSCR
              c=regn  2
              gosub   CHK_NO_S
              a=c     w
              c=regn  3
              ?a#0    s
              gonc    YX13
              a=0     x
              acex    m
              ?c#0    xs
              gonc    YX11
`ERR0*`:      golong  ERR0
YX12:         ?c#0    x
              gonc    `ERR0*`
              c=c-1   x
YX11:         asl     w
              ?a#0    m
              goc     YX12
              ?c#0    x
              goc     YX13
              acex    s
              a=c     s
              c=c+c   s
              c=c+c   s
              c=a+c   s
              ?c#0    s
              gonc    YX13
              s7=     1
YX13:         c=regn  2
              c=0     s
YXTEN:        b=0     w
              bcex    m
              acex    w
YX31:         s1=     1
              ?b#0    m
              goc     LN13
              gosub   RCSCR
              ?c#0    m
              gonc    `ERR0*`
              c=m
              ?c#0    s
              goc     `ERR0*`
              b=0     w
              golong  NRM13
LN10:         b=0     w
              bcex    m
              acex    w
LN13:         b=0     s
              ?a#0    s
              goc     `ERR0*`
              ?b#0    m
              gonc    `ERR0*`
              acex    x
              a=c     x
              ?c#0    x
              gonc    LN220
              a=a+c   x
              gonc    LN140
              c=-c-1  x
              s3=     1
LN140:        a=0     w
              c=0     s
              c=0     m
              pt=     12
              a=a-b   wpt
              c=c-1   pt
LN310:        c=c+1   pt
LN300:        b=a     w
              cmex
              c=m
              goto    LN330
LN220:        pt=     12
              c=b     w
              c=c-1   pt
              acex    w
              ?a#0    w
              golnc   LN560
LN200:        ?a#0    pt
              goc     LN210
              c=c-1   x
              asl     w
              goto    LN200
LN210:        cmex
              gosub   DIV15
              goto    `LN1+X6`
`LN1+X2`:     gosub   ADDONE
              goto    LN13
XLN1_PLUS_X:  b=0     w
              bcex    m
              a=c     w
              acex    w
              a=c     w
              c=c+1   x
              c=c+c   x
              gonc    `LN1+X2`
              ?a#0    s
              goc     `LN1+X3`
              acex    w
              gosub   LNSUB
`LN1+X6`:     pt=     12
              c=0     w
              acex    X
              a=c     w
              abex    w
              goto    `LN1+X7`
`LN1+X3`:     s3=     1
              goto    `LN1+X6`
`LN1+X8`:     ?pt=    6
              goc     LN410
              dec pt
              c=c+1   s
`LN1+X7`:     c=c+1   x
              gonc    `LN1+X8`
              goto    LN300
LN320:        asr     w
LN330:        c=c-1   s
              gonc    LN320
              c=m
              a=a+b   w
              a=a-1   s
              gonc    LN310
              c=c+1   s
              abex    w
              asl     w
              dec pt
              ?pt=    5
              gonc    LN300
              acex    w
              b=a     w
              asl     wpt
              asl     wpt
              asl     wpt
              acex    w
              pt=     0
              lc      7
              c=-c    x
              ?b#0    x
              gonc    LN420
              pt=     6
LN460:        asr     w
LN430:        bcex    w
LN431:        gosub   LNC20
              gosub   PMUL
              ?c#0    m
              gonc    LN530
              ?pt=    13
              gonc    LN460
              b=0     w
              pt=     0
              b=a     pt
              a=a+b   w
              asr     w
LN500:        gosub   LNC10_
              ?s3=1
              goc     LN570
              abex    w
              a=a-b   w
              abex    w
              a=a+b   w
              abex    w
LN570:        pt=     3
LN520:        gosub   PMUL
              ?c#0    m
              gonc    LN530
              asr     w
              goto    LN520
LN410:        bcex    w
              goto    LN400
LN540:        asr     w
              goto    LN550
LN530:        ?a#0    s
              goc     LN540
              c=c-1   x
LN550:        c=0     s
              ?s3=1
              gonc    LN560
              c=-c-1  s
              nop
LN560:        gosub   SHF10
              ?s1=1
              gonc    LN580
              gosub   RCSCR
              gosub   MP2_13
YTOX50:       c=m
YTOX60:       ?c#0    s
              golnc   EXP13
              a=a-1   x
              bcex    w
              goto    YTOX60
LN420:        asr     w
LN400:        gosub   LNAP
              abex    w
              pt=     6
              goto    LN431
PMUL1:        a=a+b   w
PMUL:         c=c-1   pt
              gonc    PMUL1
              c=0     pt
              c=c+1   x
              inc pt
              rtn
LN580:        ?s5=1
              rtn nc
              c=0     W
              cmex
              gosub   LNC10
              bcex    w
              golong  DV2_13
TEN_TO_X:     a=0     w
              gsblng  LNC10
              c=n
              gsblng  MP1_10
              goto    YTOX50
