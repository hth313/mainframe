;;; This is HP41 mainframe resurrected from list file output. QUAD 4
;;;
;;; REV.  6/81A
;;; Original file CN4B
;;;

#include "hp41cv.h"

; * HP41C mainframe microcode addresses @10000-11777
; * Contents:
; * 1. Execution points for mainframe functions (must be in
; *    @10000-11736)

              .section QUAD4

              .public ABS
              .public ACOS
              .public ADVNCE
              .public AGTO
              .public AOFF
              .public AON
              .public ARCL
              .public ASHF
              .public ASIN
              .public ASN
              .public ASTO
              .public ATAN
              .public AVIEW
              .public AXEQ
              .public BEEP
              .public BST
              .public CAT
              .public CAT3
              .public CF
              .public CHS
              .public CLA
              .public CLDSP
              .public CLP
              .public CLREG
              .public CLSIG
              .public CLST
              .public CLX
              .public COPY
              .public COS
              .public DEC
              .public DEG
              .public DEL
              .public DELETE
              .public DIVIDE
              .public DSE
              .public D_R
              .public END
              .public ENG
              .public ENTER
              .public E_TO_X
              .public E_TO_X_MINUS_1
              .public FACT
              .public FC
              .public FC_C
              .public FIX
              .public FRAC
              .public FS
              .public FS_C
              .public GRAD
              .public GTO
              .public GTOL
              .public HMS_H
              .public HMS_MINUS
              .public HMS_PLUS
              .public H_HMS
              .public INT
              .public ISG
              .public LASTX
              .public LBL
              .public LN
              .public LN1_PLUS_X
              .public LOG
              .public MEAN
              .public MINUS
              .public MOD
              .public MODE
              .public MULTIPLY
              .public OCT
              .public OFF
              .public ONE_BY_X
              .public PACK
              .public PCT
              .public PCTCH
              .public PI
              .public PLUS
              .public POWER_OF_TEN
              .public PROMPT
              .public PSE
              .public P_R
              .public RAD
              .public RCL
              .public RDN
              .public RND
              .public ROLLUP
              .public RTN
              .public RUN_STOP
              .public R_D
              .public R_P
              .public SCI
              .public SF
              .public SHIFT
              .public SIGMA_MINUS
              .public SIGMA_PLUS
              .public SIGN
              .public SIGREG
              .public SIN
              .public SIZE
              .public SQRT
              .public SST
              .public STAYON
              .public STDEV
              .public STO
              .public STOP
              .public STO_DIVIDE
              .public STO_MINUS
              .public STO_MULTIPLY
              .public STO_PLUS
              .public TAN
              .public TONE
              .public VIEW
              .public XEQ
              .public XGOIND
              .public X_EQ_0
              .public X_EQ_Y
              .public X_GT_0
              .public X_GT_Y
              .public X_LE_0
              .public X_LE_Y
              .public X_LT_0
              .public X_LT_Y
              .public X_NE_0
              .public X_NE_Y
              .public X_TO_2
              .public X_XCHNG
              .public X_XCHNG_Y
              .public Y_TO_X

; *
; * PKTTAB - parse key type table
; * Must start at 0 in QUAD 4 (1000-@10000)
; * Logical column 0
              .con    65            ; A
              .con    70            ; F
              .con    256           ; SHIFT
              .con    0
              .con    2             ; -
              .con    1             ; +
              .con    3             ; *
              .con    4             ; /
; * Logical column 1
              .con    66            ; B
              .con    71            ; G
              .con    0
              .con    0
              .con    39            ; 7
              .con    36            ; 4
              .con    33            ; 1
              .con    32            ; 0
; * Logical column 2
              .con    67            ; C
              .con    72            ; H
              .con    0
              .con    0
              .con    40            ; 8
              .con    37            ; 5
              .con    34            ; 2
              .con    512           ; DP
; * Logical column 3
              .con    68            ; D
              .con    73            ; I
              .con    0
              .con    0
              .con    41            ; 9
              .con    38            ; 6
              .con    35            ; 3
              .con    0
; * Logical column 4
              .con    69            ; E
              .con    64            ; J
              .con    0
              .con    15            ; BACKARROW
              .con    128           ; ALPHA
              .con    0
              .con    0
                                    ; OFF key is special
              .name   "Y^X"
Y_TO_X:       c=n
              gosub   XY_TO_X
              goto    NFRXY_
              .name   "HMS+"
HMS_PLUS:     c=n
              gosub   XTOHRS
              cnex
              c=regn  2
              gosub   XTOHRS
              a=c     w
              c=n
              gosub   AD2_10
              s5=     1
              gosub   XTOHRS
              goto    NFRXY_
              .name   "HMS-"
HMS_MINUS:    c=n
              c=-c-1  s
              cnex
              goto    HMS_PLUS
              .name   "+"
PLUS:         c=n
              goto    ADD210
              .name   "MOD"
MOD:          c=n
              gosub   MOD10
              goto    NFRXY_
              .name   "-"
MINUS:        c=n
              c=-c-1  s
              nop
ADD210:       gosub   AD2_10
NFRXY_:       golong  NFRXY
              .name   "*"
MULTIPLY:     c=n
              gosub   MP2_10
              goto    NFRXY_
              .name   "%"
PCT:          a=a-1   x
              a=a-1   x
              c=n
TIMES:        gosub   MP2_10
              golong  NFRX
              .name   "X^2"
X_TO_2:       c=n
              a=c
              goto    TIMES
              .name   "/"
DIVIDE:       c=n
              gosub   DV2_10
              goto    NFRXY_
              .name   "ABS"
ABS:          c=n
              c=0     s
              rtn
              .name   "ACOS"
ACOS:         gosub   TRGSET
              s0=     1
ASIN1:        s1=     1
ATAN1:        s2=     1
              golong  BRT100
              .con    0             ; no prompting
AGTO:         s7=     0
XGAXFR:       golong  XGA00
              .con    0x8c          ; L
              .con    3             ; C
              .con    0x112         ; R
              .con    0x201         ; A
ARCL:         golong  XARCL
              .name   "ASHF"
ASHF:         golong  XASHF
              .name   "ASIN"
ASIN:         gosub   TRGSET
              goto    ASIN1
              .con    0x8e          ; N
              .con    19            ; S
              .con    0x101         ; A
ASN:          golong  XASN
              .con    0x8f          ; O
              .con    0x14          ; T
              .con    0x113         ; S
              .con    0x201         ; A
ASTO:         golong  XASTO
              .name   "ATAN"
ATAN:         gosub   TRGSET
              goto    ATAN1
              .name   "AVIEW"
AVIEW:        golong  XAVIEW
              .con    0             ; no prompting
AXEQ:         s7=     1
              goto    XGAXFR
              .name   "BEEP"
BEEP:         ldi     7
              golong  XBEEP
              .name   "BST"
BST:          nop                   ; XKD
              golong  XBST
              .con    0x94          ; T
              .con    0x301         ; A
              .con    0x103         ; C
CAT:          golong  XCAT
              .con    0x286         ; F
              .con    0x203         ; C
CF:           golong  XCF
              .name   "CLA"
CLA:          c=0
              regn=c  5
              regn=c  6
              regn=c  7
              regn=c  8
NFRPUL:       rtn
              .con    0x8f          ; O
              .con    0x14          ; T
              .con    0x213         ; S
STO:          c=m
              data=c
              rtn
              .name   "CLD"
CLDSP:        gosub   DATOFF        ; clear MSGFLG
; * DATOFF also clears DATAENTRY flag, but there's no harm done.
              golong  NWGOOS

; * In keyboard mode, putting up a new goose isn't very useful,
; * but since the default display logic writes over it, no harm
; * is done.
              .con    0x90          ; P
              .con    0x0c          ; L
              .con    0x103         ; C
CLP:          golong  CLRPGM
              .name   "CLRG"
CLREG:        s8=     1
              golong  CLR
              .con    0xce          ; sigma
              .con    0x0c          ; L
              .con    3             ; C
CLSIG:        golong  XCLSIG
              .name   "CLST"
CLST:         c=0
              regn=c  0
              regn=c  1
              regn=c  2
              goto    XCLX1
              .name   "CLX"
CLX:          c=0
              .public XCLX1         ; used by SIGMA+ and SIGMA-
XCLX1:        regn=c  3             ; store new X
              golong  NFRSIG
              .con    0x99          ; Y
              .con    0x10          ; P
              .con    0x0f          ; O
              .con    0x103         ; C
COPY:         golong  XCOPY
              .name   "D-R"
D_R:          c=n
              golong  DTOR
              .name   "DEG"
DEG:          golong  XDEG
              .name   "GRAD"
GRAD:         golong  XGRAD
              .name   "RAD"
RAD:          golong  XRAD
              .con    0x8c          ; L
              .con    0x105         ; E
              .con    0x104         ; D
DEL:          golong  DELNNN
              .con    0             ; NO PROMPTING
DELETE:       nop
              golong  XDELET
              .con    0x85          ; E
              .con    0x113         ; S
              .con    0x204         ; D
DSE:          golong  XDSE
              .name   "END"
END:
              .con    0x87          ; G
              .con    0x30e         ; N
              .con    0x105         ; E
ENG:          s6=     1
              golong  XSCI
              .name   "ENTER^"
ENTER:        gosub   R_SUB
              c=regn  2
              regn=c  3
              golong  NFRENT
              .name   "E^X"
E_TO_X:       c=n
              golong  EXP10
              .name   "ADV"
ADVNCE:       gosub   PRT9
              rtn
              .name   "FACT"
FACT:         c=n
              golong  XFT100
              .con    0xbf          ; ?
              .con    0x203         ; C
              .con    0x206         ; F
FC:           acex
              c=-c-1
              acex
              goto    FS
              .name   "E^X-1"
E_TO_X_MINUS_1:
              s4=     1
              c=n
              golong  EXP10
              .con    0x83          ; C
              .con    0x3f          ; ?
              .con    0x203         ; C
              .con    0x206         ; F
FC_C:         gosub   XCF
              goto    FC
              .con    0x98          ; X
              .con    0x309         ; I
              .con    0x106         ; F
FIX:          s7=     1
              golong  XSCI
              .name   "INT"
INT:          s5=     1
              goto    FRAC
              .name   "FRC"
FRAC:         c=n
              golong  INTFRC
              .con    0xbf          ; ?
              .con    0x213         ; S
              .con    0x206         ; F
FS:           golong  XFS
              .con    0x83          ; C
              .con    0x3f          ; ?
              .con    0x213         ; S
              .con    0x206         ; F
FS_C:         gosub   XCF
              goto    FS
              .con    0             ; no prompting
GTOL:         golong  GTONN
              .con    0x8f          ; O
              .con    0x314         ; T
              .con    0x307         ; G
GTO:                                ; can't be followed by 0
              .name   "HR"
HMS_H:        c=n
              golong  XTOHRS
              .name   "HMS"
H_HMS:        s5=     1
              goto    HMS_H         ; save code here
              .con    0x87          ; G
              .con    0x113         ; S
              .con    0x209         ; I
ISG:          s0=     0
              golong  XISG
              .con    0x8c          ; L
              .con    2             ; B
              .con    0x30c         ; L
LBL:                                ; can't be followed by 0
              .name   "LN"
LN:           c=n
              golong  LN10
              .name   "LOG"
LOG:          s5=     1
              goto    LN            ; save space here
              .name   "SDEV"
STDEV:        gosub   SD
              goto    NFRNC_
              .name   "MEAN"
MEAN:         gosub   XBAR
NFRNC_:       golong  NFRNC
              .name   "R-P"
R_P:          gosub   TRGSET
              gosub   TOPOL
              goto    NFRNC_
              .name   "OFF"
OFF:          disoff
              ldi     9
              gosub   ROMCHK
              gosub   MEMCHK
              gosub   RSTKB
              golong  DRSY50
              .name   "1/X"
ONE_BY_X:     c=n
              golong  ONE_BY_X10
              .name   "P-R"
P_R:          gosub   TRGSET
              s1=     1
              s2=     1
              gosub   TOREC
              goto    NFRNC_
              .name   "PACK"
PACK:         golong  XPACK
              .name   "%CH"
PCTCH:        acex    s
              c=-c-1  s
              acex    s
              c=n
              gosub   AD2_10
              a=a+1   x
              a=a+1   x
              c=regn  2
              gosub   DV1_10
              golong  NFRX
              .name   "PSE"
PSE:          ?s13=1                ; running?
              gonc    PSE10         ; no
              s1=     1             ; set PAUSEFLAG
              gosub   STOST0        ; put SS0 back
PSE10:        golong  PSESTP
              .name   "PROMPT"
PROMPT:       golong  XPRMPT
              .name   "R-D"
R_D:          c=n
              golong  RTOD
              .name   "STOP"
STOP:         golong  STOPSB
              .con    0             ; no prompting
RUN_STOP:     nop                   ; XKD
              golong  XR_S
              .name   "LN1+X"
LN1_PLUS_X:   c=n
              golong  XLN1_PLUS_X
              .name   "LASTX"
LASTX:        c=regn  4
LXEX:         bcex
              goto    RCL
              .con    0x8c          ; L
              .con    0x103         ; C
              .con    0x212         ; R
RCL:          ?s11=1
              gsubc   R_SUB
NPRCL:        c=0
              dadd=c
              bcex
              regn=c  3
NFRPRL:       golong  NFRPR
              .name   "CHS"
CHS:          c=n                   ; get X
              ?c#0    m
              gonc    DONCHS        ; X is zero do nothing
              c=-c-1  s             ; do CHS
              regn=c  3
DONCHS:       goto    NFRPRL
              .name   "PI"
PI:           setdec
              gosub   PI_BY_2
              c=c+c   w
              c=c+1   m
              c=0     x
              goto    LXEX
              .con    0xbe          ; >
              .con    0x13c         ; <
              .con    0x218         ; X
X_XCHNG:      c=m
              data=c
              goto    NPRCL
              .name   "RDN"
RDN:          golong  XRDN
              .name   "RND"
RND:          golong  XRND
              .name   "RTN"
RTN:          golong  XRTN
              .name   "R^"
ROLLUP:       golong  XROLLUP
              .con    0x89          ; I
              .con    0x303         ; C
              .con    0x113         ; S
SCI:          golong  XSCI
              .con    0x286         ; F
              .con    0x213         ; S
SF:           golong  XSF
              .con    0xab          ; +
              .con    0x4e          ; SIGMA
SIGMA_PLUS:   golong  SIGMA
              .con    0xAD          ; -
              .con    0x4E          ; SIGMA
SIGMA_MINUS:  s5=     1
              goto    SIGMA_PLUS    ; save code here
              .con    0x87          ; G
              .con    5             ; E
              .con    0x212         ; R
              .con    0x24e         ; SIGMA
SIGREG:       golong  XSGREG
              .name   "COS"
COS:          gosub   TRGSET
              goto    COS1
              .name   "TAN"
TAN:          gosub   TRGSET
              goto    XTRIG
              .name   "SIN"
SIN:          gosub   TRGSET
              s0=     1
COS1:         s1=     1
XTRIG:        golong  TRG100
              .con    0x85          ; E
              .con    0x1a          ; Z
              .con    0x109         ; I
              .con    0x113         ; S
SIZE:         golong  XSIZE
              .name   "SQRT"
SQRT:         c=n
              golong  SQR10
              .name   "SST"
SST:          nop                   ; XKD
              golong  XSST
              .name   "ON"
STAYON:       golong  XSTYON
              .con    0xaa          ; *
              .con    0x114         ; T
              .con    0x213         ; S
STO_MULTIPLY: gosub   SEPXY
              gosub   MP2_10
              goto    NFRST
              .con    0xab          ; +
              .con    0x114         ; T
              .con    0x213         ; S
STO_PLUS:     gosub   SEPXY
              gosub   AD2_10
NFRST:        golong  NFRST_PLUS
              .con    0xad          ; -
              .con    0x114         ; T
              .con    0x213         ; S
STO_MINUS:    c=m
              setdec
              c=-c-1  s
              m=c
              goto    STO_PLUS
              .con    0xaf          ; /
              .con    0x114         ; T
              .con    0x213         ; S
STO_DIVIDE:   gosub   SEPXY
              gosub   DV2_10
              goto    NFRST
              .name   "10^X"
POWER_OF_TEN: golong  TEN_TO_X
              .con    0x85          ; E
              .con    0x0e          ; N
              .con    0x30f         ; O
              .con    0x114         ; T
TONE:         golong  XTONE
              .con    0x97          ; W
              .con    5             ; E
              .con    0x109         ; I
              .con    0x216         ; V
VIEW:         golong  XVIEW
              .con    0xbf          ; ?
              .con    0x30          ; 0
              .con    0x4d          ; #
              .con    0x18          ; X
X_NE_0:       golong  XX_NE_0
              .con    0xbf          ; ?
              .con    0x19          ; Y
              .con    0x4d          ; #
              .con    0x18          ; X
X_NE_Y:       golong  XX_NE_Y
              .name   "X<0?"
X_LT_0:       golong  XX_LT_0
              .name   "X<=0?"
X_LE_0:       golong  XX_LE_0A
              .name   "X<=Y?"
X_LE_Y:       golong  XX_LE_Y
              .name   "X<>Y"
X_XCHNG_Y:    c=regn  3
              acex
              c=regn  2
              regn=c  3
              acex
              regn=c  2
              golong  NFRPR
              .name   "X<Y?"
X_LT_Y:       golong  XX_LT_Y
              .name   "X=0?"
X_EQ_0:       golong  XX_EQ_0
              .name   "X=Y?"
X_EQ_Y:       golong  XX_EQ_Y
              .name   "X>0?"
X_GT_0:       golong  XX_GT_0
              .name   "X>Y?"
X_GT_Y:       golong  XX_GT_Y
              .con    0             ; no prompting
XGOIND:       golong  XGI
              .con    0x91          ; Q
              .con    0x105         ; E
              .con    0x318         ; X
XEQ:                                ; can't be followed by 0
              .name   "DEC"
DEC:          s4=     1
              goto    OCT
              .name   "OCT"
OCT:          c=n
              golong  TOOCT
              .name   "SIGN"
SIGN:         golong  XSIGN
              .name   "AON"
AON:          s7=     1             ; set ALPHAMODE
AON10:        gosub   STOST0
              golong  ANNOUT
              .name   "AOFF"
AOFF:         s7=     0             ; clear ALPHAMODE
              goto    AON10

              .con    0             ; no prompting
SHIFT:        nop                   ; XKD
              gosub   TGSHF1        ; toggle shift flag
              goto    USCOM1

              .con    0             ; no prompting
MODE:         nop                   ; XKD
              c=keys

              .public MODE1         ; for Wand ALPHA,PRGM,USER
; * Entry point add for Wand on 3-13-79
; *
MODE1:
              pt=     3
              c=c+c   pt
              c=c+c   pt
              c=c+c   pt
              gonc    ALFPRG
                                    ; USER key
              c=regn  14
              rcr     6
              cstex                 ; put up SS3
              ?s4=1                 ; USERMODE?
              goc     USEROF        ; yes
              s4=     1             ; set USERMODE
              goto    USERC
USEROF:       s4=     0             ; clear USERMODE
USERC:        cstex
              rcr     8
USCOM:        c=st                  ; merge SS0 with other sets
              regn=c  14
USCOM1:       s9=     0             ; keyboard not reset yet
              golong  DRSY51        ; refresh annunciators only

ALFPRG:       gosub   PRT14
              .public PR14RT        ; for printer
PR14RT:
              ?c#0    pt            ; PRGM key?
              goc     PRGM          ; yes
              gosub   RSTMS1        ; ALPHA key
              ?s7=1                 ; alpha mode?
              gonc    ALPHON        ; no
              s7=     0             ; clear alpha mode
APCOM:        c=st                  ; merge SS0 w/ other sets
              regn=c  14            ; put status sets back
D05XFR:       s9=     0             ; keyboard not reset yet
              golong  DRSY05        ; refresh main display
ALPHON:       s7=     1             ; set alpha mode
              ?s3=1                 ; program mode?
              gonc    APCOM         ; no
              goto    USCOM         ; yes

PRGM:         gosub   RSTMS1
              s1=     0             ; clear PAUSEFLAG
              s7=     0             ; clear alpha mode
              ?s3=1                 ; PRGMMODE?
              goc     PRGMOF        ; yes
              s3=     1             ; no. set PRGMMODE
              goto    APCOM
PRGMOF:       s3=     0             ; clear PRGMMODE
              c=st
              regn=c  14            ; put status sets back
              gosub   DECMPL        ; decompile
              goto    D05XFR

; ******************************************************
CAT3:         c=0                   ; move # to a mant
              bcex    x
              rcr     11
              acex
              gosub   ALPDEF        ; sel correct def
              nop
              xdef    PLUS
              xdef    MINUS
              xdef    MULTIPLY
              xdef    DIVIDE
              xdef    ONE_BY_X
              xdef    POWER_OF_TEN
              xdef    ABS
              xdef    ACOS
              xdef    ADVNCE
              xdef    AOFF
              xdef    AON
              xdef    ARCL
              xdef    ASHF
              xdef    ASIN
              xdef    ASN
              xdef    ASTO
              xdef    ATAN
              xdef    AVIEW
              xdef    BEEP
              xdef    BST
              xdef    CAT
              xdef    CF
              xdef    CHS
              xdef    CLA
              xdef    CLDSP
              xdef    CLP
              xdef    CLREG
              xdef    CLSIG
              xdef    CLST
              xdef    CLX
              xdef    COPY
              xdef    COS
              xdef    D_R
              xdef    DEC
              xdef    DEG
              xdef    DEL
              xdef    DSE
              xdef    END
              xdef    ENG
              xdef    ENTER
              xdef    E_TO_X
              xdef    E_TO_X_MINUS_1
              xdef    FACT
              xdef    FC
              xdef    FC_C
              xdef    FIX
              xdef    FRAC
              xdef    FS
              xdef    FS_C
              xdef    GRAD
              xdef    GTO
              xdef    H_HMS
              xdef    HMS_PLUS
              xdef    HMS_MINUS
              xdef    HMS_H
              xdef    INT
              xdef    ISG
              xdef    LASTX
              xdef    LBL
              xdef    LN
              xdef    LN1_PLUS_X
              xdef    LOG
              xdef    MEAN
              xdef    MOD
              xdef    OCT
              xdef    OFF
              xdef    STAYON
              xdef    P_R
              xdef    PACK
              xdef    PCT
              xdef    PCTCH
              xdef    PI
              xdef    PROMPT
              xdef    PSE
              xdef    ROLLUP
              xdef    R_D
              xdef    R_P
              xdef    RAD
              xdef    RCL
              xdef    RDN
              xdef    RND
              xdef    RTN
              xdef    STDEV
              xdef    SCI
              xdef    SF
              xdef    SIGMA_PLUS
              xdef    SIGMA_MINUS
              xdef    SIGREG
              xdef    SIN
              xdef    SIGN
              xdef    SIZE
              xdef    SQRT
              xdef    SST
              xdef    STO_PLUS
              xdef    STO_MINUS
              xdef    STO_MULTIPLY
              xdef    STO_DIVIDE
              xdef    STO
              xdef    STOP
              xdef    TAN
              xdef    TONE
              xdef    VIEW
              xdef    X_EQ_0
              xdef    X_NE_0
              xdef    X_LT_0
              xdef    X_LE_0
              xdef    X_GT_0
              xdef    X_EQ_Y
              xdef    X_NE_Y
              xdef    X_LT_Y
              xdef    X_LE_Y
              xdef    X_GT_Y
              xdef    X_XCHNG
              xdef    X_XCHNG_Y
              xdef    XEQ
              xdef    X_TO_2
              xdef    Y_TO_X
              .con    0
;
; *
; *
; *
; *************************************************************
; * NOTE: No execution point may be located after @1736 in this
; * QUAD.  The search algorithm uses entries > @1736 in the
; * main function table as delimiters of holes in the table.
; *************************************************************
