;;; This is HP41 mainframe resurrected from list file output. QUAD 5
;;;
;;; REV.  6/81A
;;; Original file CN5B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @12000-13777
; *

              .section QUAD5

              .public CHKADR
              .public CHK_NO_S
              .public CHK_NO_S2
              .public CLR
              .public DEGDO
              .public ERRAD
              .public FCNTBL
              .public FIND_NO_1
              .public FLGANN
              .public FNDEND
              .public GETLIN
              .public LOAD3
              .public PCKDUR
              .public RDNSUB
              .public R_SUB
              .public SEPXY
              .public STFLGS        ; set MSGFLG & DATA.PUBLIC flag
              .public SUMCHK
              .public SUMCK2
              .public TONE7
              .public TONEB
              .public XARCL
              .public XASHF
              .public XASTO
              .public XBEEP
              .public XCF
              .public XCLSIG
              .public XDEG
              .public XDSE
              .public XFS
              .public XGRAD
              .public XISG
              .public XRAD
              .public XRDN
              .public XROLLUP
              .public XSCI
              .public XSF
              .public XSGREG
              .public XSIZE
              .public XSTYON
              .public XTONE
              .public XX_EQ_0
              .public XX_EQ_Y
              .public XX_GT_0
              .public XX_GT_Y
              .public XX_LE_0
              .public XX_LE_0A
              .public XX_LE_Y
              .public XX_LT_0
              .public XX_LT_Y
              .public XX_NE_0
              .public XX_NE_Y
              .public Y_MINUS_X

FCNTBL:                             ; Main function table
              xdef    CAT           ; 00
              xdef    GTOL          ; 01
              xdef    DEL           ; 02
              xdef    COPY          ; 03
              xdef    CLP           ; 04
              xdef    RUN_STOP      ; 05
              xdef    SIZE          ; 06
              xdef    BST           ; 07
              xdef    SST           ; 08
              xdef    STAYON        ; 09
              xdef    PACK          ; 0A
              xdef    DELETE        ; 0B
              xdef    MODE          ; 0C
              .con    0x3e0
              xdef    SHIFT         ; 0E
              xdef    ASN           ; 0F
              .con    0x3ec         ; digit entry (13)
XSTYON:       c=regn  14            ; set the stayon flag
              rcr     2
              st=c
              s3=     1             ; set stayon
              c=st
              rcr     12
              regn=c  14
              rtn
GETLIN:       c=0
              dadd=c
              c=regn  15
              rtn
              .fillto 0x1D
              xdef    AGTO
              xdef    AXEQ
              .con    0x3E0
              .con    0x3FF         ; ROWS 2 and 3
; ************************************************
; * This routine does subtract for compares.
; ************************************************
Y_MINUS_X:    setdec
              c=n
              c=-c-1  s
              nop
              gosub   AD2_10
              n=c
              rtn
              .public OVFL10
; *
; * Check overflow/underflow
; * C has the number
; *   return with :
; *                PT= 12  OK
; *                PT= 10  overflow
; *                PT= 11  underflow
; *   RETURN IN DEC MODE
OVFL10:       ?c#0    m
              goc     OVFL15
              c=0     w
OVFL15:       setdec
              pt=     12
              ?c#0    xs
              rtn nc
              c=c-1   x
              c=c+1   xs
              c=c-1   xs
              gonc    OVFL30
              c=c+1   x
              legal
OVFL20:       rtn
OVFL30:       c=c+c   xs
              gonc    OVFL40
              c=0     w
              goto    OVFL50
OVFL40:       c=0     wpt
              c=c-1   wpt
              c=0     xs
              dec pt
OVFL50:       dec pt
              rtn
              .fillto 0x40
              xdef    PLUS          ; ROW 4
              xdef    MINUS
              xdef    MULTIPLY
              xdef    DIVIDE
              xdef    X_LT_Y
              xdef    X_GT_Y
              xdef    X_LE_Y
              xdef    SIGMA_PLUS
              xdef    SIGMA_MINUS
              xdef    HMS_PLUS
              xdef    HMS_MINUS
              xdef    MOD
              xdef    PCT
              xdef    PCTCH
              xdef    P_R
              xdef    R_P
              xdef    LN            ; ROW 5
              xdef    X_TO_2
              xdef    SQRT
              xdef    Y_TO_X
              xdef    CHS
              xdef    E_TO_X
              xdef    LOG
              xdef    POWER_OF_TEN
              xdef    E_TO_X_MINUS_1
              xdef    SIN
              xdef    COS
              xdef    TAN
              xdef    ASIN
              xdef    ACOS
              xdef    ATAN
              xdef    DEC
              xdef    ONE_BY_X      ; ROW 6
              xdef    ABS
              xdef    FACT
              xdef    X_NE_0
              xdef    X_GT_0
              xdef    LN1_PLUS_X
              xdef    X_LT_0
              xdef    X_EQ_0
              xdef    INT
              xdef    FRAC
              xdef    D_R
              xdef    R_D
              xdef    H_HMS
              xdef    HMS_H
              xdef    RND
              xdef    OCT
              xdef    CLSIG         ; ROW 7
              xdef    X_XCHNG_Y
              xdef    PI
              xdef    CLST
              xdef    ROLLUP
              xdef    RDN
              xdef    LASTX
              xdef    CLX
              xdef    X_EQ_Y
              xdef    X_NE_Y
              xdef    SIGN
              xdef    X_LE_0
              xdef    MEAN
              xdef    STDEV
              xdef    AVIEW
              xdef    CLDSP
              xdef    DEG           ; ROW 8
              xdef    RAD
              xdef    GRAD
              xdef    ENTER
              xdef    STOP
              xdef    RTN
              xdef    BEEP
              xdef    CLA
              xdef    ASHF
              xdef    PSE
              xdef    CLREG
              xdef    AOFF
              xdef    AON
              xdef    OFF
              xdef    PROMPT
              xdef    ADVNCE
              xdef    RCL           ; ROW 9
              xdef    STO
              xdef    STO_PLUS
              xdef    STO_MINUS
              xdef    STO_MULTIPLY
              xdef    STO_DIVIDE
              xdef    ISG
              xdef    DSE
              xdef    VIEW
              xdef    SIGREG
              xdef    ASTO
              xdef    ARCL
              xdef    FIX
              xdef    SCI
              xdef    ENG
              xdef    TONE
              .con    0x3e7         ; XROM (8)
              .public TSTMAP
; * TSTMAP - test bit map
; *- A subroutine used to eliminate duplicate code.
; *- Test bit map for a specified keycode and clear
; *- its corresponding bit if set.
; *- IN:  A[1:0]= logical keycode + 1
; *-      chip 0 selected
; *- OUT: chip 0 selected
; *- USES: A[13:0], C[13:0], M[13:0]
; *- USES: 1 subroutine level
; *
TSTMAP:       gsblng  TBITMA        ; test bit map
              ?c#0                  ; bit set?
              golnc   NFRPU         ; nope
              golong  SRBMAP        ; reset bit map
              .fillto 0xa8
              xdef    SF
              xdef    CF
              xdef    FS_C
              xdef    FC_C
              xdef    FS
              xdef    FC
              xdef    XGOIND
              .con    0x3F0
                                    ; ROW 11
; ***************************************************
; * This code clears the sigma registers
; ***************************************************
XCLSIG:       gosub   SUMCHK        ; legal and get address
                                    ; SUMCHK returns address of
                                    ; last sigma reg in C.X
              pt=     6
              a=0
CLRNXT:       acex
              data=c
              acex
              c=c-1
              dadd=c
              dec pt
              ?pt=    0
              gonc    CLRNXT
              rtn
; ***********************************************
; * The roll up function happens here.
; ***********************************************
XRDN:         gosub   RDNSUB
              goto    NFRPRL
              .fillto 0xc0
              xdef    END
              .con    0x3ec
              .public FSTIN
; * FSTIN - first instruction
; * Sets A[3:0] to the address in MM format of the first location
; *-in program memory minus 1 byte. (In packed memory this is the
; *-address of the first instruction.)
; * USES A[3:0] and C
; * EXPECTS PT=3 in and out
; *
FSTIN:        c=0                   ; set A to reg 0 address
              dadd=c
              c=regn  13
              rcr     3
              a=c     x
              a=0     pt
              rtn

              .PUBLIC RTJLBL
; *
; * RTJLBL - right-justify alpha operand
; * On entry, C has a non-zero alpha string in the form
; *     "CBA0000" where the string is "ABC"
; * RTJLBL moves zeroes to the left side: "0000CBA"
; * USES the PTR and C only.
; * ON EXIT, PT=1.
; *
RTJLBL:       pt=     1
RTJ10:        ?c#0    wpt
              rtn c
              rcr     2
              goto    RTJ10
              .fillto 0xce
              xdef    X_XCHNG
              xdef    LBL
              xdef    GTO           ; ROW 13
              .con    0x3ee

; *****************************************************
; * This routine checks for character data.
; *****************************************************
SEPXY:        abex
              c=m
              .public CHK_NO_S1
CHK_NO_S1:    acex
              gosub   CHK_NO_S
              acex
CHK_NO_S:     setdec
CHK_NO_S2:    ?c#0    s
              rtn nc
              c=c+1   s
              gonc    ERRAD
              c=c-1   s
              rtn
              .fillto 0xE0
              xdef    XEQ           ; ROW 14
              .con    0             ; end of main function table
ERRAD:        gosub   ERROR
              xdef    MSGAD

; *****************************************************
; * This routine does a roll down.
; *****************************************************
XROLLUP:      gosub   R_SUB
NFRPRL:       golong  NFRPR
RDNSUB:       gosub   R_SUB
              gosub   R_SUB
R_SUB:        c=0
              dadd=c
              c=data
              acex
              c=regn  1
              regn=c  0
              c=regn  2
              regn=c  1
              c=regn  3
              regn=c  2
              acex
              regn=c  3
              rtn

; * LOAD3 - set REG.C = 33333333333332
; *
LOAD3:        setdec                ; set to decimal mode
              c=0     w
              c=c-1   w             ; get all 9's in C
              sethex                ; put back in hex mode
              c=c+c   w             ; C _ 33333333333332
              rtn
              .fillto 0x100
; *
; * DCTAB - defaultcode table
; * There are two types of entries.  Entry type is encoded in
; * bits 8 and 9:
; * BITS 9,8 = 00 data entry (digit entry and alpha entry keys)
; * BITS 9,8 = 01 function in main FCN table
; * For FCN entries, the index to the table is encoded in bits 7-0.
; * For data entry entries, bits 7-0 contain either the ASCII
; * character (alpha entry), or the FCN code for the digit entry FCN.
; * DCTAB must start at @400 in QUAD 5 (H1500=@12400)
; *
; * Logical COL 0, unshifted, normal
              .con    327           ; sigma+
              .con    369           ; x<>y
              .con    270           ; shift
              .con    387           ; enter
              .con    321           ; -
              .con    320           ; +
              .con    322           ; *
              .con    323           ; /
; * Logical COL 0, shifted, normal
              .con    328           ; sigma-
              .con    368           ; clsigma
              .con    270           ; shift
              .con    256           ; catalog
              .con    376           ; x=y?
              .con    326           ; x<=y?
              .con    325           ; x>y?
              .con    359           ; X=0?
; * Logical COL 1, unshifted, normal
              .con    352           ; 1/X
              .con    373           ; RDN
              .con    480           ; XEQ
              .con    0             ; RIGHT HALF OF ENTER KEY
              .con    23            ; 7
              .con    20            ; 4
              .con    17            ; 1
              .con    16            ; 0
; * Logical COL 1, shifted, normal
              .con    339           ; Y^X
              .con    332           ; %
              .con    271           ; ASN
              .con    0             ; RIGHT HALF OF ENTER KEY
              .con    424           ; SF
              .con    390           ; BEEP
              .con    412           ; FIX
              .con    370           ; PI
; * Logical COL 2, unshifted, normal
              .con    338           ; SQRT
              .con    345           ; SIN
              .con    401           ; STO
              .con    28            ; CHS
              .con    24            ; 8
              .con    21            ; 5
              .con    18            ; 2
              .con    26            ; DECIMAL POINT
; * Logical COL 2, shifted, normal
              .con    337           ; X^2
              .con    348           ; ASIN
              .con    463           ; LBL
              .con    406           ; ISG
              .con    425           ; CF
              .con    334           ; P-R
              .con    413           ; SCI
              .con    374           ; LASTX
; * Logical COL 3, unshifted, normal
              .con    342           ; LOG
              .con    346           ; COS
              .con    400           ; RCL
              .con    27            ; EEX
              .con    25            ; 9
              .con    22            ; 6
              .con    19            ; 3
              .con    261           ; R/S
; * Logical COL 3, shifted, normal
              .con    343           ; 10^X
              .con    349           ; ACOS
              .con    464           ; GTO
              .con    389           ; RTN
              .con    428           ; FS?
              .con    335           ; R-P
              .con    414           ; ENG
              .con    408           ; VIEW
; * Logical COL 4, unshifted, normal
              .con    336           ; LN
              .con    347           ; TAN
              .con    264           ; SST
              .con    0             ; BACKARROW
              .con    268           ; mode (ALPHA)
              .con    268           ; mode (PRGM)
              .con    268           ; mode (USER)
              nop                   ; OFF key is special
; * Logical COL 4, shifted, normal
              .con    341           ; E^X
              .con    350           ; ARCTAN
              .con    263           ; BST
              .con    375           ; CLX
              .con    268           ; mode (ALPHA)
              .con    268           ; mode (PRGM)
              .con    268           ; mode (USER)
              nop                   ; OFF key is special
; *
; * Logical COL 0, unshifted, alpha mode
              .con    65            ; A
              .con    70            ; F
              .con    270           ; SHIFT
              .con    78            ; N
              .con    81            ; Q
              .con    85            ; U
              .con    89            ; Y
              .con    58            ; :
; * Logical COL 0, shifted, alpha mode
              .con    97            ; lower case A
              .con    126           ; SIGMA
              .con    270           ; SHIFT
              .con    94            ; ^
              .con    45            ; -
              .con    43            ; +
              .con    42            ; *
              .con    47            ; /
; * Logical COL 1, unshifted, alpha mode
              .con    66            ; B
              .con    71            ; G
              .con    75            ; K
              .con    0             ; right half of ENTER key
              .con    82            ; R
              .con    86            ; V
              .con    90            ; Z
              .con    32            ; SPACE
; * Logical COL 1, shifted, alpha mode
              .con    98            ; lower case B
              .con    37            ; %
              .con    127           ; lazy "T" (APPEND)
              .con    0             ; right half of ENTER key
              .con    55            ; 7
              .con    52            ; 4
              .con    49            ; 1
              .con    48            ; 0
; * Logical COL 2, unshifted, alpha mode
              .con    67            ; C
              .con    72            ; H
              .con    76            ; L
              .con    79            ; O
              .con    83            ; S
              .con    87            ; W
              .con    61            ; =
              .con    44            ; comma
; * Logical COL 2, shifted, alpha mode
              .con    99            ; lower case C
              .con    29            ; not equal sign
              .con    410           ; ASTO
              .con    13            ; angle sign
              .con    56            ; 8
              .con    53            ; 5
              .con    50            ; 2
              .con    46            ; decimal point
; * Logical COL 3, unshifted, alpha mode
              .con    68            ; D
              .con    73            ; I
              .con    77            ; M
              .con    80            ; P
              .con    84            ; T
              .con    88            ; X
              .con    63            ; ?
              .con    261           ; R/S
; * Logical COL 3, shifted, alpha mode
              .con    100           ; lower case D
              .con    60            ; <
              .con    411           ; ARCL
              .con    36            ; $
              .con    57            ; 9
              .con    54            ; 6
              .con    51            ; 3
              .con    382           ; AVIEW
; * Logical COL 4, unshifted, alpha mode
              .con    69            ; E
              .con    74            ; J
              .con    264           ; SST
              .con    0             ; BACKARROW
              .con    268           ; mode (ALPHA)
              .con    268           ; mode (PRGM)
              .con    268           ; mode (USER)
              NOP                   ; OFF key is special
; * Logical COL 4, shifted, alpha mode
              .con    101           ; lower case E
              .con    62            ; >
              .con    519           ; BST
              .con    391           ; CLA
              .con    268           ; mode (ALPHA)
              .con    268           ; mode (PRGM)
              .con    268           ; mode (USER)
                                    ; OFF key is special
; *************************************************
; * ISG and DSE are done here. The routine breaks
; * the input in B into its three parts - INT,
; * COMPARE, and INC. It adds the INC, stores the
; * result and branches to the COMPARE routine
; * to decide whether to skip or not.
; *************************************************
XDSE:         s0=     1             ; set DSE flag
XISG:         bcex                  ; get content of RNN
              gosub   CHK_NO_S      ; check for alpha
              goto    NOFRAC
ELMFRC:       csr     m             ; change to FIX notation
              c=c+1   x
NOFRAC:       ?c#0    xs
              goc     ELMFRC
              gsblng  SINFR         ; do INT and FRC
              c=m                   ; get INT part
; * Next two states (?pt=0, goc OVRDEC) are vestigial from when
; * SINFR worked for 13-digit mantissas in another machine.  These
; * two states can be removed without harm.
              ?pt=    0             ; prevent clear for large values
              goc     OVRDEC
              dec pt
OVRDEC:       c=0     wpt           ; clear fractional part
              bcex    m             ; join mantissa with exp and sign
              bcex    w             ; bring complete INT to C
              m=c                   ; save for later
              c=a                   ; put FRAC in C
              data=c
              pt=     7             ; set to clear trail digits
              c=0     wpt
              pt=     9             ; pick off inc
              ?c#0    wpt           ; dummy one for zero
              goc     SEPA
              pt=     8
              lc      1
              pt=     9
SEPA:         a=0
              a=c     wpt           ; pick off inc
              c=0     wpt           ; leave compare val
              asl
              asl
              asl                   ; increment left-just
              pt=     12            ; point to digit one
              c=c+1   x             ; exp compare
              c=c+1   x
              a=a+1   x             ; exp inc
              ?a#0    pt            ; is inc exp ok?
              goc     TSTEXP        ; yes
              asl     m
              a=0     x
TSTEXP:       ?c#0    pt            ; exp 2 too large?
              goc     ADDIT         ; no, just right
              rcr     13            ; shift compare left
              c=0     x             ; exp=1?
              c=c+1   x
              ?c#0    pt            ; exp comp ok now?
              goc     ADDIT         ; yes
              rcr     13            ; shift left
              c=0     x             ; exp must be zero
ADDIT:        ?s0=1                 ; DSE or ISG?
              gonc    ADDEM         ; ISG
              a=a-1   s             ; make dec out of inc
ADDEM:        n=c                   ; save floating point compare
              c=m                   ; get integer part back
              gosub   AD2_10
              m=c                   ; save INT part of result
              a=c                   ; DUP RESULT IN A
              c=data                ; get FRAC part back
              c=a     x             ; dup exp
MRSHFT:       csr     m             ; shift FRAC into position
              c=c-1   x             ; in position yet?
              goc     COMBIN        ; yes
              ?c#0    m             ; fraction zero
              goc     MRSHFT        ; no not yet
COMBIN:       c=0     x             ; sign and exp C=0
              c=c+a   m
              legal
              gosub   SHF40
              data=c                ; store updated counter
              s7=     1
              c=m
              acex
              ?s0=1                 ; DSE??
              gonc    XX_GT_Y
; *************************************************
; * The comparisons follow. X values enter in N
; * while Y values are in A.
; *************************************************
XX_LT_Y:      gosub   Y_MINUS_X     ; do subtract
XX_GT_0:      setdec
              c=n
              ?c#0
              gonc    SKP
              c=c+1   s
              gonc    NOSKP
              goto    SKP
XX_GT_Y:      gosub   Y_MINUS_X
XX_LT_0:      ?s7=1
              goc     XX_LE_0
`XX<0`:       setdec
              c=n
              c=c+1   s
              gonc    SKP
              goto    NOSKP
XX_LE_Y:      gosub   Y_MINUS_X
              ?c#0
              gonc    NOSKP
              goto    XX_GT_0
XX_EQ_0:      a=0
              c=n
              goto    XYY
XX_LE_0A:     c=regn  3             ; row logic doesn't check
              gosub   CHK_NO_S      ;  for alpha data on X<=0?
              n=c
XX_LE_0:      c=n
              ?c#0
              gonc    NOSKP
              goto    `XX<0`
XX_NE_0:      a=0
              c=n
              goto    XYN
XX_EQ_Y:      c=regn  2
              acex
              c=regn  3
XYY:          ?a#c
              goc     SKP
              .public NOSKP
NOSKP:        ?s13=1
              goc     NOSKPO
              c=0
              dadd=c
              c=regn  14
              cstex
              ?s4=1
              goc     NOSKPO
              cstex
              ?s7=1                 ; is this ISG or DSE?
              goc     NOSKPO
              gosub   MSG
              xdef    MSGYES
NOSKPO:       golong  NFRPU         ; can't do a rtn here
; * Because some comparisons have NFRX on the stack instead of NFRPU
XX_NE_Y:      c=regn  2
              acex
              c=regn  3
XYN:          ?a#c
              goc     NOSKP
              .public SKP
SKP:          sethex
              ?s13=1
              gonc    `SST?`
              .public DOSKP
DOSKP:        gosub   GETPC
              gosub   SKPLIN
              gosub   PUTPCX        ; force recalc of line number
              goto    NOSKPO
`SST?`:       c=0
              dadd=c
              c=regn  14
              cstex
              ?s4=1
              goc     DOSKP
              cstex
              ?s7=1                 ; ISG DSE?
              goc     NOSKPO
              gosub   MSG           ; no comp or flags
              xdef    MSGNO
              goto    NOSKPO
; ***************************************************************
; * The flag conditionals follow. Entry is with R14 in A and A
; * mask in B. The mask consists of all zeros except for a one
; * at the location of the selected flag.
; ***************************************************************
XFS:          c=b                   ; get mask
              c=c.a                 ; AND R14 with mask
              ?c#0                  ; is anything left?
              goc     NOSKP         ; yes. NO SKP
SKPIT:        goto    SKP
XSF:          bcex                  ; move mask to C
              c=cora                ; set masked bit
              goto    FLGANN
XCF:          c=b
              c=-c-1
              nop
              c=c.a
FLGANN:       regn=c  14
              acex
              m=c
              gosub   ANNOUT
              c=m
              acex
              rtn
; **************************************************
; * SUM+NN sets the address of the register used
; * for SIGMA PLUS. It checks to see if the address
; * is in fact a legal address. The subroutine
; * SUMCHK is called by the SIGMA PLUS function
; * for this check.
; **************************************************
XSGREG:       c=n                   ; address or sum 1
              gosub   SUMCK2        ; legal?
              c=n                   ; yes
              acex                  ; put address in scratch
              c=0
              dadd=c
              c=regn  13
              rcr     11
              c=0     x
              c=c+a   x
              rcr     3
              regn=c  13
              rtn
SUMCHK:       c=regn  13            ; get address
              rcr     11
SUMCK2:       acex                  ; add5
              ldi     5
              sethex
              c=c+a   x
              legal
; *************************************************
; * CHKADR - checks for valid data addresses
; * IN: addr in C.X
; * OUT: data in B, addr in C.X, hexmode,
; *      DADD=C.X (except some error exits)
; * USES: active pointer, A, S9, DADD, C, B
; * May exit to ERRNE
; *
; * CHKAD4 - checks to see if the register is there.
; *   ON ENTRY, DADD=B=address of register and C=contents of reg
; *   Status of S9 on entry controls exit if the register isn't
; *   there. Exits to ERRNE if S9=1, else goes to COLD START!
; *   ON EXIT, address of register is in C.X and contents are in B
; *   and hexmode and uses active pointer and A
; * NOTE - CHKAD4 is probably obsolete now. It used to be called by
; * MEMCHK in CN0.  DRC 10/20/79
; *************************************************
CHKADR:       golong  PATCH6
              .public P6RTN
P6RTN:        bcex                  ; save address
              c=data                ; get current content
              setdec
              c=c+1   w             ; logic in here assures
              c=c-1   w             ;  data is in a canonical
                                    ;   form
              ?c#0    s             ; non-positive?
              gonc    CKAD3         ; positive number?
              c=c+1   s             ; negative number?
              goc     CKAD2         ; yes
              c=data                ; assume an alpha string
              c=0     s             ; assure A 1 in digit 13
              c=c+1   s
              legal
              goto    CKAD4
CKAD2:        c=c-1   s             ; restore 9 in sign digit
CKAD3:        ?c#0    xs            ; negative exponent?
              gonc    CKAD3J        ; no.
              c=0     xs            ; assure exp sign = 9
              c=c-1   xs
CKAD3J:       pt=     12
              ?c#0    pt            ; is mantissa normalized?
              goc     CKAD4         ; yes
              c=0     w             ; force whole word to zero
              .public CHKAD4
CHKAD4:
CKAD4:        sethex
              bcex
              a=c                   ; get adr back
              data=c                ; write adr out
              c=data                ; bring adr back in
              ?a#c                  ; get adr back?
              gonc    CKAD10        ; yes
                                    ; reg isn't there
              ?s9=1
              golc    ERRNE
              golong  COLDST
CKAD10:
              c=b                   ; put data back
              data=c
              acex                  ; adr back to C.X
              rtn
; **************************************************
XARCL:        c=b
              c=c-1   s
              ?c#0    s             ; numeric data?
              gonc    REGALP        ; no, alpha data
              gosub   AFORMT        ; numeric data
ARCL10:       ?s13=1                ; running?
              rtn c
              c=regn  14
              st=c
              ?s4=1                 ; SSTFLAG?
              rtn c
              ?s7=1                 ; ALPHA mode?
              rtn nc                ; no
              s8=     1             ; say prompt & no scroll
              gosub   ARGOUT
; *
; * STFLGS - set MSGFLG & DATAENTRY flag
; * Assumes chip 0 enabled.  Leaves SS 1/2 up and REG 14 in C
; *
STFLGS:       c=regn  14
              rcr     1
              st=c
              s1=     1             ; set MSGFLG
              s6=     1             ; set DATAENTRY flag
              c=st
              rcr     13
STFL10:       regn=c  14
              rtn

REGALP:       c=0     x             ; re-enable chip 0
              dadd=c
              pt=     12            ; relies on P active
ARCL20:       sel p
              dec pt
              dec pt                ; move P right 1 byte
              ?pt=    12            ; wraparound?
              goc     ARCL10        ; yes. done
              c=b                   ; put char to G for APNDNW
              g=c
              sel q
              pt=     11
              ?b#0    pq            ; any chars found yet?
              gsubc   APNDNW        ; append to alpha reg

; * APNDNW clobbers A, C, and the active pointer, which is Q here.
              goto    ARCL20
; **************************************************
; * This routine sets the internal display format
; * status.
; **************************************************
XSCI:         c=st                  ; FE00NNNN
              rcr     2             ; XXXXXXXX,FE00NNNN
              c=st                  ; FE00NNNN,FE00NNNN
              rcr     13            ; FE00NNNNFE00,NNNN
              st=c                  ; save NNNNFE00
              c=regn  14            ; get status
              rcr     3             ; move dsp to position
              cstex                 ; move GRAD RAD to status
              ?s0=1                 ; is GRAD set
              gonc    `S1?`         ; no then RAD
              c=c+1                 ; set low bit
`S1?`:        ?s1=1                 ; RAD?
              gonc    DSPDN
              c=c+1                 ; set bit two
              c=c+1
DSPDN:        rcr     11
              goto    STFL10
; ***************************************************************
; * XBEEP - coconut beep
; * Sets up status with a tone number then calls tone as if
; * from keyboard.
; ***************************************************************
XBEEP:
              gosub   TONEB
              ldi     5             ; load a 5
              gosub   TONEB
              ldi     8             ; load a 8
              gosub   TONEB
              .public TONE7X
TONE7X:       ldi     7
TONEB:        st=c                  ; fall into tone
; ******************************************************************
; * XTONE - execute 41-C TONE function
; *
; *  One-digit (0-9) operand function, 0=LOW, 9=HIGH. Tones are not
; *  musical notes. The frequency differences are rather arbitrary.
; *     TONE N     WORD TIMES/CYCLE
; *          9      3
; *          8      4
; *          7      5
; *          6      6
; *          5      8
; *          4     10
; *          3     12
; *          2     14
; *          1     16
; *          0     18
; *  The duration of each tone is equally .25 seconds
; *  If the audio enable flag is not set, silent return.
; *
; * INPUT: 1. ST[7:0] = operand (0-9)
; *        2. chip 0 enabled
; *
; * USES : A, C, ST[7:0], FO[7:0], no PT. + 1 sub level
; *
; * OUTPUT: 1. hexmode
; *         2. FO[7:0] = 0
; *         3. A.X = FFF
; *         4. chip 0 enabled
; * SPECIAL ENTRIES:
; *
; * TONE7X - generates tone 7
; *  Same as XTONE except no operand is required.
; *
; * TONEB - same as XTONE except the operand is in C[1:0]
; *
; ******************************************************************
XTONE:        c=regn  14            ; is beep enabled?
              rcr     7
              cstex
              ?s1=1
              rtn nc                ; no, not enabled
              clr st                ; clear flag out reg
              fexsb
              st=c                  ; save frequency input in ST
              c=0
              ldi     0xff          ; put all 1s in ST
              cstex                 ;  & get count back
              rcr     11            ; place count for look up
              a=c
              rcr     4             ; shift freq into digit 13
              setdec
              c=-c-1  s
              sethex
              gosub   PCKDUR        ; pick .25 second duration
              .con    91            ; constants must be odd
              .con    101
              .con    115
              .con    135
              .con    161
              .con    201
              .con    267
              .con    319
              .con    399
              .con    533
PCKDUR:       c=stk
              c=c+a   m
              cxisa
              acex    x             ; duration now in A.X
                                    ; test for tone 7,8,9
              c=c-1   s
              goc     TONE9
              c=c-1   s
              goc     TONE8
              c=c-1   s
              goc     TONE7
              .newt_timing_start
DELOOP:       a=c     s             ; get freq cntr
              fexsb                 ; turn on tone
1$:           a=a-1   s             ; freq count
              gonc    1$
              a=a-1   x             ; count down duration
              gonc    DELOOP
              rtn

TONE9:        fexsb
              a=a-1   x
              gonc    TONE9
              rtn
TONE8:        fexsb
              nop
              a=a-1   x
              gonc    TONE8
              rtn
TONE7:        fexsb
              nop
              nop
              a=a-1   x
              gonc    TONE7
              .newt_timing_end
              rtn
; *****************************************************
; * This routine sets degrees, radians or grads.
; *****************************************************
XDEG:         gosub   DEGDO
XDEG2:        c=st
              rcr     11
              golong  ANN_14
XRAD:         gosub   DEGDO
              s0=     1
              goto    XDEG2
XGRAD:        gosub   DEGDO
              s1=     1
              goto    XDEG2
DEGDO:        c=regn  14
              rcr     3
              st=c
              s0=     0
              s1=     0
              rtn
; ***************************************************
; * FNDEND - find the high end of RAM
; * Routine starts at reg 0 storing and retrieving
; * the registers addressed until the retrieved
; * value does not match the stored value.
; * Upon return, A[2:0] contains the address of the
; * first nonexistent register.
; * If flag 8 is set and entry is at clear,
; * The routine also clears all data registers.
; * NOTE: FNDEND relies on the tested register being different from
; * what you get when you read a nonexistent register - probably an
; * OK assumption if nonexistent registers give all zeros or all ones.
; ***************************************************
FNDEND:       s8=     0             ; clear clear flag
              c=0                   ; address chip zero
              dadd=c
CLR:          c=regn  13            ; get reg 0
              rcr     3
              c=0     m             ; must have zeros in test
CLEM:         dadd=c                ; address register
              acex                  ; save adr
              c=data                ; save value
              bcex
              c=a                   ; dup adr
              data=c                ; send adr out
              c=data                ; bring it back
              ?a#c                  ; has it changed?
              rtn c                 ; yes so rtn
              bcex                  ; put original val back
              ?s8=1                 ; clear register?
              gonc    OVR0          ; no
              c=0
OVR0:         data=c                ; put val back
              a=a+1                 ; inc adr
              acex                  ; get adr
              goto    CLEM
; *************************************************
; * This routine kills the first six characters
; * in the alpha register.
; *************************************************
XASHF:        gosub   FIND_NO_1     ; find first character
              ?pt=    12            ; 7 in this reg
              gonc    REGG          ; no regular 6 or less
              pt=     2             ; clear top six and done
INSHFT:       c=0     pq
DONSHF:       data=c
              rtn
REGG:         c=0
              data=c                ; clear first reg
              ?pt=    10            ; done six
              rtn c
              acex
              dadd=c                ; address next reg
              c=data
              inc pt                ; clear remaining characters
              inc pt
              inc pt
              inc pt
              goto    INSHFT
; **************************************************
; * This function takes the first six non-nulls
; * in the alpha register and stores them.
; **************************************************
XASTO:        gosub   FIND_NO_1
              ?pt=    12            ; all in this reg?
              gonc    REG           ; no
              rcr     2             ; shift right 2
DONSTO:       pt=     13
              lc      1             ; set one in 13
              lc      0             ;  and clear 12
              cnex                  ; get data address back
              dadd=c
              cnex                  ; get register content back
              goto    DONSHF
REG:          ?pt=    10            ; all in this reg
              goc     DONSTO        ; done
              acex                  ; get adr of next reg
              dadd=c
              c=data                ; get next reg
              inc pt
              acex    wpt           ; combine two reg
SHFLFT:       inc pt                ; shift the
              inc pt
              rcr     12
              ?pt=    11            ; is the pointer in position?
              gonc    SHFLFT
              goto    DONSTO
; ***************************************************
; * This subroutine finds the first non-null in
; * the alpha register.
; ***************************************************
; ***************************************************
FIND_NO_1:    ldi     8             ; load address
              dadd=c
              acex                  ; put address in A
              sel q                 ; set Q at 13 for test and clears
              pt=     13
              sel p                 ; set P at six to clear garbage
              pt=     6
              c=data
              c=0     pq
              pt=     3
`THSIT?`:     a=a-1                 ; dec address
              ?c#0                  ; anything in this reg?
              goc     FOUND1        ; if yes then out
              c=a                   ; otherwise get next reg
              dadd=c
              c=data
              dec pt                ; count down on loop
              ?pt=    0             ; done yet
              gonc    `THSIT?`
              pt=     12
              ?c#0    pq            ; if 7 characters in last rtn
              rtn c
              pt=     10            ; otherwise done  with 10
              rtn
FOUND1:       pt=     0
FNDPT:        dec pt
              dec pt
              ?c#0    pq
              gonc    FNDPT
              rtn                   ; rtn with pointer at first byte
; ***********************************************************
; * The size function places R0 such that coconut contains
; * the correct number of registers.
; * The number of registers is delivered in hex in AX
; * Entry SIZSUB uses S9 to tell whether to go to PACKE or return
; * If there isn't enough room - S9=1 goes to PACKE, S9=0 returns
; * with S9=1 if not successful.
; ***********************************************************
XSIZE:        s9=     1             ; exit via PACKE if
                                    ; unsuccessful
              .public SIZSUB
              acex    X             ; get user spec num of regs
SIZSUB:       n=c                   ; N contains the number needed
              gosub   MEMLFT        ; calculate the mem unused
              m=c                   ; M=unused registers
              gosub   FNDEND        ; find the end of mem
; ****************************************************
; * More or less registers than we have now?
; ****************************************************
              c=0
              dadd=c
              b=a                   ; mem end in B
              c=regn  13
              rcr     3
              a=a-c   x
              c=n                   ; C=registers we need
              a=a-c   x             ; comp # 2 shift left positive
              goc     LARGER        ; user wants more registers
; ****************************************************************
; * Code below sets AX=chain head-where we stop
; *                 AM=-1 dec
; *                 BX=from address-where we get data
; *                 BM=to address-where we put data
; ****************************************************************
              s8=     1             ; set clean up flag 0
              c=b                   ; CX=to
              acex
              m=c                   ; save shift distance
              c=a-c                 ; CX=from
              rcr     3
              bcex    x             ; C=FRMXXXXXXXXTO
              rcr     11
              bcex                  ; B=TOFRM
              c=regn  13            ; get test address
              c=0     m
              c=c-1   m
              acex                  ; A=INCTST
              goto    STRTMV
; *******************************************************
; * Sets up as for smaller except we stop at nothingness
; * and start at chain end using 1 for an increment.
; *******************************************************
LARGER:       c=m                   ; get unused reg
              c=c+a   x             ; add neg shift
              goc     LARG10        ; made it
              ?s9=1                 ; exit mode?
              golc    PACKE
              s9=     1             ; SAY DIDN'T MAKE IT
              rtn

LARG10:       c=regn  13            ; A=NEGSHFT C=FROM
              c=c+a   x             ; C=TO
              rcr     11
              bcex                  ; C=txt B=TOXXX
              c=0     m
              c=c+1   m             ; C=INCTST
              acex
              m=c                   ; save neg shift
              c=regn  13            ; C=FROM
              bcex    x             ; B=TOFRM
              goto    STRTMV
; *****************************************************
; * This routine shifts memory either left or right
; * according to the inputs in A and B.
; *****************************************************
KPMVN:        rcr     11            ; C=TOFRM
              c=c+a   m             ; inc TO
              bcex                  ; C=DATA B=TOFRM
              data=c                ; data moved
STRTMV:       bcex                  ; A=INCTST C=TOFRM
              acex                  ; C=TOFRM A=INCTST
              ?s8=1                 ; smaller move?
              gonc    CHKTOP        ; no
              ?a<c    x             ; is FRM<TST
              gonc    GETREG        ; if no continue
`B=0`:        acex                  ; get 0 for to
              b=0
              goto    DOTO
CHKTOP:       ?a#c    x             ; zeros after mem end
              gonc    `B=0`
GETREG:       acex                  ; A=INCTST C=TOFROM
              dadd=c                ; DADD=FROM
              bcex    m             ; save to PART
              rcr     11            ; INC DEC FROM
              c=c+a   m
              rcr     3
              bcex    x             ; A=INCTST B=TOFROM
              c=data
              bcex
DOTO:         rcr     3             ; C=FRMXX...XX0TO
              dadd=c                ; DADD=TO
              ?a#c    x             ; done if TO=TST
              goc     KPMVN         ; no
              bcex                  ; clear last register
              data=c
; **************************************************
; * Fix pointers after move.
; **************************************************
              c=m                   ; get move distance
              bcex                  ; save
              gosub   GETPC         ; enable chip 0
              ?s10=1                ; ROM RAM?
              goc     NOTRAM
              a=a+b   x             ; shift PC
NOTRAM:       abex                  ; B=PC for CLRSB2
              c=regn  13
              c=c+a   x
              rcr     3
              c=c+a   x
              rcr     8
              c=c+a   x
              rcr     3
              regn=c  13
              abex                  ; bring PC back to A[3:0]
              s9=     0
              golong  DCRT10
              .public SETSST
; *
; * SETSST - set single step bit
; * Requires chip 0 enabled on input
; * DESTROYS C
; *
SETSST:       c=regn  14
              st=c
              s4=     1             ; SET SST BIT
              c=st
              regn=c  14
              rtn
