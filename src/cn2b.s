;;; This is HP41 mainframe resurrected from list file output. QUAD 2
;;;
;;; REV.  6/81A
;;; Original file CN2B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @4000-5777

              .section QUAD2

              .public BAKAPH
              .public BAKDE
              .public BLINK
              .public BLINK1
              .public BSTCAT
              .public CAT1
              .public CAT2
              .public CNTLOP
              .public DEEXP
              .public DEROVF
              .public DERUN
              .public DIGENT
              .public DIGST_
              .public DSPCA
              .public DSPCRG
              .public FIX57
              .public FORMAT
              .public GTCNTR
              .public GTRMAD
              .public INPTDG
              .public LDD_P_
              .public NFRST_PLUS
              .public NOREG9
              .public NOTFIX
              .public RFDS55
              .public RG9LCD
              .public ROUND
              .public RSTST
              .public R_SCAT
              .public SETQ_P
              .public SSTCAT
              .public XCAT

; *
; * GTRMAD - get XEQ ROM function entry addr
; *
; * Calling sequence :
; *  C[2:0] = Lower 1 & half bytes of the XEQ ROM function code
; *  GOSUB GTRMAD
; *  <return here if ROM not plugged in or FC # too big>
; *  <return here if ROM plugged in and FC # in limit>
; *  when return REG.B always has:
; *      B[2:0] = function number
; *      B[4:3] = ROM ID number
; *  If the function found in the ROM then
; *      A.[3:0] = auxiliary ROM function execution address
; *      S2  = Bit 8 of the upper word in function table
; *      S3  = Bit 9 of the upper word in function table
; *      USES A,C,B[6:0], status set, and active pointer
; *
GTRMAD:       c=0     m
              c=c+c   w
              c=c+c   w             ; ROM ID in C[3:2] now
              rcr     13            ; C[4:3] _ ROM ID
              csr     x
              c=c+c   x
              c=c+c   x
              csr     x             ; C.X _ FC #
              rcr     3             ; C.X _ ROM ID
              a=c     x             ; A.X _ ROM ID
              rcr     11
              pt=     6
              bcex    wpt           ; B[4:0] _ ROM ID & FC #
              c=0     m
              lc      5             ; start from hex 5000 (ASL 1)
              pt=     6
RMAD10:       cxisa                 ; read ID from one port
              ?a#c    x             ; is the ID a match ?
              gonc    RMAD20        ; yes
RMAD15:       c=c+1   pt            ; addr _ addr + hex 1000
              gonc    RMAD10        ; check another port
#if defined(HP41CX)
; * Extend search to page 3 for HP-41CX. Note that this pushes the RMAD20
; * label down one position, but we regain sync by removing the bug fix
; * nop a few lines down.
              golong  RMAD_PAGE3    ; search page 3 FAT
#else
              rtn                   ; ROM not plugged in
#endif
RMAD20:       c=c+1   m             ; point to 2nd word of ROM
              abex    x             ; A.X = FC #, preserve ID in B.X
              cxisa                 ; load # of FC's in the ROM
#if ! defined(HP41CX)
              nop                   ;  (deleted bug) 12/8/91 WCW
#endif
              ?a<c    x             ; is the FC in the ROM ?
              gonc    RMAD30        ; no, FC # too big
              b=a     x             ; restore B.X = FC #
; * Entry point added for HP-41CX
              .public RMAD25
RMAD25:       acex                  ; C.X _ FC #, A.M ROM pointer
              c=c+c   x             ; multiply FC # by 2
              a=a+1   m             ; point to beginning of FC table
              c=0     m
              rcr     11
              c=a+c   m             ; C.M _ function table entry
              cxisa
              c=c+c   xs
              c=c+c   xs
              rcr     2
              st=c                  ; set top 2 bits to S3,S2
              rcr     10
              a=c                   ; A[3:2] _ upper byte of XADR
              rcr     2
              c=c+1   m             ; point to lower byte of XADR
              cxisa                 ; GET LOWER BYTE
              pt=     1
              a=c     wpt           ; A[3:0] _ XADR
              rcr     3
              a=a+c   m             ; compute chip address
              golong  RETP2         ; return to P+2

RMAD30:       c=c-1   m
              abex    x             ; A.X = ID, B.X = FC #
              goto    RMAD15
; *
; *
; *
; * Digit entry
; *       Digit entry use REG.9 & status set in REG.10
; *   to remember all the keys entered.
; *   Format of REG.9 :
; *
; *   Digit 13  : D.P. position, which is the # of digits
; *               between D.P. and digit 3. its initial
; *               value is 10.
; *   Digit 12-3: mantissa digits, initial value are F's
; *   Digit 2   : exp. sign. =0 if exp positive
; *                          =D if exp negative
; *   Digit 1-0 : exp. digits, initial value are F's
; *
; *   Status information :
; *          S0 = 1 if D.P. hit, otherwise = 0
; *          S1 = 1 if EEX hit, otherwise = 0
; *          S2 = 1 if mantissa negative, otherwise = 0
; *          S3 = 1 if mantissa nonzero
; * If S9=1 means this call is from DERUN (digent in run time),
; * then CHS shall not check if mantissa zero.
; *
              .public DGENS8
DGENS8:       s8=     0             ; say no CHS when X=0
DIGENT:       c=regn  8
              rcr     11
              st=c                  ; restore DIGENT status set
              pt=     12
              c=g                   ; put the digit to C[13]
              ?c#0    s             ; is this a back arrow ?
              golnc   BAKDE         ; yes
              rcr     13
              lc      12            ; load CHS
              lc      11            ; load EEX
              lc      10            ; load D.P.
              a=c     w             ; copy C to A
              asl     w             ; get ready for comparison
              ?a#c    s             ; is it a CHS ?
              gonc    DECHS         ; yes
              asl
              ?s1=1                 ; EEX hit ?
              golc    DEEXP         ; yes
              ?a#c    s             ; is it an EEX ?
              gonc    DEEEX         ; yes
              asl
              ?a#c    s             ; is it a D.P. ?
              gonc    DEDP          ; yes
              ?c#0    s             ; is it a nonzero digit ?
              gonc    DE200         ; no
              s3=     1             ; remember mantissa nonzero
DE200:        pt=     3             ; find a place in mantissa
              c=regn  9
DE210:        c=c+1   pt
              gonc    DE220         ; found the last digit
              inc pt                ; point to the left next digit
              legal
              goto    DE210
DE220:        ?pt=    3             ; mantissa full ?
              golc    BLINK1        ; yes, ignore this entry
              ?s0=1                 ; D.P. hit ?
              goc     INDGJ         ; yes, put it to mantissa
              c=regn  9             ; move the potential D.P.
              c=c-1   s             ;  to right one digit
              regn=c  9
INDGJ:        golong  INPTDG
DEDP:         ?s0=1                 ; D.P. hit already ?
              goc     BLINK1        ; yes, ignore this D.P.
              s0=     1             ; say D.P. hit
              goto    RSTSTJ        ; put the status back
DEEEX:        c=regn  9             ; see if we allow EEX now
              a=c
              pt=     13
              lc      2
              ?a<c    s             ; have we gone too far ?
              goc     BLINK1        ; yes, not accept EEX now
              s1=     1             ; say EEX hit
              ?s3=1                 ; mantissa zero ?
              goc     RSTST         ; no
              c=0                   ; set mantissa to 1
              c=c-1
              c=0     xs
              pt=     13
              lc      9             ; D.P. position = 9
              lc      1             ; mantissa _ 1
              s3=     1             ; remember mantissa nonzero
              goto    RSTOR9
DECHS:        ?s1=1                 ; EEX hit ?
              goc     CHSEXP        ; yes, CHS of EXP.
              ?s8=1                 ; check X=0 ?
              goc     DECHS1        ; no
              ?s3=1                 ; mantissa nonzero
              gonc    BLINK1        ; yes, ignore CHS
DECHS1:       ?s2=1                 ; CHS hit ?
              goc     .+3           ; yes
              s2=     1
RSTSTJ:       goto    RSTST         ; put status back
              s2=     0
              goto    RSTST         ; put status back
CHSEXP:       c=regn  9
              a=c     w
              c=0     xs            ; assume exp was negative
              pt=     2
              ?a#0    xs            ; was exp negative ?
              goc     RSTO9J        ; yes
              lc      13            ; load a "D" to REG.9[2]
RSTO9J:       goto    RSTOR9        ; restore REG.9
DEEXP:        ?a#c    s             ; is it an EEX ?
              gonc    BLINK1        ; yes, ignore it
              asl
              ?a#c    s             ; is it a D.P. ?
              gonc    BLINK1        ; yes, ignore it
              pt=     0             ; find a place in exp
              c=regn  9
EXPDG1:       c=c+1   pt
              gonc    EXPDG2        ; found the last exp digit
              inc pt
              legal
              goto    EXPDG1
EXPDG2:       ?pt=    0             ; exp full ?
              gonc    INPTDG        ; not yet

BLINK1:
BLINK:                              ; disoff ignore a key, turn display on
              disoff
              ldi     208
              .newt_timing_start
1$:           c=c-1   x
              gonc    1$
              .newt_timing_end
              distog
              rtn
INPTDG:       dec pt                ; insert a digit to REG.9
              nop
              c=g
              a=c     pt
              c=regn  9
              acex    pt
RSTOR9:       regn=c  9
RSTST:        c=regn  8
              rcr     11
              c=st                  ; put the status bits back
              rcr     3
              regn=c  8
              rtn
; *
; * DERUN - entry point of digit entry in run time
; *  Come in from mainloop with the 1st digit in A[3:2], PC points
; *  to 1st byte of digit entry in mem.
; *
DERUN:        pt=     2
              acex
              g=c                   ; save the digit in G
              s8=     1             ; remember in run time
                                    ; tell digent calling from derun
              goto    DIGST1
; *
; * DIGST_ - digit entry initialization
; * Set up REG.9 (refer the format to DIGENT)
; * Reset DIGENT status (CHS, D.P., EEX) and save it in REG.10[1:0]
; * Push the stack if pushflag set
; * If not in program, clear X
; * Called by dataentry with digit code in G
; * Assumes chip 0 enabled
; * Not a subroutine, return to various places
; *
DIGST_:       s8=     0             ; remember not in run time
DIGST1:       c=0     w             ; initialize REG.9
              c=c-1   w
              c=0     xs            ; exp positive
              pt=     13
              lc      10            ; initial D.P. position
              regn=c  9
              gosub   STBT10        ; move status bits to REG.10
              c=regn  14
              st=c                  ; load set #0
              ?s3=1                 ; progmode ?
              gonc    DIGST2        ; no
              gosub   INSSUB        ; increment line# by 1
              golong  DAT320        ; return to dataentry
DIGST2:       ?s11=1                ; push flag set ?
              gsubc   R_SUB         ; yes, push stack
              s11=    1
              c=0
              regn=c  3             ; clear X
              ?s8=1                 ; running ?
              golnc   DAT231        ; no, return to dataentry
                                    ; drop thru to DERUN
; *
; * DIGIT ENTRY DURING RUN TIME
; *
              gosub   GETPC
              b=a     wpt
DERUN5:       gosub   ENCP00
              gosub   DIGENT
              gosub   NOREG9        ; normalize digit entry
              gosub   NBYTAB
              abex    wpt           ; save PC in B
              pt=     1
              a=c     wpt           ; A[2:0] _ next FC
              ldi     0x1d
              ?a#c    pt            ; is a row 1 FC ?
              goc     DERNRT        ; no, exit
              ?a<c    wpt           ; is a digit FC ?
              gonc    DERNRT        ; no, exit
              acex
              pt=     0
              g=c                   ; put the digit to G
              goto    DERUN5
; * END OF DIGIT ENTRY UPDATE PC
; *
DERNRT:       abex
              gosub   DECAD         ; point to last byte of digit entry
DERRT1:       gosub   PUTPC
              golong  NFRPU

; *
; * OVERFLOW- overflow detected by digit entry routine
; *
DEROVF:       abex
              sethex
              pt=     3
              goto    DERRT1
; *
; * Construct digit entry display from REG.9
; * (please refer the REG.9 format in DIGENT)
; * Called by dataentry. DIGENT routine itself won't refresh
; * the display, it only updates the REG.9. so, during digit
; * entry, dataentry has to call this routine for each digit
; * to refresh display.
; * Status bits meaning:
; * S0 - D.P. hit                S1 - EEX hit
; * S2 - CHS hit                 S4 - digit grouping flag
; * S5 - decimal point flag
; *
; * RG9LCD builds regs A & C and sets up P and Q for a subsequent
; * call to RFDS55. RFDS55 is the one that actually sends stuff to
; * the LCD.
; *
RG9LCD:       c=regn  8             ; load flags - S2:CHS
              rcr     11
              st=c                  ; S1:EEX   S0:D.P.
              c=regn  9
              a=c     w             ; A _ REG.9
              gosub   ENLCD         ; enable LCD chip
              gosub   LOAD3         ; load all 3's into C
              pt=     3             ; start from end of mantissa
RFDS10:       a=a+1   PT            ; find the last digit ?
              gonc    RFDS15        ; yes
              c=c-1   pt            ; C[PT] _ 2
              a=a-1   s             ; decrement D.P. pos counter
              inc pt                ; point to left next digit
              legal
              goto    RFDS10
RFDS15:       a=a-1   pt            ; restore the digit
              ?s1=1                 ; EEX hit ?
              goc     RFDS17        ; yes, don't prompt mantissa
              ?pt=    3             ; mantissa full ?
              goc     RFDS17        ; yes, don't prompt
              dec pt                ; point to prompt position
              a=a-1   pt            ; A[PT] _ 1
              lc      1             ;  under score = "1F"
              inc pt
              inc pt                ; restore the pointer
RFDS17:       ?s0=1                 ; D.P. hit ?
              gonc    RFDS25        ; no, don't look for D.P.
RFDS19:       a=a-1   s             ; look for D.P.
              goc     RFDS20        ; found it!
              inc pt                ; point to left next digit
              legal
              goto    RFDS19
RFDS20:       ?s5=1                 ; load the D.P. to C
              gonc    1$            ; load a comma instead of
              lc      7
              goto    2$
1$:           lc      15
2$:           inc pt                ; restore the pointer
RFDS25:       ?s4=1                 ; grouping flag set ?
              gonc    RFDS35        ; no
              ?pt=    13
              goc     RFDS30
RFDS26:       a=c     s             ; A[13] _ 3
RFDS27:       a=a-1   s             ; count 3 from left
              goc     RFDS28        ; shall we put a comma here ?
              ?pt=    12            ; reach left end of mantissa ?
              goc     RFDS35        ; yes, we are done
              inc pt                ; point to left next digit
              legal
              goto    RFDS27
RFDS28:       ?s5=1                 ; load a comma to C
              gonc    1$
              lc      15
              goto    2$
1$:           lc      7             ; load a D.P. instead of
2$:           inc pt                ; restore pointer
              legal
              goto    RFDS26
RFDS30:       acex    s
              goto    .+2
RFDS35:       a=c     s             ; take care of the sign
              a=a-1   s             ; A[13] _ 2
              c=0     s             ; assume positive mantissa
              pt=     13
              ?s2=1                 ; CHS hit ?
              gonc    1$            ; no, mantissa positive
              lc      13            ; "-" = 2D
1$:           acex    s
              sel q
              pt=     13            ; Q= 13
              sel p
              c=c-1   xs            ; C[2] _ 2
              ?s1=1                 ; EEX hit ?
              gonc    RFDS50        ; no, let's goto display
              pt=     1             ; look at digit 1
              a=a+1   pt            ; is there a digit there ?
              goc     RFDS40        ; no, let's prompt at digit 1
              a=a-1   pt            ; restore digit 1
              pt=     0             ; look at digit 0
              a=a+1   pt            ; is there a digit ?
              goc     RFDS42        ; no, let's prompt at digit 0
              a=a-1   pt            ; restore digit 0
              c=c+1   pt            ; C[0] _ 3
              legal
              goto    RFDS45        ; we are ready for LCD
RFDS40:       a=0     wpt
RFDS42:       a=a-1   pt
              lc      1
RFDS45:       pt=     3             ; say display exp
              rtn
RFDS50:       a=0     xs
              pt=     0             ; say only display mantissa
              rtn
RFDS55:       csr     pq            ; display only 12 digits
              csr     pq
              srldb                 ; shift into display REG.B
              acex    w
              csr     pq
              csr     pq
              srlda                 ; shift into display REG.A
              c=0     w
              srldc                 ; clear display REG.C
              .public ENCP00
ENCP00:       c=0     x             ; enable chip 0 & return
              pfad=c                ; disable peripherals
              dadd=c                ; enable chip 0
              rtn
; *
; * PGMAON - turn on program annunciator
; * No entry requirements
; * Leaves chip 0 enabled on exit
; * Uses C and one subroutine level
; *
              .public PGMAON
PGMAON:       gosub   ENLCD
              readen
              cstex
              s1=     1             ; turn on prgm annunciator
              cstex
              wrten
              goto    ENCP00
; *
; *
; * NOREG9 - normalize the digit entry string in REG.9 and store
; *          it to X-reg
; * (please refer the information to digit entry)
; * Assumes chip 0 enabled. uses A,C. 1 sub level.
; * Returns in hex mode, chip 0 enabled.
; * Status bits meaning :
; * S1 - EEX hit          S2 - CHS hit
; * S9 - Running or SST
; *
NOREG9:       c=regn  9
              pt=     3             ; look for last digit
NORG05:       c=c+1   pt
              gonc    NORG10
              inc pt                ; point to left next digit
              legal
              goto    NORG05
NORG10:       c=c-1   pt            ; restore the digit
              a=c     x             ; normalize exp
              c=0     xs
              pt=     0
NORG20:       a=a+1   pt            ; shift blank out of exp
              gonc    NORG30
              csr     x
              inc pt
              ?pt=    2
              gonc    NORG20
NORG30:       setdec
              ?a#0    xs            ; exp sign negative ?
              gonc    1$            ; no
              c=-c    x             ; complement exp
1$:           a=c     w             ; copy C to A
              pt=     13
              lc      9
              acex    s             ; C[13]=# of digits after D.P.
              a=a-c   s             ; A[13]=# of digits before D.P.
              goc     NORG50
NORG40:       ?a#0    pt            ; leading zero ?
              goc     NORG51        ; no
              asl     m             ; shift out leading zero
              a=a-1   s             ; pass D.P. ?
              gonc    NORG40        ; not yet
NORG42:       a=a-1   x             ; zero followed by D.P.
NORG45:       ?a#0    pt            ; leading zero past D.P. ?
              goc     NORG55        ; no
              c=c-1   s             ; end of mantissa ?
              goc     NORG65        ; yes, exit
              a=a-1   x             ; exp _ exp_-1
              asl     m             ; shift out leading zero
              goto    NORG45
NORG50:       a=0     s
              goto    NORG42
NORG51:       a=a-1   s             ; past D.P. ?
              goc     NORG55        ; yes
              a=a+1   x
              gonc    NORG51        ; usually no carry here
              goto    NORG51        ; catches carries
NORG55:       a=0     s             ; assume mantissa positive
              ?s2=1                 ; CHS hit ?
              gonc    1$            ; no
              a=a-1   s
1$:           acex    w
              ?s1=1                 ; EEX hit ?
              gonc    NORG70        ; no, don't check overflow
              gosub   OVFL10
              regn=c  3
              ?pt=    12            ; overflow?
              goc     NORG75        ; no
              ?s8=1                 ; running ?
              golc    DEROVF        ; yes
              gosub   PRT13
              gosub   DATOFF
              golong  NFRKB
NORG65:       c=0     w
NORG70:       regn=c  3
NORG75:       sethex
              rtn


; *
; * BAKDE - back space during data entry
; * BAKDE like DIGENT only updates the digit entry string in REG.9.
; * Assumes chip 0 enabled. Uses A,C. Returns with chip 0 enabled.
; *
BAKDE:        c=regn  9
              sel q
              pt=     12
              sel p
              a=c     s             ; A[13] _ D.P. position
              ?s1=1                 ; EEX hit ?
              gonc    BKMANT        ; no, look at mantissa
BKEXP:        pt=     0             ; last digit in exp
              goto    BKDE10        ; look for last digit in exp
BKMANT:       pt=     3             ; last digit in mantissa
BKDE10:       c=c+1   pt
              gonc    BKDE20        ; found the last digit !
              c=c-1   pt            ; C[PT] _ F
              a=a-1   s
              inc pt                ; point to left next digit
              legal
              goto    BKDE10
BKDE20:       ?s1=1                 ; EEX hit ?
              gonc    BKMN20        ; no
BKEX10:       ?pt=    2             ; over exp ?
              goc     BKEX20        ; yes, exp out
BKDG:         c=0     pt            ; take the digit out
              ?c#0    pq            ; mantissa zero ?
              goc     BKDG1         ; no
              s2=     0             ; mant. can't be negative zero
              s3=     0             ; remember mantissa zero
BKDG1:        lc      15
              goto    RSTRG9        ; restore REG.9
BKEX20:       c=c-1   xs
              c=c-1   xs            ; was exp negative ?
              gonc    BKEX30        ; yes
              s1=     0             ; say EEX not hit
BKEX30:       c=0     xs
              goto    RSTRG9        ; restore REG.9
BKMN20:       ?pt=    13            ; past last digit ?
              goc     BKMN30        ; yes, digent off
              ?s0=1                 ; D.P. hit ?
              goc     BKMN25        ; yes
              ?pt=    12            ; last digit in mantissa ?
              goc     BKMN30        ; yes, digent out
              c=c+1   s             ; D.P. pos _ D.P. pos-1
              legal
              goto    BKDG          ; back out one digit
BKMN25:       a=a-1   s             ; is this a D.P. ?
              gonc    BKDG          ; no. back out one digit
              s0=     0
              goto    RSTSS
BKMN30:       c=regn  14
              st=c                  ; load set #0
              ?s3=1                 ; progmode ?
              gonc    BKDE30        ; no
              gosub   DATOFF
              golong  ERR120
BKDE30:       c=0     w
              regn=c  3             ; clear X
              spopnd
              ldi     0x77          ; load the "CLX" FC
              rtn                   ; go back to PARSE
RSTRG9:       regn=c  9             ; restore register 9
RSTSS:        golong  RSTST         ; put status back to REG.10

; *
; * BAKAPH - back space during alpha entry (only in normal mode)
; * Assumes chip 0 enabled.
; * Uses A,C. H[13] & B[13] used as LCD counter.
; *
BAKAPH:       s9=     0             ; keyboard has not been reset
              c=regn  5
              pt=     1
              ?c#0    wpt           ; is any char in alpha reg. ?
              golnc   DAT106        ; no. do a CLA
              a=c     w             ; shift the last char out
              c=regn  6
              acex    wpt
              acex    w
              rcr     2
              regn=c  5
              c=regn  7
              acex    wpt
              acex    w
              rcr     2
              regn=c  6
              c=regn  8
              acex    wpt
              acex    w
              rcr     2
              regn=c  7
              c=regn  8
              rcr     6
              c=0     wpt
              rcr     10
              regn=c  8
              c=regn  9
              ?c#0    S             ; LCD full ?
              gonc    BKPH50        ; yes, do argout again
              gosub   ROLBAK
              frsabc                ; read last char from LCD
              cstex                 ; test for punc. char
              ?s6=1
              goc     BKPH20
              ?s7=1
              goc     BKPH20
              cstex
BKPH10:       c=b     s
              c=c+1   s
              bcex    s
PROMPT_:      gosub   OPROMT        ; output prompt char
              goto    NFRKB0
BKPH20:       s6=     0
              s7=     0
              cstex
              a=c     x
              ldi     0x20          ; load a blank
              ?a#c    x             ; is last char a blank ?
              goc     BKPH30        ; no
              c=0     x
              pfad=c
              dadd=c
              c=regn  8             ; load last char from AREG.
              c=0     xs
              ?a#c    x             ; is it a blank?
              goc     BKPH40        ; no
              gosub   ENLCD
BKPH30:       acex    x
              slsabc                ; put the last char back
              goto    PROMPT_
BKPH40:       gosub   ENLCD
              goto    BKPH10
BKPH50:       s8=     1             ; no scroll, prompt
              gosub   ARGOUT
              c=b
              gosub   STOLCC
NFRKB0:       golong  NFRKB1

              .public XRND
; *
; * RND function
; *
XRND:         c=regn  14            ; load display format
              rcr     2
              st=c                  ; load status set 1
              a=c     x
              c=regn  3             ; load the X
              s8=     0
; *
; *
; * Rounding routine
; *   calling sequence
; *           C    = normalized number
; *           A[2] = DSP #
; *           S8   = 1 if called from "FORMAT"
; *                  0 if called from "XRND"
; *           GOSUB ROUND
; *   Returns with rounded number in REG.C
; *   USES A,B,C
; *
ROUND:        setdec
              b=a     xs
ROUNDA:       pt=     12            ; move pointer TO 12-(DSP# + 1)
RND20:        ?pt=    2             ; end of mantissa ?
              goc     RND90         ; yes, no rounding
              dec pt
              a=a-1   xs            ; stop ?
              gonc    RND20         ; no, keep going
              a=c     w             ; copy the number to A
              ?c#0    xs            ; exp positive ?
              gonc    RND30         ; yes
              ?s7=1                 ; FIX mode ?
              gonc    RND60         ; no, let's round it up
RND40:        inc pt
              ?pt=    12            ; past left end of mantissa?
              goc     RND100        ; yes, FIX mode infeasible
              a=a+1   x             ; keep moving to rounding point
              gonc    RND40
              goto    RND60         ; let's round it now
RND70:        dec pt                ; exp positive
RND75:        ?pt=    2             ; past end of mantissa ?
              goc     RND120        ; yes, FIX mode infeasible
              a=a-1   x
              gonc    RND70
RND60:        b=0     w             ; here is the rounding
              b=a     wpt
              a=a+b   m
              gonc    RND50         ; rounding ok !
RND45:        a=c     w             ; save the # in case of overflow
              a=0     wpt
              a=c     x
              pt=     1             ; test for overflow number
              c=c+1   wpt
              goc     RND95         ; overflow
RND47:        a=0     w
              a=a+1   s
              asr     w             ; set mantissa to 1
              pt=     11
RND50:        a=0     wpt
              acex    m             ; C_rounded number
RND90:        sethex
              rtn
RND95:        acex    w             ; no rounding for overflow #
              ?a#0    xs            ; exp negative ?
              gonc    RND90         ; no
              c=0     x             ; it's not really an overflow
              goto    RND47
RND30:        ?s7=1                 ; FIX mode ?
              gonc    RND60         ; no, let's round it up
              goto    RND75
RND100:       a=a+1   x
              gonc    RND105
              b=a     m
              a=a+b   m
              goc     RND45
RND105:       ?s8=1                 ; called from "FORMAT" ?
              goc     RND110        ; yes
              c=0     w             ; return zero
              goto    RND90
RND110:       s7=     0             ; display the # in SCI mode
              abex    xs
              goto    ROUNDA        ; round it again
RND120:       ?s8=1                 ; called from "FORMAT" ?
              gonc    RND90         ; no, no rounding then
              a=0     x             ; is FIX mode feasible ?
              pt=     0
              a=a-1   pt            ; A[1] _ 9
              ?a<c    x             ; exp < 9 ?
              goc     RND110        ; no, FIX mode infeasible
              goto    RND90         ; FIX mode, no rounding
; *
; *
; * FORMAT routine - format a normalized number
; * Calling sequence :
; *         C= normalized number
; *         GOSUB FORMAT
; * Returns < A : ready for display REG.A >
; *         < B : ready for display REG.B >
; * USES A,B,C. assumes chip 0 enabled
; * USES status bits 0-8
; * S4 = digit grouping flag
; * S5 = decimal point flag
; * S6 = ENG mode flag
; * S7 = FIX mode flag
; * S8 = FIX mode feasible flag
; *
; * Calls STBT10, ROUND, LOAD3, LDD_P_, SETQ_P
; * Probably uses only one additional subroutine level
; *
FORMAT:       bcex    w             ; save the number to B
              sethex
              gosub   STBT10        ; move status bits to REG.10
              c=b     w             ; get the number back
              s8=     1             ; signal rounding routine
              gosub   ROUND         ; round the number
              bcex    w             ; move the number to B temp.
              gosub   LOAD3         ; load all 3's to C
              c=c+1                 ; C[0] _ 3
              a=c     w             ; A _ all 3's
              setdec
              c=regn  14
              rcr     5             ; C[13] _ DSP#
              bcex    w             ; B[13] _ DSP#, C _ rounded no.
              abex    s             ; A[13] _ DSP# , B[13] _ 3
              b=c     x             ; copy exp to B
              ?c#0    s             ; mantssa positive ?
              gonc    1$            ; yes
              pt=     13
              lc      13
1$:           ?s7=1                 ; FIX mode ?
              golnc   NOTFIX        ; no
FIX00:        pt=     12
              ?c#0    xs            ; exp positive ?
              gonc    FIX20         ; yes
              gosub   LDD_P_        ; load decimal point
              gosub   SETQ_P
FIX10:        dec pt
              csr     m             ; shift in leading zero
              a=a-1   s             ; decrement dsp #
              c=c+1   x             ; until exp = 0
              gonc    FIX10
              goto    FIX40         ; put in the tail blanks
FIX20:        c=c-1   x             ; passing D.P. ?
              goc     FIX30         ; yes, goto load D.P.
              dec pt
              legal
              goto    FIX20
FIX30:        c=0     x
              a=a-1   s
              goc     FIX60         ; FIX mode, dsp# = 0
              gosub   LDD_P_        ; load the D.P.
              gosub   SETQ_P        ; set Q=P
FIX35:        dec pt                ; passing the dsp #
              ?pt=    2             ; end of mantissa ?
              goc     FIX50         ; yes
FIX40:        a=a-1   s             ; DSP# _ DSP# -1
              gonc    FIX35
FIX45:        dec pt
              ?pt=    2             ; end of mantissa ?
              goc     FIX50
              a=a-1   pt            ; filling tailing blank
              legal
              goto    FIX45
FIX50:        pt=     0
              sel q
              ?s4=1                 ; grouping flag set ?
              gonc    FIX57         ; no
SETCOM:       a=b     s             ; A.S _ 3(comma counter)
FIX55:        a=a-1   s             ; count 3 and load a comma
              goc     LDCOMA
              inc pt                ; move the pointer to left
              ?pt=    13
              gonc    FIX55
FIX57:        pt=     13            ; Q _ 13
              sel p
              abex    s             ; A[13] _ 3
              goto    FMTRTN
LDCOMA:       acex    pt
              ?s5=1                 ; load a comma
              gonc    1$
              lc      15
              goto    2$
1$:           lc      7             ; load a D.P. instead of
2$:           inc pt
              acex    pt
              goto    SETCOM
FIX60:        gosub   SETQ_P
              ?s4=1
              gsubc   LDD_P_
              goto    FIX45
FMTRTN:       a=a-1   s             ; A[13] _ 2
              a=a-1   xs            ; A[2] _ 2
              acex    w
              sethex
              bcex
              golong  LDSST0
NOTFIX:       pt=     12
              ?s6=1                 ; ENG mode ?
              gonc    SCI00         ; no, SCI mode
              a=c     x             ; A.X _ exp
              ldi     3
              ?a#0    xs            ; exp negative ?
              goc     ENG10         ; yes
1$:           a=a-c   x             ; compute exp mod 3
              gonc    1$
              a=a+c   x
              goc     ENG60
ENG10:        a=a+c   x             ; add 3 to negative D<P
              gonc    ENG10
ENG20:        c=b     x             ; copy exp back to C.X
              c=-c    x             ; complement negative exp
              c=c+a   x
ENG25:        a=a-1   x             ; move the D.P. to right
              goc     ENG30
              dec pt
              a=a-1   s             ; decrement the dsp #
              gonc    ENG25
              a=0     s             ; dsp# _ 0
              goto    ENG25
ENG30:        gosub   LDD_P_
ENG35:        dec pt                ; passing dsp #
              ?pt=    2
              goc     ENG45
              a=a-1   s
              gonc    ENG35
ENG40:        a=a-1   pt            ; A[PT] _ 2, fill tailing blank
              dec pt
              ?pt=    2             ; end of mantissa ?
              gonc    ENG40
ENG45:        ?b#0    xs            ; exp negative ?
              gonc    ENG50         ; no
              pt=     2
              lc      13            ; load the minus sign
ENG50:        pt=     3
              acex    x
              ldi     0x333
              acex    x
              sel q
              golong  FIX57
ENG60:        c=b     x             ; C.X _ exp
              acex    x
              a=a-c   x
              acex    x
              goto    ENG25
SCI00:        a=0     x
              ?c#0    xs            ; exp positive ?
              goc     ENG20         ; no
              goto    ENG30
SETQ_P:       sel q
              pt=     13
SETQ10:       ?p=q
              goc     SETQ20
              dec pt
              legal
              goto    SETQ10
SETQ20:       sel p
              rtn
LDD_P_:       acex    pt
              .public LDDP10        ; for printer ROM
LDDP10:       ?s5=1
              gonc    1$
              lc      7
              goto    2$
1$:           lc      15            ; load a comma instead of
2$:           inc pt
              acex    pt
              rtn
; *
; * DSPCRG - output REG.C to LCD
; * If C[13] = 0 or 9 it means a normalized number
; * If C[13] = 1 it means an alpha string
; * Assumes chip 0 enabled.
; * USES A,B,C,N, status bits 0-8. Returns chip 0 enabled.
; * 2 sub levels.
; *
DSPCRG:       sel p
              a=0     s
              a=a+1   s             ; A.S _ 1
              ?a#c    s             ; is it a string ?
              gonc    VIEW05        ; yes
              gosub   FORMAT
              gosub   ENLCD
              bcex    w
              golong  RFDS55
VIEW05:       pt=     13
              lc      12
              bcex    s
DSPCA:        disoff
              pt=     13
              lc      15
              lc      15
              rcr     12            ; C[1:0] _ FF:deliminator
              n=c                   ; save the REG. in N
              gosub   ENLCD
VIEW20:       c=n
              rcr     12            ; C[1:0] _ outgoing character
              n=c
              a=c     x
              pt=     1
              ?a#0    wpt           ; leading zero ?
              gonc    VIEW20        ; yes, ignore it
              a=a+1   wpt           ; hit deliminator ?
              goc     VIEW30        ; yes
              gosub   ASCLCD        ; send it to LCD
              goto    VIEW20
VIEW30:       ldi     0x20
              c=b     s             ; left-justify
VIEW35:       c=c-1   s
              gonc    VIEW40
              distog
              golong  ENCP00
VIEW40:       slsabc
              goto    VIEW35

; *************************************************************
; * This is the start of the catalog routine.
; * Catalog 2 displays plug-in rom functions.
; *************************************************************
CAT2:
#if defined(HP41CX)
; * Jump to page 3 to preserve CAT2 entry point
              golong  CAT2_
              nop
; * Entry point valid for HP-41CX
              .public CAT2CX_10
CAT2CX_10:
              ?s0=1
              gonc    GTCNTR
              golong  BSTCT1
; * Entry point added for HP-41CX
              .public CAT2CX_20
CAT2CX_20:

#else
              c=0
              abex    x
              a=a-1   x             ; get number
              c=c+1   m             ; ADDR= 2nd word of ROM
              pt=     6             ; 2nd word= # functions in ROM
              lc      4
              pt=     6
NXTROM:       c=c+1   pt            ; ADDR= 2nd word of next ROM
              golc    QUTCAT
              cxisa                 ; get 2nd word= # functions
              a=a-c   x
              gonc    NXTROM
#endif
              a=a+c   x             ; a is number in ROM
              a=0     m             ; add A to strt def adrs
              acex
              rcr     11
              c=c+c   m             ; double distance
              c=c+a   m             ; address of def - 1
              c=c+1   m             ; get address of character
              cxisa
              bcex    x
              c=c+1   m
              cxisa
              rcr     2
              c=b     x
              pt=     1             ; build address
              rcr     3
              acex    pt
              rcr     11
              c=c+a   pt
              c=c+c   xs
              c=c+c   xs
#if defined(HP41CX)
              ?b#0    s
              gonc    LB_0B7C
#endif
              c=c+c   xs
              goc     USLNG         ; uslng code
              rcr     9             ; micro done
              golong  END2          ; put out prompt
USLNG:
              rcr     12
              acex
              s2=     1
              gosub   TXTLB1
              golong  END3

#if defined(HP41CX)
LB_0B7C:      c=c+c   xs
              goc     CAT2CX_10
              golong  LB_321D
#endif

; ****************************************************
; * Catalog subroutines and entry logic.
; ****************************************************
XCAT:         acex                  ; get catalog number
              st=c
              gosub   TONSTF
; ** In the next part, the contents of the C REG will be shown.
; ** "C"= catalog #, "E"= digit of entry #, "A"= alpha character.
              a=0
              c=regn  8             ; C= "* *******AAA AAA"
              pt=     5             ; *= don't know or don't care (or both)
              a=c     wpt           ; save alpha in A
              c=st                  ; get catalog #
              rcr     1             ; C= "C ********** ***"
              acex    s             ; save catalog # in A(S)
              acex                  ; C= "C 0000000AAA AAA"
              regn=c  8
GTCNTR:       c=regn  8             ; get cat 1 and entry #, "E"=entry#
              rcr     10            ; C= "0 000AAAAAAC EEE"
NOCHG:        c=c+1   x             ; move to next entry
              s0=     0             ; clear bst flag
BSTCNT:       b=c     x             ; save entry #
              rcr     4             ; C= "C EEE0000AAA AAA"
              regn=c  8
              c=c-1   s             ; check for cat 0
              c=c-1   s             ; check for cat 1
              goc     CAT1
              c=c-1   s             ; check for cat 2
#if defined(HP41CX)
              golc    CAT2CX
              golong  CXCAT
#else
              golc    CAT2
              golong  CAT3
#endif
; ******************************************************
CNTLOP:       ldi     0x100         ; load time-out constant
              .newt_timing_start
KPCNT:        bcex
              chk kb
              gonc    DECCNT
#if defined(HP41CX)
              gosub   CAT_STOP
              ?a#c    x             ; R/S key?
              golnc   CLCTMG        ; clear catalog and message
              b=0     pt
#else
              c=keys
              rcr     3
              c=0     xs
              a=c     x
              pt=     0
              c=c+c   pt            ; check for "ON" key
              golc    OFF
              ldi     135           ; R/S key?
              ?a#c    x
XCCTMG:       golnc   CLCTMG        ; clear catalog and message
#endif
RSTKBD:       rst kb
DECCNT:       bcex
              c=c-1   x
              gonc    KPCNT
              .newt_timing_end
              goto    GTCNTR
              .fillto 0x3b4
SSTCAT:       gosub   SETSST        ; set SST flag
              goto    GTCNTR        ; inc cnt in B
R_SCAT:       gosub   RSTKB         ; clear keyboard
              goto    GTCNTR
BSTCAT:       gosub   SETSST        ; set SST flag
BSTCT1:       s0=     1             ; set BST flag
              c=regn  8
              rcr     10            ; BST counter
              c=c-1   x
              ?c#0    x             ; index#0?
              goc     BSTCNT
              goto    NOCHG
; ******************************************************
; * The routines which get and display the characters
; * for the three types of catalogs are listed below.
; ******************************************************
CAT1:         pt=     3
              s10=    0             ; set RAM flag
              bcex    x             ; chk for first time
              c=c-1   x
              c=c-1   x
              gonc    PC
              gosub   FSTIN
              lc      4
              s0=     0             ; clear BST flag
              pt=     3
              bcex
              gosub   CLRSB2        ; clr stk,L#,save new PC
PC:           gosub   GETPC         ; fetch PC to A[3:0]
              c=regn  13
              lc      6
              pt=     3
              ?s0=1
              goc     OVRINC        ; do BST?
              ?a#c    wpt
              golnc   QUTCAT
              gosub   INCAD2
              gosub   INCAD         ; get by start of link
OVRINC:       gosub   FLINKA
              ?s0=1                 ; BST
              goc     OVRROT        ; leave A[3:0] alone
              rcr     4
              acex    wpt
OVRROT:       gosub   PUTPCD
              gosub   CLLCDE
              s1=     0             ; no scrolling
              gosub   DF060
#if defined(HP41CX)
              golong  CAT_END3
#else
              golong  END3
#endif
; ***********************************************
; * This code finishes register arithmetic.
; ***********************************************
NFRST_PLUS:   gsblng  OVFL10        ; check overflow
              bcex
              ?pt=    10            ; if PT = 10 overflow
              gonc    NOOVF
              c=0     x             ; re-enable chip 0
              dadd=c
              c=regn  14
              rcr     6
              st=c
              ?s7=1                 ; range error ignore?
              golnc   ERRIGN        ; no. go test error ignore flag
NOOVF:        c=n
              dadd=c
              bcex
              data=c
              rtn
