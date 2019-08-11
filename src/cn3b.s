;;; This is HP41 mainframe resurrected from list file output. QUAD 3
;;;
;;; REV.  6/81A
;;; Original file CN3B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @6000-7777
; *

              .section QUAD3

              .public ABTS10
              .public ABTSEQ
              .public AJ2
              .public AJ3
              .public DSPLN_
              .public FDIG20
              .public FDIGIT
              .public IND
              .public MIDDIG
              .public NEXT
              .public NEXT1
              .public NEXT2
              .public NEXT3
              .public NLT000
              .public NLT020
              .public NULTST
              .public NULT_
              .public NULT_3
              .public NULT_5
              .public PAR112
              .public PARA60
              .public PARS56
              .public PARS75
              .public PARSE
              .public PARSEB
              .public STK


; *
; * CLRSB2 - clear user subroutine stack and clobber line number
; * ON ENTRY - PT=3, chip 0 enabled, new PC in B[3:0] in MM form
; * USES B[3:0], A[3:0], C
; * Exits via PUTPCX, which clobbers the line number only if S13=0.
; *
; * CLRSB3 - entry point to finish pushing the subroutine stack
; * ON ENTRY - C[13:4] has what should go into REG 12[13:4].
; *     PT=3, chip 0 enabled, new PC in B[3:0] in MM form
; * otherwise the same as CLRSB2
; *
              .public CLRSB2
              .public CLRSB3
CLRSB2:       c=0
              regn=c  11
CLRSB3:       regn=c  12
              abex    wpt
              goto    CLRSBX
              .fillto 5
; *
; * PARSE - key sequence parser
; * ENTRY CONDITIONS: chip 0 selected, hex, P sel
; *
PARSE:
              c=regn  14            ; load status set 1/2
              rcr     1
              st=c
              clrabc
              c=keys
              rcr     5             ; KC to C[13:12]
              ldi     0xc1          ; @6020\16
              rcr     10
              pt=     3
              gotoc
              .fillto 0x10
              nop                   ; causes col 0 to map
                                    ; onto column 1
              lc      0             ; 1
              goto    PAR003        ; 2
              lc      1             ; 3
              goto    PAR003        ; 4
PAR001:       lc      2             ; 5
              goto    PAR003        ; 6
              goto    PAR001        ; 7
              lc      3             ; 8
              goto    PAR003        ; 9
CLRSBX:       golong  PUTPCX
              .fillto 0x1c
              lc      4             ; C
PAR003:       rcr     1             ; C[2:1]=logcol,row
              a=c     x             ; A[2:1]=logcol,row
              ?s4=1                 ; shiftset?
              gonc    PAR005        ; no
              ldi     0x80          ; adj row for shift
              c=a+c   x
PAR005:       n=c                   ; N[2:1]=log KC
              ?s5=1                 ; PKSEQ?
              gonc    NEWFCN        ; no

                                    ; continuing key sequence
                                    ; A[2:1]=logcol, row
                                    ; A[0]=0, A.M=0
                                    ; row does not have shift
                                    ; adjustment in it
              acex
              pt=     1
              c=c+c   pt
              c=c+c
              c=c+c
              c=c+c
              rcr     13
              pt=     6
              lc      1             ; PKTTAB is at @10000
              cxisa
              rcr     1             ; construct PTEMP1
              c=c+c   x
              c=c+c   x
              .public PARS05
; * Entry point for Wand on 3-13-79
; *
PARS05:
              a=c
              pt=     0
              c=regn  15
              rcr     3
              g=c                   ; restore PTEMP2 to G
              a=a+c   pt            ; merge operand type info
              acex    x
              st=c                  ; put up PTEMP1
              s9=     0             ; say address not found yet
              gosub   ENLCD         ; turn on LCD chip
              ldi     32            ; BLANK
              a=c     x             ; blank to A.X
              b=a     x             ;  and B.X
              pt=     1
PARS10:       rabcr                 ; right-justify LCD
              ?a#c    wpt
              gonc    PARS10
              a=a-1   wpt           ; turn blank into prompt
PARS20:       ?a#c    wpt           ; not a prompt?
              goc     PARS30        ; not a prompt
              c=b     x             ; retrieve blank
              slsabc                ; get rid of prompt
              srsabc
              rabcr                 ; shift off something
              goto    PARS20
PARS30:       rabcl

              a=a+1   s             ; check for backarrow
              rtn c
              a=a-1   s
              c=stk
              c=c+1   m             ; increment return address
              gotoc                 ; on exit, PT=1, LCD chip on,
                                    ; SS PTEMP1 up, B.X=blank
; *
; * NEWFCN - new function
; * First key of a new key sequence
NEWFCN:                             ; on entry, SS1/2 up, chip 0
                                    ; on, KC in C[2:1] B=0
              a=c     x             ; A[2:1]=log KC
              c=regn  14
              st=c                  ; put up SS0
              ?s7=1                 ; alphamode?
              gonc    PARS50        ; no
              ldi     0x155         ; H1550\16=H155
              goto    PARS55

PARS50:       rcr     6
              st=c                  ; put up SS3
              ?s4=1                 ; USER mode?
              gonc    PARS52        ; no
              gosub   TBITMP        ; yes. test bit map
              ?c#0                  ; key reassigned?
              golc    RAK60         ; yes
              c=regn  14
              st=c                  ; put up SS0 again
              ?s3=1                 ; PRGM mode?
              goc     RAK10         ; yes - skip auto-assign tests
              c=n
              c=0     m
              rcr     2             ; log row to C.S
              a=c     x             ; log col to A.X
              ldi     0x66          ; row 0 offset
              c=c-1   s             ; row 0?
              goc     RAK05         ; yes
              pt=     0
              lc      11            ; set up row 1 offset
              ?c#0    s             ; row#1?
              gonc    RAK05         ; row 1
              pt=     1
              lc      7             ; set up shifted row 0 offset
              c=c+1   s
              c=c+c   s             ; shifted?
              gonc    RAK10         ; no
              ?c#0    s             ; not shifted row O?
              goc     RAK10         ; not auto-assigned
RAK05:        c=a+c   x             ; C.X=implied local label

              .public RAK06
; * Entry point add for Wand on 3-13-79
; *
RAK06:
              m=c                   ; save operand in M
              a=c                   ; set up A[1:0] for search
              gosub   SEARCH
              ?c#0                  ; found?
              goc     PARS60        ; yes
RAK10:                              ; key is not reassigned
              c=n                   ; retrieve logical KC
              a=c                   ; restore log KC to A[2:1]
PARS52:       c=regn  14
              st=c                  ; put up SS0
              ldi     0x150         ; H1500\16= hex 150
                                    ; normal mode default table
PARS55:                             ; ST has SS0
                                    ; log KC in A[2:1]
                                    ; default table addr\16 in C.X
              c=0     s
              rcr     12
              c=a+c   x
              rcr     12            ; C[6:3]=table address
              cxisa

              .public PARSDE
; * Entry point for Wand to execute data entry key (3-15-79)
; *
PARSDE:
              c=c-1   xs            ; data entry key?
              gsubc   DATENT        ; goes to DATENT w/ ASCII
                                    ; or DE FC or 0 for BKARROW
                                    ; IN C[1:0] & W/ SS0 up
PARS56:                             ; CHS, CLX, DELETE,
                                    ; storage arithmetic,
                                    ; and STOP re-enter here.
                                    ; Entry requirements:
                                    ; FC in C.X, chip 0 on,
                                    ; SS0 up
              rcr     11            ; FC to digits 4,3
              bcex                  ; save in B
              c=regn  10
              pt=     4
              c=b     wpt           ; merge FC to digits 4,3 of REG 10
              c=0     x
              regn=c  10
              ?s3=1                 ; program mode?
              gonc    PARS57
              ?c#0    pt            ; programmable?
              gonc    PARS57        ; not programmable
              pt=     1
              c=c+1   pt            ; set insert bit
PARS57:       pt=     0             ; save PTEMP2 in G
              g=c
              st=c                  ; put up PTEMP2
              c=b                   ; recover FC to C[4:3]
              rcr     5             ; FC to digits 13:12
              ldi     0x14          ; H14=@12000\256 main FCN table
              rcr     9
              cxisa                 ; get XADR
              pt=     3
              lc      1
              rcr     11            ; full XADR in C[6:3]
              m=c                   ; save XADR in M
              stk=c                 ;  and on subr stack
              cxisa                 ; get C(XADR)
#if defined(HP41CX)
              golong  LB_38D6
#else
              ?c#0    x             ; not XKD?
              goc     PARS70        ; not XKD.
#endif
; * Entry point added for HP-41CX
              .public PARS59
PARS59:       c=regn  14
              st=c                  ; put up SS0
              rtn                   ; go execute immediately

PARS60:
              cmex                  ; save adr in M,
                                    ; retrieve argument to C
              acex    x             ; put arg to A.X for ROW940
              b=a     x             ;  & save arg in B.X
              gosub   OFSHFT
              gosub   CLLCDE
              ldi     0xe0          ; FC for XEQ
              gosub   PROMF1        ; prompt "XEQ "
              s1=     0             ; set up for ROW940
              gosub   ROW940        ; prompt argument
              ldi     0xe0          ; set up for NLT020
                                    ; FC for XEQNN
              pt=     0             ; clear insert bit in G
              g=c                   ;  for NLT020
              rcr     11
              a=c
              abex    x             ; now FC in A[4:3]
                                    ; arg in A[1:0]
; * Arg is preserved here for the benefit of the printer.  Since S9 is
; * set when we get to XEQ NN, XEQNN never looks at the argument at all.
              s9=     1             ; tell XEQNN that address
                                    ; is already known in M
              golong  NULT_5

; * Entry point added for HP-41CX
              .public PARS70
PARS70:       s9=     0             ; initialize S9.
                                    ; S9=1 tells AXEQ & XEQNN
                                    ; that their address has
                                    ; already been found and is
                                    ; in M.
PARS75:                             ; return from AXEQ & RASNKY
                                    ; for microcoded XROM FCNs
                                    ; * entry REQ for PARS75:
                                    ; * PTEMP2 in status bits
                                    ; * & M=XADR
              gosub   OFSHFT        ; turn off shift
              gosub   DSPLN_        ; enable and clear LCD
                                    ; if insert then inc & dsp line#
              c=m                   ; retrieve XADR
              gosub   PROMF2        ; PROMF2 returns S8=0
                                    ; XROM microcode FCNs rely on
                                    ; S8=0 here
                                    ; (when S9 is set, S8 tells
                                    ; xrom whether the FCN is
                                    ; microcode or user lang)
              c=m                   ; retrieve XADR again
              c=c-1   m             ; point to XADR-1
              cxisa                 ; op1 to C.XS
              ?c#0    xs            ; op1 # 0?
              golnc   NLT000        ; no operand
              c=c+c   xs
              c=c+c   xs
              a=c     xs            ; A.XS=4*op1
              c=c-1   m             ; point to XADR-2
              cxisa                 ; C.XS=op2
              c=a+c   xs
              rcr     2
              st=c
              s3=     0             ; clear op1 bit 1
              cstex                 ; op1 bit 1 still exists
                                    ; in ST, but is clear in C
              pt=     0
              acex    pt
              c=g
              acex    pt            ; merge optype into PTEMP2
              g=c                   ; put PTEMP2 back to G
              ?s3=1                 ; op1 bit 1?
              gonc    PARSEA        ; no


PAR110:       gosub   NEXT2
              .public PAR111        ; added for Wand 11/5/79
PAR111:
              goto    ABTSEQ        ; must be short goto!!!
              ?s4=1                 ; A...J?
              golc    AJ2           ; yes
              ?s3=1                 ; digit?
              gonc    PAR115        ; no
              gosub   FDIGIT
PAR112:       gosub   BLINK
              goto    PAR110
PAR115:       ?s2=1                 ; op1 bit 0?
              golc    PARSEB        ; yes
              ?s6=1                 ; shift?
              golc    IND           ; yes
              ?s1=1                 ; op2 bit 1?
              goc     PAR112        ; yes
PAR130:       ?s7=1                 ; DP?
              golc    STK           ; yes
              ?s0=1                 ; op2 bit 0?
              goc     PAR112
                                    ; must be STO
              ?a#0    S             ; +-*/ ?
              gonc    PAR112        ; no
              ldi     145           ; yes
              acex
              rcr     13
              pt=     0
              a=a+c   pt
              legal
              gosub   LDSST0
              acex
              golong  PARS56        ; start over with new FC

; *
; * ABTSEQ - abort partial key sequence
; *
; * Note that ABTSEQ doesn't clear alpha mode, which may be set if we're
; * in the middle of keying in an alpha operand.  If it is desired to
; * ensure that the alphamode flag and annunciator are cleared, then
; * do a golong to NAME33, which clears alpha mode and then jumps to
; * ABTSEQ.
; *
ABTSEQ:       gosub   CLLCDE        ; clear display
              gosub   ANNOUT
ABTS10:       gosub   PRT4
              gosub   RSTSEQ        ; clear SHIFTSET, PKSEQ,
                                    ; MSGFLG, DATAENTRY,
                                    ; CATALOGFLAG, & PAUSING
              golong  NFRKB

PARSEA:                             ; ALPHA name ALPHA
                                    ; 1-digit numeric
                                    ; 3-digit numeric
              ?s0=1                 ; op2 bit 0?
              gonc    PARA05
                                    ; 1-dig or 3-dig numeric
              ?s1=1                 ; op2 bit 1?
              gonc    PARA50

                                    ; 1-digit numeric
                                    ; ALPHA name ALPHA
PARA05:       gosub   NEXT1
              .public PARA06        ; added for Wand 11/5/79
PARA06:
              goto    ABTSEQ        ; must be short goto!!
              ?s0=1                 ; op2 bit 0?
              gonc    PARA45
              ?s4=1                 ; A...J?
              golc    FDIG20        ; yes
              ?s3=1                 ; digit?
              golc    FDIG20        ; yes
              ?s6=1                 ; shift?
              golc    IND           ; yes
PARA10:       gosub   BLINK
              goto    PARA05

PARA45:                             ; ALPHA name ALPHA
              ?s5=1                 ; ALPHA key?
              golc    NAMEA         ; yes
              goto    PARA10

PARA50:                             ; 3-digit numeric
PARA60:       gosub   NEXT3
              .public PARA61        ; for the Wand
PARA61:
              goto    ABTSEQ
              ?s4=1                 ; A...J?
              golc    AJ3           ; yes
              ?s3=1                 ; digit?
              gonc    PARA70        ; no
              gosub   MIDDIG
PARA65:       gosub   BLINK
              goto    PARA60

PARA70:       c=keys                ; check for EEX
              rcr     3
              a=c     wpt
              ldi     0x83          ; KC for EEX
              ?a#c    wpt
              goc     PRA110

              .public PARA75
; *  Entry point add for Wand on 3-13-79
; *
PARA75:
              ldi     0x31
              slsabc
PARA80:       gosub   NEXT3
              goto    PRA100
              ?s3=1                 ; digit?
              gsubc   MIDDIG
PARA90:       gosub   BLINK
              goto    PARA80

PRA100:       rabcr
              goto    PARA60

PRA110:       ?s1=1                 ; op2 bit 1? (GTO.?)
              gonc    PARA65        ; no
              ?s7=1                 ; DP key?
              goc     PRA115        ; yes
              ?s5=1                 ; ALPHA key?
              gonc    PARA65        ; no
              gosub   ENCP00        ; yes
              a=0     x
              a=a-1   x
              a=a-1   x             ; generate FFE in A.X
              c=regn  10
              acex    x             ; merge FFE with REG 10
              regn=c  10
              goto    XFRNMA
PRA115:                             ; GTO..
              rabcr                 ; retrieve DP from LCD
              rabcl                 ; put back first DP
              slsabc                ; add a second DP
              a=0     x             ; set argument
              a=a-1   x             ;  to FFF
              golc    NULT_3

PARSEB:                             ; INPUT: SS=PTEMP1, LCD on,
                                    ;  HEX, PSEL, P=1
                                    ; GTO, LBL, and XEQ
              gosub   ENCP00        ; re-enable chip 0
              c=regn  10            ; get parse temps
              rcr     3             ; FC now in digits 1:0
              a=c                   ; save REG 10 in A
              ?s0=1                 ; op2 bit 0?
              goc     PARB20        ; yes
                                    ; LBL
              ldi     0xcd          ; load FC for ALBL
PARB10:       ?s5=1                 ; ALPHA key?
              goc     PARB15
              gosub   ENLCD
              golong  PAR112

PARB15:       acex    wpt
              acex
              rcr     11
              regn=c  10
              c=g                   ; PT=1 here from NEXT
              st=c                  ; set bit 1 of PTEMP2
              s5=     1             ;  (say null string not allowed)
              c=st
              g=c
XFRNMA:       golong  NAMEA

PARB20:       ?s6=1                 ; SHIFT?
              gonc    PARB30
              ldi     0xae          ; load FC for GTO/IND
              acex    wpt
              acex
              rcr     11
              regn=c  10
              ?s1=1                 ; op2 bit 1?
              goc     INDGTO
              goto    INDXEQ

PARB30:       ldi     0x1e          ; FC for AXEQ
              ?s1=1                 ; op2 bit 1?
              gonc    PARB10        ; XEQ
              c=c-1   x             ; convert to FC for AGTO
              ?s7=1                 ; GTO   DP KEY?
              gonc    PARB10

              .public PARB40
; * Entry point for Wand (3-15-79)
; *
                                    ; GTO .NNN
PARB40:
              pt=     0             ; reset insert bit
              c=g                   ;  in PTEMP2
              cstex
              s4=     0
              cstex
              g=c
              pt=     1
              ldi     1             ; FC for GTOL
              acex    wpt
              acex
              rcr     11
              regn=c  10
              gosub   CLLCDE
              ldi     0xd0          ; FC for GTO
              gosub   PROMF1
              srsabc
              ldi     0x60          ; " ."
              slsabc
              golong  PARA60


; * IND - takes care of indirect operands
; *
IND:          gosub   ENCP00
INDXEQ:       pt=     0
              c=g
              cstex
              s6=     1             ; indirect
              cstex
              g=c
INDGTO:
              gosub   ENLCD
              gosub   MESSL
              .con    9             ; I
              .con    14            ; N
              .con    4             ; D
              .con    0x220         ; blank


IND20:        gosub   NEXT2
              .public IND21         ; added for Wand 11/5/79
IND21:
              goto    ABTXF3        ; must be short goto!!
              ?s4=1                 ; A...J?
              goc     AJ2
              ?s7=1                 ; DP?
              goc     STK
              ?s3=1                 ; digit?
              gonc    IND30
              gosub   FDIGIT
IND30:        gosub   BLINK
              goto    IND20


; * AJ3 and AJ2 - take care of A...J keys for 3- and 2-digit operands
; *
AJ3:                                ; GTO.--- or FC---
              ldi     0x30          ; zero
              slsabc
              goto    AJ210

AJ2:                                ; FC IND-- or FC--
              ldi     0x30          ; zero
AJ210:        ?a#0    s
              goc     AJ220
              c=c+1
AJ220:        slsabc
              rcr     1
              acex    s
              rcr     13
              slsabc
              golong  NULT_

MIDDIG:
              acex    s
              rcr     13
              lc      3
              c=0     xs
              slsabc
MID10:        gosub   NEXT2
              goto    MID20
              ?s3=1                 ; digit?
              gonc    MID15
              gosub   FDIGIT
MID15:        gosub   BLINK
              goto    MID10

MID20:
              rabcr
              rtn

ABTXF3:       golong  ABTSEQ

; *
; * STK - handles stack register operands X,Y,Z,T,L
; *
STK:
STK03:        gosub   MESSL
              .con    19            ; S
              .con    20            ; T
              .con    0x220         ; blank
              gosub   NEXT1

              .public STK00         ; for the Wand
STK00:
              goto    ABTXF3        ; must be short goto!!
              ldi     0x20          ; blank
              srsabc
              srsabc
              srsabc

              .public STK04
; * Entry point for Wand (3-16-79)
; *
STK04:
              gosub   GTACOD        ; get alpha code[keycode]
              pt=     13
              lc      4             ; set for LastX
              a=c                   ; REG index in A.S, char in A.X
              ldi     76            ; "L"
              ?a#c    x
              goc     STK20
STK05:        gosub   MASK          ; put char out to LCD
              gosub   LEFTJ
              gosub   ENCP00
              pt=     0             ; get PTEMP2
              c=g
              st=c
              c=regn  10
              pt=     2
              lc      7
              ?s6=1                 ; indirect?
              gonc    STK10
              pt=     2
              lc      15
STK10:
              acex
              rcr     12
              acex    PT
              golong  NLT020

STK15:        gosub   BLINK
              goto    STK03

STK20:        ldi     87            ; "W"
STK30:        a=a-1   s
              ?a#0    s
              gonc    STK40
              c=c+1   x
              ?a#c    x
              goc     STK30
              goto    STK05

STK40:        ldi     84            ; "T"
              ?a#c    x
              gonc    STK05
              goto    STK15


; * FDIGIT - final digit
; * ENTRY CONDITIONS: A.S=second to last digit, hex, P sel,
; *     LCD chip on, status set PTEMP1 up
FDIGIT:                             ; shift prompts off right end of LCD
              c=0
              acex    s
              rcr     13
              pt=     1
              lc      3
              slsabc                ; send digit to display
FDIG10:
              gosub   NEXT1
              goto    FDIG30        ; backarrow return (short goto!!!)
              ?s3=1                 ; digit?
              goc     FDIG20        ; yes
              gosub   BLINK
              goto    FDIG10
FDIG20:
              c=0
              acex    s
              rcr     13
              lc      3
              slsabc                ; send digit to display
              goto    NULT_

FDIG30:
              rabcr                 ; shift digit off
              rtn


NEXT1:        ldi     31
              goto    NXT1E
NEXT2:        ldi     31
              goto    NXT2E
NEXT3:        ldi     31
              slsabc
NXT2E:        slsabc
NXT1E:        slsabc
NEXT:         gosub   LEFTJ
              gosub   ENCP00
              c=regn  15            ; save PTEMP2 in
              pt=     3             ;  REG 15[4:3]
              c=g
              regn=c  15
              c=regn  14
              rcr     1
              st=c
              s5=     1             ; set PKSEQ
              s1=     1             ; set MSGFLG
              c=st
              rcr     13
              gosub   ANN_14
              gosub   RSTKB
              golong  WKUP10

; *
; * NULT_ - null test following numeric operand
; * ENTRY CONDITIONS: P sel, LCD on
NULT_:
              pt=     13            ; initialize # of digits counter
              lc      15
              pt=     1
              a=c                   ; # of digits counter in A.S
NULT_1:       rabcr
              a=a+1   s
              st=c
              ?s4=1
              goc     NULT_1        ; shift until " " or " ."
              a=0     x             ; initialize sum
NULT_2:       rabcl
              c=0     pt
              c=0     xs
              a=a+c   x
              a=a-1   s             ; decrement # of digits
              goc     NULT_3
              acex    x             ; multiply by 10
              c=c+c   x
              a=c     x
              c=c+c   x
              c=c+c   x
              a=a+c   x
              legal
              goto    NULT_2

NULT_3:
              pt=     0
              c=g
              st=c                  ; put up PTEMP2
              ?s6=1                 ; indirect?
              gonc    NULT_4        ; no
              ldi     128
              a=a+c   x             ; set indirect bit
NULT_4:       b=a     x             ; save arg in B.X
              gosub   LEFTJ
              gosub   ENCP00
              c=regn  10            ; get FC
              a=c                   ; FC to A[4...]
              ?s5=1                 ; XROM?
              goc     NLT020        ; yes. arg in B.X only
              a=b     x             ; copy arg to A.X
NULT_5:       asl     x             ;  & COZY UP TO FC
              goto    NLT020        ; FC,arg in A[4:1]

NLT000:
              gosub   LEFTJ
              gosub   ENCP00
              c=regn  10
              a=c                   ; save FC in A
              ldi     200
              .newt_timing_start
              disoff
NLT010:       rst kb
              chk kb
              gonc    NLT030
              c=c-1   x
              gonc    NLT010
              distog
              .newt_timing_end
NLT020:                             ; for entry here,
                                    ; FC, arg in A[4:1]
              gosub   NULTST
              goto    NLT040
NLT030:       gosub   RST05         ; debounce key up
              gosub   CLLCDE
              distog
              gosub   ENCP00
              .public NLT040
NLT040:                             ; key is up. go execute FCN
                                    ; first give printer a chance
              gosub   PRT5
              gosub   RSTSEQ        ; clear SHIFTSET, PKSEQ,
                                    ; MSGFLAG, DATAENTRY,
                                    ; CATALOGFLAG, & PAUSING
                                    ; leaves SS0 up
              pt=     0
              c=g
              cstex                 ; get PTEMP2
              ?s4=1                 ; insert?
              gonc    NLT050        ; no
              ?s12=1                ; private?
              goc     AB10XF        ; yes
              acex
              rcr     5
              golong  INSLIN

NLT050:       cstex                 ; bring back SS0
              c=0
              pt=     4
              lc      15            ; put NFRPU (@360)
              stk=c                 ;  on the subroutine stack
              acex
              rcr     5
              ?c#0    s
              golc    XCUTE
              abex    x             ; retrieve 3-digit argument
              golong  XCUTB1        ;  from B.X to A.X

; *
; * NULTST - null test
; *
NULTST:                             ; null test
              ldi     576           ; initialize null timer
              c=c+c   x
              .newt_timing_start
NULT10:       rst kb
              chk kb                ; key up yet?
              golnc   RST05         ; go debounce
              c=c-1   x             ; no. decrement counter
              gonc    NULT10
              .newt_timing_end
              s8=     0             ; don't print message
              gosub   MSGA          ; key down too long
              xdef    MSGNL
              ldi     1000
              .newt_timing_start
NULT20:       c=c-1   x             ; 310 millisec delay
              gonc    NULT20        ;  so "NULL" can be seen
              .newt_timing_end
AB10XF:       golong  ABTS10

              .public NAME20
              .public NAMEA
              .public NAME21
              .public NAM40
              .public NAM44_
              .public NM44_5
              .public NAME4A
              .public NAME4D
; *
; * Parse logic for alpha operands starts here
; *
NAMEA:                              ; on entry, SS is scratch
              gosub   ENCP00
              gosub   PRT3
              .public PR3RT         ; for printer
PR3RT:
              c=regn  14
              cstex
              s7=     1             ; set alpha mode
              cstex
              regn=c  14
              c=0                   ; initialize alpha operand
              regn=c  9
NAME10:       gosub   ENLCD
NAME20:       gosub   NEXT1
              goto    NAME30        ; backarrow
NAME21:                             ; on entry here, PT=1,
                                    ; LCD chip on, SS PTEMP1 up
              ?s6=1                 ; shift key?
              golnc   NAM40
              gosub   TOGSHF        ; toggle shift key
              goto    NAME10

              .public NAME33        ; used by card rdr logic
                                    ; to abort a partial
                                    ; key sequence
                                    ; may also be used by
                                    ; printer logic
NAME33:       gosub   LDSST0
              s7=     0             ; clear alpha mode
              c=st
              regn=c  14
              golong  ABTSEQ

NAME30:                             ; on entry, PT=1, LCD chip on
              gosub   ENCP00        ; bkarrow hit
              c=regn  9
              ?c#0                  ; any chars to delete?
              gonc    NAME33        ; no
              rcr     12            ; yes. delete one char
              c=0     wpt
              regn=c  9
              gosub   OFSHFT
              gosub   ENLCD
              rabcr                 ; shift off one character
NAME31:       goto    NAME20

NAME34:       ?s1=1                 ; op2 bit 1?
                                    ; (is empty operand an error?)
              gonc    NAME42        ; no

NAME35:       gosub   BLINK
              goto    NAME10

              .public NAME37
; * Entry point add for Wand on 3-13-79
; *
NAME37:       gosub   GTACOD
              a=c     x             ; copy character to A.X
              gosub   OFSHFT
              a=a-1   xs            ; is it a character?
              gonc    NAME35        ; no
              pt=     1
              ldi     127           ; lazy "T"
              ?a#c    wpt
              gonc    NAME35
              ldi     58            ; colon
              ?a#c    wpt
              gonc    NAME35
              ldi     46            ; D.P.
              ?a#c    wpt
              gonc    NAME35
              ldi     44            ; comma
              ?a#c    wpt
              gonc    NAME35
              c=regn  9
              ?c#0    wpt           ; full already?
              goc     NAME35        ; full
              acex    wpt           ; add character to REG 9
              a=c     wpt           ; restore character to A.X
              rcr     2             ; -
              regn=c  9             ; -
                                    ; add char to display
              bcex                  ; save operand in B
              gosub   ENLCD
              gosub   MASK          ; transliterate char and
                                    ; send to display
                                    ; note mask decrements B.S
              goto    NAME31
              .fillto 0x334         ; preserve entry table


NAM40:        gosub   ENCP00
              ?s5=1                 ; ALPHA key?
              gonc    NAME37
              pt=     1
              c=regn  9
              ?c#0                  ; any chars in operand?
              gonc    NAME34        ; no
              gosub   RTJLBL        ; right-justify operand
NAME42:       regn=c  9             ; put back right-justified
                                    ; operand
              c=regn  14            ; put up SS0
              st=c
              s7=     0             ; clear alpha mode
              c=st
              gosub   ANN_14        ; store status sets and
                                    ; update ALPHA annunciator
              c=regn  10
              rcr     3
              a=c     x             ; FC to A.X
              ldi     15            ; FC for ASN
              ?a#c    wpt           ; FC # ASN?
              golnc   KEYOP         ; this is ASN
              b=a     x             ; save FC in B.X
              gosub   ENLCD         ; this is not ASN
              gosub   LEFTJ
              gosub   ENCP00
              c=regn  9
              sel q
              pt=     13
              sel p
              pt=     2
              ?c#0    pq            ; more than 1 char in label?
              gsubnc  ALCL00        ; no. test for local ALPHA LBL
              abex    x             ; retrieve FC from B
              ldi     0x1e          ; FC for AXEQ
              pt=     1
              ?a#c    wpt           ; FC # AXEQ?
              goc     NAME46        ; not AXEQ
              c=regn  9
              m=c
              gosub   ASRCH
              ?c#0                  ; found?
              goc     NAME44        ; yes
              c=regn  14            ; restore SS0
              st=c
              c=regn  15            ; restore PTEMP2 to G
              rcr     3
              pt=     0
              g=c
              ?s3=1                 ; program mode?
              goc     NAME46        ; yes
              c=regn  10            ; restore FC to A
              a=c                   ; for PRT5
              gosub   PRT5
              gosub   RSTSEQ
              golong  ERRNE

NAME44:       ?s9=1                 ; microcode FCN?
              goc     NAME48        ; yes

; * User program. PC in C[3:0].
; * If in ROM then S2=1 and XROM in C[7:4]
              m=c                   ; save PC in M
              rcr     4
              n=c                   ; put XROM to N[3:0]
NAM44_:

; * Entry conditions for NAM44@
; * S2=1 for ROM, S2=0 for RAM
; * PC in M[3:0]
; * If ROM, then XROM in N[3:0]
; * If RAM, then AXEQ already in place in REG 10
              s9=     1             ; say address already known
NM44_5:
; * Instructions below to clear and set S5 may not be necessary
; * because NLT020 doesn't look at S5.
              s5=     0             ; clear ROM bit for NLT020
              ?s2=1                 ; ROM?
              gonc    NAM44A        ; no
              s5=     1             ; set ROM bit for NLT020
              c=n                   ; get XROM to C[3:0]
              gosub   STORFC
NAM44A:       s4=     0             ; clear insert bit for NLT020
              c=regn  14
              cstex                 ; put up SS0
              ?s3=1                 ; program mode?
              gonc    NAM44B        ; no
              st=c
              s4=     1             ; set insert bit for NLT020
              c=st
NAM44B:       st=c                  ; temp status up & in C
              pt=     0
              g=c                   ; temp status to G for NLT020
              ?s9=1                 ; is address known?
              gonc    NAME46        ; no
              gosub   DSPLN_        ; enable and clear display
                                    ; if S4 then inc & dsp line#
              gosub   ENCP00
              c=m                   ; put label addr to
              a=c                   ;  A[3:0]
              gosub   TXTLBL
NAME46:       c=regn  10
              a=c                   ; FC to A[4:1]
              b=a     x             ; in case this is GTO .ALPHA
              golong  NLT020

NAME48:                             ; microcode FCN
              ?s5=1                 ; mainframe?
              gonc    NAME4C        ; no
                                    ; yes. FC is in C[5:4]
              rcr     4             ; FC to C.X
              c=0     xs
              a=c                   ; new FC to A.X
NAME4A:       c=regn  14
              st=c                  ; put up SS0
              acex                  ; bring back FC to C
              s9=     0             ; restore S9=0
                                    ; (not an auto-reassigned FCN)
              golong  PARS56

NAME4C:
; * We come to NAME4C from ASRCH in the AXEQ logic
; * XADR is in C[3:0] and XROM is in C[7:4]
              m=c                   ; save XADR in M[3:0]
              rcr     4             ; move XROM to C[3:0]
NAME4D:
; * Reparse logic for microcoded XROM functions
; * On entry, XADR is in M[3:0] and XROM is in C[3:0]
              gosub   STORFC        ; put XROM to REG 10
              c=regn  14            ; get SS0
              st=c
              pt=     1
              c=m                   ; get XADR
              rcr     11            ; put XADR to C.M
              m=c                   ; put XADR to M[6:3]
              ?s3=1                 ; program mode?
              gonc    NAME4F        ; no
              cxisa
              ?c#0    X             ; programmable?
              gonc    NAME4E        ; no
              lc      3             ; set XROM bit(5)
                                    ; & insert bit(4)
              goto    NAME4G
; * For microcode FCNs in plug-in ROMs, if C(XADR)=0 then we look
; * at C(XADR+1) to determine whether the FCN should be executed on
; * key down.  If C(XADR+1)=0 then the FCN is XKD else the FCN is
; * a normal non-programmable function.
NAME4E:       c=c+1   m
              cxisa
              ?c#0    x             ; is C(XADR+1) non-zero?
              goc     NAME4F
              gotoc                 ; XKD FCN - go do it

NAME4F:       lc      2             ; set XROM bit(5) only
NAME4G:       lc      0
              st=c                  ; initialize PTEMP2
              pt=     0
              g=c                   ;  & save in G
              golong  PARS75

; *
; * DSPLN_ - display (line#+1)
; * On entry, line number must be valid in REG 15, and chip 0 must
; *     be enabled.
; * 1. Gets line number from REG 15
; * 2. clears LCD
; * If S4 is clear, then returns immediately
; * 3. Increments line number (but doesn't store back to REG 15)
; * 4. If private, replaces line number with 0
; * 5. Calls GENNUM to put line number to LCD
; * 6. Shifts on a blank following the line number
; * On exit, the display chip is enabled and the PT=0
; * Uses A, B.X, B.S, C, & one subroutine level
; *
DSPLN_:       c=regn  15            ; get line number
              bcex    x
              gosub   CLLCDE
              ?s4=1
              rtn nc
              abex    x             ; bring line # to A.X
              a=a+1   x             ; increment it
              ?s12=1                ; private?
              gonc    DSPL10        ; no
              a=0     x             ; yes - zero out line#
DSPL10:       a=0     s             ; set up for GENNUM
              gosub   GENNUM
              ldi     32
              slsabc                ; shift in a blank
              rtn
; *
; * GOLONG - long branch routine for plug-in ROMs
; * Same as GOSUB except uses 1 subroutine level temporarily.
; *
; * GOSUB - subroutine routine for port addressed plug-in ROMs
; * This subroutine allows subroutine calls in port addressed
; * plug-in ROMs.
; * The calling sequence is:
; *       GOSUB   GOSUB    must be in hex mode on entry!!
; *       DEF     <NAME>
; * Where name is in the same 1024-word ROM as the calling routine.
; *
; * WARNING!!! - Calling a subroutine in another 1024-word ROM from
; * the current one will not work. use GOSUB[0-3].
; *
; * Uses only C, no additional subroutine levels
; *
; * GOLNGH - same as GOLONG except sets hex mode on entry.
; * GOSUBH - same as GOSUB  except sets hex mode on entry.
; *
              .public GOLNGH
              .public GOLONG
              .public GOSUBH
              .public GOSUB
GOLNGH:       sethex
GOLONG:       c=stk                 ; get address of calling routine
              cxisa                 ; get the destination address
              goto    GOSUBA        ; go create the correct 16-bit address

GOSUBH:       sethex
GOSUB:        c=stk                 ; get address of calling routine
              cxisa                 ; get the destination address
              c=c+1   m             ; advance address beyond argument for return.
              stk=c                 ; put return address back
GOSUBA:       c=c+c                 ; move over both addresses two bits
              c=c+c                 ; so that the desired 10-bit boundary
              csr     m             ; falls on a digit boundary C[3:2]
              csr     m             ; combine 10 bits from argument
              csr     m             ; with 6 bits from subroutine stack
              c=c+c                 ; to form a 16-bit address
              c=c+c                 ; and position properly for GOTOC
              rcr     12
              gotoc                 ; go to the desired address.

              .public GT3DBT
GT3DBT:       gsblng  GETPC         ; status_3rd byte
              m=c                   ; -
              gsblng  INCAD2        ; -
              gsblng  GTBYTA        ; -
              cstex                 ; -
              rtn

              .public XSIGN
; ******************************************************
; * The sign function returns one for positive
; * numbers and -1 for negative numbers and zero
; * for alpha data
; ******************************************************

XSIGN:        pt=     12
              c=regn  3
              c=0     wpt
              a=c
              a=a-1   s
              a=a-1   s
              goc     DONSGN        ; makes use of OVFL10
                                    ; at NFRX to zero out
                                    ; whole word because
                                    ; mantissa is zero
              lc      1
DONSGN:       golong  NFRX

; *
; * Must have at least 2 words at the end of CN3 for checksum and
; * trailer

              .fillto 0x3fe
REVLEV:       .con    14            ; REV level= N
CKSUM0:       .con    0000
