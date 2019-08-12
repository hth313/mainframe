;;; This is HP41 mainframe resurrected from list file output. QUAD 11
;;;
;;; REV.  6/81A
;;; Original file CN11B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @26000-27777
; * CONTENTS:

              .section QUAD11

              .public AOUT15
              .public APHST_
              .public APNDNW
              .public APPEND
              .public ARGOUT
              .public ASCLCD
              .public CLLCDE
              .public CLRLCD
              .public DAT106
              .public DAT231
              .public DAT260
              .public DAT280
              .public DAT300
              .public DAT320
              .public DAT400
              .public DAT500
              .public DATENT
              .public DECMPL
              .public INBCHS
              .public INBYTJ
              .public MASK
              .public NXBYTO
              .public NXTBYT
              .public OPROMT
              .public OUTLCD
              .public ROLBAK
              .public SCROL0
              .public SCROLL
              .public STBT10
              .public STOLCC
              .public TEXT
              .public TXTLB1
              .public TXTLBL
              .public XECROM
              .public XROMNF

; *
; * Special char table
; *
ASCTBL:       .con    0x7f          ; lazy "T"
              .con    0x61          ; small A
              .con    0x62          ; small B
              .con    0x63          ; small C
              .con    0x64          ; small D
              .con    0x65          ; small E
; * LCD 106 overbar ... Helios 0 small diamond
              .con    0             ; LCD 106
              .con    0x60          ; superscript T
; * LCD 108 one-legged hangman ... Helios 6 upper case gamma
              .con    6             ; LCD 108
                                    ; * LCD 109 two-legged hangman ... Helios 4 alpha
              .con    4             ; LCD 109
; * LCD 10A two-legged one-armed hangman ... Helios 5 beta
              .con    5             ; LCD 10A
; * LCD 10B complete hangman ... Helios 1 little x
              .con    1             ; LCD 10B
              .con    0x0c          ; mu
              .con    0x1d          ; not equal sign
              .con    0x7e          ; sigma sign
              .con    0x0d          ; angle sign
; *
; *
; * ARGOUT - output alpha register to display
; * Calling sequence:
; * If S8=1, no scroll, prompt
; * If S8=0, scroll, no prompt
; * If S8=0, then S9 indicates whether the keyboard has been reset
; *          S9=1 : keyboard has already been reset
; *          S9=0 : keyboard has not been reset
; * By set/reset S8,S9 the keyboard will remain alive during scrolling.
; *        GOSUB  ARGOUT
; * Assumes nothing, returns with chip 0 enabled
; * USES A,B,C. calls NXBYTA, ASCLCD. 2 sub levels.
; *
ARGOUT:       c=0
              pfad=c
              pt=     4             ; load first char addr
              lc      6             ;  = 6008 (byte 3, REG. 8)
              ldi     0x8c
              rcr     1
              a=c
AOUT05:       gosub   NXBYTA
              pt=     1
              ?c#0    wpt           ; is a leading blank ?
              goc     AOUT10        ; no
              ldi     5             ; check end of AREG.
              pt=     3
              c=0     pt
              ?a#c    wpt           ; last char in AREG. ?
              goc     AOUT05        ; no
              gosub   CLLCDE        ; clear LCD
              goto    AOUTR0
AOUT10:       rcr     2
              gosub   CLLCDE
              disoff
              goto    AOUT20
AOUT15:       abex    w
              ldi     5
              pt=     3
              c=0     pt
              ?a#c    wpt           ; end of alpha reg. ?
              goc     AOUT18        ; not yet
AOUTR0:       b=a     s             ; B[13] _ LCD counter
              ldi     0x1f
              ?s8=1                 ; prompt ?
              gonc    AOUT16        ; no
              slsabc
              a=a-1   s             ; LCD full ?
              goc     AOUTRT        ; yes
AOUT16:       c=c+1   x             ; @37+1 = @40
AOUT17:       a=a-1   s             ; do we have to left-justify ?
              goc     AOUTRT        ; no
              slsabc
              goto    AOUT17
AOUTRT:       disoff
              distog                ; turn display on again
              c=b     s
              golong  STOLCC        ; save the LCD counter
AOUT18:       ?a#0    s             ; LCD full ?
              goc     AOUT19        ; no
              ?s8=1                 ; scroll needed ?
              gsubnc  SCROLL        ; yes
AOUT19:       gosub   ENCP00
              pt=     3
              gosub   NXBYTA        ; get next char
              rcr     2
AOUT20:       b=a     w
              gosub   ENLCD         ; enable LCD
              rcr     12            ; C[1:0] _ char
              c=0     xs            ; C[2] _ 0
              gosub   ASCLCD        ; send it to LCD
              goto    AOUT15
; *
; * ASCLCD - send an ASCII char to LCD
; * Called with ASCII in C[1:0]
; * Assumes LCD enabled, returns with LCD enabled.
; * USES A.X, B.S, C. 1 sub level.
; *     GOSUB  ASCLCD
; *
COLON:        ldi     0x80
              goto    PUNC
COMMA:        ldi     0xc0
              goto    PUNC
ASCLCD:       a=c     x
; * Entry point added for HP-41CX
              .public ASCLCA
ASCLCA:       a=0     xs
              ldi     0x3a
              ?a#c    x             ; is this a colon ?
              gonc    COLON         ; yes
              ldi     0x2c
              ?a#c    x             ; is this a comma ?
              gonc    COMMA         ; yes
              ldi     0x2e
              ?a#c    x             ; is this a period ?
              goc     MASK          ; no
PERIOD:       ldi     0x40
PUNC:         a=c     x
              frsabc                ; look at previous char
              cstex
              ?s6=1                 ; is there a punc. with it ?
              goc     PUNC10        ; yes
              ?s7=1                 ; is there a punc. with it ?
              goc     PUNC10        ; yes
              cstex
              pt=     13
              lc      12
              a=c     s
              c=b     s
              ?a#c    s             ; is this the first char ?
              gonc    OUTLCD        ; yes
              goto    PUNC20
PUNC10:       cstex
              slsabc                ; put the previous back
              ldi     0x20          ; load a blank
OUTLCD:       ?b#0    s
              gonc    PUNC20
              abex    s
              a=a-1   s
              abex    s
PUNC20:       c=cora
              slsabc
              rtn
; *
; * MASK - convert an ASCII character to LCD character form
; *        (not including comma, period and colon)
; * Called with ASCII in A[2:0]
; * Two calling sequences:
; * 1.     GOSUB MASK
; *        NOP
; *        Calling mask followed by a NOP, the LCD char will return
; *        in C[2:0]. Chip enable unchanged.
; *        USES A.X, C. assumes nothing. 1 sub level.
; * 2.     GOSUB MASK
; *        <ANYTHING BUT NOP>
; *        Calling mask not followed by a NOP will cause the char
; *        being sent to display. Returns with chip 0 enabled.
; *        USES A.X, B.S, C. 1 sub level. Assumes LCD enabled.
; *
MASK:         a=0     xs
              ldi     0x20
              ?a<c    x             ; ASCII < 0x20 ?
              goc     MASK10        ; yes, special char
              ldi     0x60
              ?a<c    x             ; ASCII >= 0x60 ?
              gonc    MASK10        ; yes, special char
              acex    x
              cstex
              s6=     0             ; mask 6 bits only
              cstex
MASKRT:       a=c     x
              c=stk
              cxisa
              stk=c
              acex    x
              ?a#0    x
              rtn nc
              a=0     x
              goto    OUTLCD
MASK10:       c=0                   ; check special char table
              pt=     6
              lc      2             ; table entry at 0000 of QUAD 11
              lc      12
              pt=     3
MASK20:       cxisa                 ; load 1 char from table
              ?a#c    x             ; match a special char ?
              gonc    MASK30        ; yes
              c=c+1   pt            ; point to next word
              gonc    MASK20        ; go on !
              ldi     0x3a          ; all segment if not found
              goto    MASKRT
MASK30:       rcr     3
              c=0     xs
              c=c+1   xs            ; C[2:0] has the special char
              legal
              goto    MASKRT        ; replace it
; *
; *
; * TEXT FUNCTION - execution of TEXT FC in run time
; * Assumes PGM counter pointing to the 1st byte of the TEXT function
; * This routine will pick up the char from mem and move it to the
; * alpha reg. If the 1st char is a lazy "T", the string will be
; * appended to alpha reg. Otherwise, the alpha reg will be cleared
; * before the string goes in.
; * Calls APPEND. Returns to NFRPU. PC will point to last byte of TEXT
; * FC on exit.
; *
TEXT:         a=0     w
              gosub   GETPC         ; get prgm counter
              gosub   GTBYT
              pt=     1
              c=0     pt            ; C[1:0] _ string counter
              c=c-1   wpt
              rtn c                 ; rtn if "F0" F.C.
              rcr     10            ; C[4] _ string counter
              pt=     4             ; move counter to A[4]
              a=c     pt
              gosub   NXTBYT        ; get first char
              b=a     w             ; save the counter in B
              pt=     0
              g=c
              a=c     x
              a=0     xs
              c=0     x
              dadd=c
              ldi     127           ; test first char
              ?a#c    x             ; is it a lazy "T" ?
              gsubc   INTARG        ; no, initialize alpha reg
TEXT30:       c=b     w
              a=c     w
              pt=     3
              rcr     4             ; C.X _ string counter
              c=c-1   x             ; all done ?
              golc    PUTPC
TEXT40:       rcr     10
              a=c     w
              gosub   NXTBYT        ; point to next char
              b=a     w             ; save counter in B
              pt=     0
              g=c
              c=0     x
              dadd=c                ; enable chip 0
              gosub   APNDNW        ; store char to AREG.
              goto    TEXT30
; *
; * SCROLL - turn on the display and decide whether to have a delay
; *          after pushing a char off left end.
; * S8=1 means scroll is not required, no delay
; * S9=1 means keyboard has already been reset.
; *      If any key hit when S9=1, no delay anymore. This way the
; *      keyboard will stay alive during scrolling.
; * Destroys C.X  may set S9
; * May use a subroutine level to call RST05
; *
SCROLL:       disoff
              distog
SCROL0:       ?s8=1                 ; scroll required ?
              rtn c                 ; no
              ?s9=1                 ; has keyboard been reset ?
              goc     SCROL2        ; yes
              .newt_timing_start
              rst kb
              chk kb
              goc     SCROL5        ; old key still down
              s9=     1             ; remember old key is up
              gosub   RST05         ; delay for debounce
SCROL2:       chk kb                ; is a new key down ?
              rtn c                 ; yes, no scroll
SCROL5:       ldi     0x380
              c=c+c   x             ; *** @1600 for final product *****
                                    ;     ***********************
SROL10:       c=c-1   x
              gonc    SROL10
              .newt_timing_end
              rtn
; *
; * Clear LCD
; * CLRLCD - assume LCD enabled
; * CLLCDE - enable LCD & clear it

CLLCDE:       ldi     0x10
              dadd=c                ; disable sleeper chip
              ldi     0xfd
              pfad=c                ; enable LCD chip
CLRLCD:       pt=     11
              c=0     wpt
              pt=     10
              lc      2
              pt=     7
              lc      2
              pt=     4
              lc      2
              pt=     1
              lc      2
              srlabc
              srlabc
              srlabc
              rtn
; *
; * NXTBYT - get next byte in RAM or ROM
; *
              .public NBYTA0
NBYTA0:       gosub   ENCP00
              .public NBYTAB
NBYTAB:       abex
NXTBYT:       pt=     3
              ?s10=1                ; ROM memory ?
              golnc   NXBYTA        ; no
NXBYTO:       a=a+1
              legal
              golong  GTBYTO

; *
; * APPEND - append a char to alpha reg
; * Char in G
; * Assumes chip 0 enabled. Uses A,C. 1 sub level
; * Two entries :
; * 1. APPEND : will give a warning if AREG full and audio enabled
; * 2. APNDNW : no warning even if AREG full
; *
APPEND:       c=regn  8             ; check if AREG. almost full ?
              pt=     1
              rcr     2             ; check second last char
              ?c#0    wpt           ; still empty
              gsubc   TONE7X        ; no, give a warning
APNDNW:       pt=     1
              c=regn  8
              rcr     12
              a=c
              c=regn  7
              rcr     12
              a=c     wpt
              acex    w
              regn=c  8
              c=regn  6
              rcr     12
              a=c     wpt
              acex    w
              regn=c  7
              c=regn  5
              rcr     12
              a=c     wpt
              acex    w
              regn=c  6
              acex    w
              pt=     0
              c=g
              regn=c  5
              rtn
; *
; * DATA ENTRY - when parse detects a DATAENTRY FC, it puts the FC
; *              in C[1:0] and branches to here.
; *
DATENT:       bcex    x
              gosub   OFSHFT        ; reset shift
              bcex    x
              c=0     xs
              a=c     x             ; copy FC to A.X
              pt=     0
              g=c                   ; copy FC to REG.G too
              c=regn  14
              rcr     6
              cstex
              s1=     0             ; reset catalog flag
              cstex
              rcr     8
              regn=c  14
              c=c+c   xs
              c=c+c   xs            ; already in DATAENTRY ?
              goc     DAT200        ; yes
              ?a#0    x             ; back arrow ?
              goc     DAT110        ; no
              ?s5=1                 ; MSGFLAG set ?
              goc     DAT140        ; yes
DAT102:       ?s3=1                 ; program mode ?
              gonc    DAT105        ; no
              ldi     0x0b          ; delete
              rtn                   ; return to PARSE
DAT105:       ?s7=1                 ; alpha mode ?
              goc     DAT106        ; yes
              ldi     0x77          ; CLX
              rtn                   ; return to PARSE
DAT106:       ldi     0x87          ; CLA
              rtn
DAT110:       ldi     0x1c          ; load CHS
              ?a#c    x             ; is it a CHS ?
              goc     DAT120        ; no
              ldi     0x54          ; CHS FC
              rtn                   ; return to PARSE
DAT120:       gosub   STFLGS        ; set MSGFLG & DATAENTRY flag
                                    ; STFLGS leaves SS one-half up
              ?s3=1                 ; alpha mode?
              golnc   DIGST_        ; initialize digit entry
              golong  APHST_        ; initialize alpha entry
DAT140:       s5=     0             ; clear MSGFLAG
              c=regn  14
              c=st
              regn=c  14
              goto    DAT220
DAT200:       s5=     1             ; set MSGFLAG
              c=regn  14
              c=st
              regn=c  14
              ?s3=1                 ; progmode ?
              goc     DAT300        ; yes
              ?s7=1                 ; alpha mode ?
              gonc    DAT235        ; no
DAT230:       ldi     127
              a=c     x
              pt=     0
              c=g                   ; load the FC
              ?c#0    x             ; is this a back arrow ?
              golnc   BAKAPH        ; yes
              ?a#c    x             ; is this a lazy "T" ?
              goc     DAT240        ; no
              gosub   BLINK         ; blink and ignore it
              goto    DAT220
DAT231:       c=regn  14            ; set numeric data entry flag
              rcr     8             ;  (flag 22)
              cstex
              s1=     1             ; set flag 22
              cstex
              rcr     6
              regn=c  14
DAT235:       gosub   DGENS8        ; tell DIGENT no CHS when X=0
              gosub   NOREG9
              gosub   RG9LCD
              gosub   RFDS55
DAT220:       golong  NFRKB
DAT240:       gosub   APPEND        ; append to alpha reg.
              c=regn  9
              ?c#0    s             ; LCD full ?
              goc     DAT245        ; not yet
              bcex    s
              gosub   ENLCD
              frsabc
              goto    DAT260
DAT245:       gosub   ROLBAK
DAT260:       c=0     x
              c=g
              gosub   ASCLCD        ; send it to LCD
DAT280:       gosub   OPROMT        ; output the prompt
              goto    DAT220
DAT300:       ?s7=1                 ; alpha mode ?
              golc    DAT500        ; yes

; *
; * Digit entry in PRGM mode
; *
              gosub   GETPC
              gosub   DELLIN
DAT320:       c=0
              dadd=c                ; enable chip 0
              gosub   DGENS8        ; tell DIGENT no CHS when X=0
              gosub   GETPC
              a=0     s             ; initialize CT
              b=a
              gosub   NXBYTA
              pt=     1
              ?c#0    wpt           ; is first byte a null ?
              gonc    DAT322        ; yes
              abex    w             ; otherwise insert a null first
              gosub   INBYT0
              a=0     s
DAT322:       c=0     x
              dadd=c                ; enable chip 0
              ?s2=1                 ; mantissa negative ?
              gonc    DAT325        ; no
              gosub   INBCHS        ; insert a CHS first
DAT325:       sel q
              pt=     12
              sel p
              c=regn  9             ; load D.P. pos counter in REG.9[13]
              setdec
              ?c#0    s
              gonc    DAT333
              c=-c    s             ; tenth complement
              sethex
              bcex    s             ; save the D.P. pos in REG.B
DAT330:       c=b     s             ; C.S _ D.P. position
              c=c-1   s             ; output D.P. now ?
              gonc    DAT335        ; not yet
              ?s0=1                 ; D.P. hit ?
              gonc    DAT335        ; no
              bcex    s
              ldi     0x1a
              gosub   INBYTJ        ; insert a D.P. to mem
              goto    DAT330
DAT333:       c=c-1   s
              sethex
DAT335:       bcex    s
              sel q
              ?pt=    13            ; finished digit 0 ?
              goc     DAT380        ; yes, all done
              c=regn  9
              c=c+1   pt            ; last digit in mantissa ?
              goc     DAT350        ; yes
              ?pt=    2             ; end of mantissa ?
              goc     DAT345        ; yes
              c=c-1   pt            ; restore the digit
              inc pt                ; move the digit to G
              lc      1
              g=c
              dec pt                ; point to next digit
              sel p
              gosub   INBYT         ; insert the digit
              goto    DAT330
DAT345:       ?s1=1                 ; EEX hit ?
              goc     DAT370        ; yes
              ?s0=1                 ; D.P. hit ?
              gonc    DAT380        ; no, no prompt
              c=c-1   s             ; D.P. at digit 3 ?
              goc     DAT380        ; yes, no prompt
              c=c-1   s             ; D.P. at digit 4 ?
              goc     DAT380        ; yes
              goto    DAT390        ; prompt
DAT350:       ?pt=    1             ; end of exp ?
              goc     DAT390        ; yes
              ?pt=    0             ; end of exp ?
              goc     DAT390        ; yes
DAT360:       ?s1=1                 ; EEX hit ?
              gonc    DAT390        ; no, we are done
DAT370:       pt=     1
              sel p
              ldi     0x1b
              gosub   INBYTJ        ; insert an EEX
              c=regn  9
              ?c#0    xs            ; exp negative ?
              gonc    DAT330        ; no
              gosub   INBCHS        ; insert a CHS
              goto    DAT330
DAT380:       sel p
              gosub   INBYT0
DAT385:       s8=     0             ; no prompt
              goto    DAT410
DAT390:       sel p
              gosub   INBYT0        ; insert a null at tail
DAT400:       s8=     1             ; say prompt
DAT410:       gosub   DFILLF
DAT415:       golong  NFRKB
INBCHS:       ldi     0x1c          ; load a CHS
INBYTJ:       pt=     0
              g=c
              golong  INBYT

; *
; * Alpha entry in PGM mode
; *
DAT500:       ldi     127
              ?a#c    x             ; is it a lazy "T" ?
              gonc    DAT400        ; yes, ignore it
              c=regn  9
              ?a#0    x             ; is it a back arrow ?
              goc     DAT510        ; no
              c=c-1   s             ; string length - 1
              ?c#0    s             ; zero length now ?
              goc     DAT505        ; no
              gosub   DATOFF        ; reset DATAENTRY flag
              golong  XDELET
DAT505:       acex    w
              gosub   PTBYTA        ; zero last char
              gosub   DECADA        ; point back one char
DAT507:       c=0     x
              dadd=c                ; enable chip 0
              acex    w
              regn=c  9
              goto    DAT520
DAT510:       c=c+1   s             ; string length + 1
              gonc    DAT515        ; string length <= 15
              gosub   BLINK         ; string length > 15
              goto    DAT415        ; ignore this char
DAT515:       acex    w
              gosub   INBYT         ; insert this char
              a=a-1   s
              nop
              goto    DAT507
DAT520:       a=c     s             ; A.S _ string length
              gosub   GETPC
              gosub   INCADA        ; point to 1st byte of TEXT
              acex    s             ; C.S = string length
              a=c     s             ; save the length in A.S
              rcr     13
              pt=     1
              lc      15            ; C[1:0] _ FX
              gosub   PTBYTA        ; update string length
              a=a+1   s             ; length = 15 ?
              goc     DAT385        ; yes, no prompt
              goto    DAT400
ROLBAK:       c=regn  9             ; load LCD counter
              a=c     s             ; A[13] _ LCD counter
              b=a     s
              gosub   ENLCD         ; enable LCD chip
ROBK10:       ?a#0    s
              rtn nc
              a=a-1   s
              frsabc
              goto    ROBK10
; *
; * OPROMT - output a prompt char and left-justify display and
; *          update LCD counter.
; * The LCD counter is in B[13] upon entry. It will be updated
; * and stored to REG.9[13] on return.
; * The counter is set to 12. Every time a char shifts from right
; * end to display the counter is decremented by one.
; * Assumes LCD enabled. Returns with chip 0 enabled.
; * USES A[13], B[13], C[13], C[2:0], N, 1 sub level.
; *
OPROMT:       ldi     0x1f
              slsabc
              ldi     0x20
              c=b     s
              c=c-1   s             ; LCD full ?
              goc     OPMT20        ; yes
              a=c     s
              c=c+1   s             ; restore LCD counter
OPMT10:       ?a#0    s             ; string at left end ?
              gonc    STOLCC        ; yes
              slsabc
              a=a-1   s
              gonc    OPMT10
STOLCC:       c=0     x
              pfad=c                ; disable LCD chip
              dadd=c                ; enable sleeper chip
              regn=c  9
              rtn
OPMT20:       c=0     s
              goto    STOLCC
; *
; * APHST_ - initialize alpha entry
; * G has the char.
; * Called by DATAENTRY and returns to DATAENTRY
; *
APHST_:       c=regn  14
              st=c                  ; load set #
              ?s3=1                 ; program mode ?
              goc     APHST4        ; yes
              rcr     8
              cstex
              s0=     1             ; set flag 23
              cstex
              rcr     6
              regn=c  14
              c=0     x
              pt=     0
              c=g                   ; load the char
              a=c     x
              ldi     127
              ?a#c    x             ; is this a lazy "T" ?
              goc     APHST3        ; no, clear alpha reg.
              c=regn  5
              pt=     1
              ?c#0    wpt           ; alpha reg. empty ?
              goc     APHST1        ; no
              pt=     13
              lc      12            ; set LCD counter
              bcex    s
              gosub   ENLCD
              goto    APHST2
APHST1:       gosub   ROLBAK
APHST2:       golong  DAT280
APHST3:       gosub   INTARG
              pt=     13
              lc      12
              bcex    s
              gosub   CLLCDE
              golong  DAT260
APHST4:       gosub   INSSUB        ; increment line #
              pt=     0
              c=g
              n=c                   ; save the char in N temp.
              gosub   GETPC         ; load the PGM counter
              a=0     S
              ldi     0xf1          ; F1 - one-char text string
              pt=     0
              g=c
              gosub   INBYT
              c=n                   ; load the char
              pt=     0
              g=c
              gosub   INBYT
              acex    w
              c=c-1   s
              regn=c  9             ; save working ptr in REG.9
              golong  DAT400        ; exit from alpha entry

; *
; * STBT10 - move some status bits to scratch area (REG.8)
; *     DIGIT(0) - 0 : D.P.hit
; *                1 : EEX hit
; *                2 : CHS hit
; *                3 : mantissa nonzero flag
; *     DIGIT(1) - 4 : digit grouping flag
; *                5 : decimal point flag
; *                6 : END
; *                7 : FIX
; *     DIGIT(2) - # of digits
; *
STBT10:       c=0     w
              dadd=c
              pt=     6
              lc      12
              pt=     4
              lc      15
              lc      12
              a=c     w             ; A _ 0000000C0FC000
              c=regn  14
              c=c.a
              rcr     2
              a=c     x
              c=c+c   m             ; move num separator & comma
              c=c+c   m             ;  to lower two bits in a digit
              rcr     4
              a=a+c   x
              c=regn  8
              rcr     11
              c=a     x
              st=c
              rcr     3
              regn=c  8
              rtn
; *
; * DECMPL - decompile
; *
; * Calling sequence :
; *          GOSUB  DECMPL
; * Assumes nothing. USES A,B,C,N, ST 0-9. 3 sub levels
; * Returns with chip 0 enabled and load status set 0
; *     and R14 in C (PACH12 in CN0 depends on R14 in C on RTN)
; *
; * PACK and DECOMPILE share common termination logic
; * Pack terminates by going either to DCPL00 or to DCPLRT.
; * Since PACK can either return to the calling program or exit
; * via error, status bit S9 is used to control what type of
; * termination is done.  S9 is cleared at the DECMPL entry
; * point, so decompile always returns.  PACK sets or resets
; * S9 as necessary before it comes to the DCPL00 or DCPLRT entries.
; *
; * S8 and S3 are used inside DECOMPILE.  S8 is used to remember
; * the state of the decompile bit in one END while traveling up
; * the label chain to find the next previous END.  S3 is used to
; * remember whether any program has been decompiled.  IF no
; * program has been decompiled, then DECOMPILE skips around
; * the logic to zero out the subroutine stack.
; *
DCPL17:       ?c#0    x             ; is this a chain END ?
              goc     DCPL15        ; no
DCPL20:       c=0                   ; remember we are at 1st PGM
              n=c
              gosub   FSTIN         ; get REG0
              goto    DCPL24

DECMPL:       s9=     0
              .public DCPL00
DCPL00:       gosub   GTFEND        ; load chain head
              acex    wpt
              n=c                   ; save .END. addr in N
              s3=     0             ; rem no PGM decompiled yet
DCPL05:                             ; next .END. addr in C[3:0]
              a=c     wpt           ; load END addr from C
              gosub   INCAD2        ; point to 3rd byte of END
              gosub   GTBYTA        ; get 3rd byte of END
              cstex                 ; check if DECMPL bit set
              ?s1=1                 ; DECMPL bit set ?
              goc     DCPL07        ; yes
              s8=     0
              cstex
              goto    DCPL11
DCPL07:       s8=     1             ; set S8 remember it
              s1=     0             ; clear DECMPL bit
              cstex
              gosub   PTBYTA        ; put the byte back
DCPL11:       c=n
              a=c
              gosub   GTLINK
              ?c#0    x             ; chain END ?
              gonc    DCPL20        ; yes
; * Moves up searching for END or first ALBL in;  mem
DCPL15:       gosub   UPLINK        ; moves up one link
              c=c+1   s             ; is this byte an END ?
              goc     DCPL17        ; no, it is an ALBL
              c=a     wpt
              n=c                   ; save END addr in N
              gosub   INCAD2        ; point to 3rd byte of END
DCPL24:       ?s8=1                 ; need to DECMPL this PGM ?
              gonc    DCPL70        ; no
              s3=     1             ; rem at least DECMPL 1 PGM
              gosub   GTBYTA
              rcr     12
DCPL25:       a=a-1   pt            ; next byte in same reg. ?
              gonc    DCPL30        ; yes
              acex    wpt           ; next byte in next reg.
              c=c-1   pt
              c=c-1   pt
              c=c-1   x             ; point to next reg.
              dadd=c
              a=c     wpt
              c=data                ; load next reg.
              rcr     12
DCPL30:       a=a-1   pt            ; point to next byte
              rcr     12            ; C[3:2] _ next byte
              c=-c    pt            ; 16 complement
              c=c+c   pt            ; one-byte ?
              goc     DCPL25        ; yes, go on to next line
              c=c+c   pt            ; three-byte line ?
              goc     DCPL40        ; no, it's two bytes
              c=c+c   pt            ; row 15 ?
              goc     DCPL45        ; no, it's row 13 or 14
              c=c+c   pt            ; test row 0 or row 15
              gonc    DCPL25        ; row 0 if no carry
; * TEXT row, let the "NXLIN" routine handle it
DCPL35:       gosub   NXLTX
              goto    DCPL25        ; go on to next line

DCPL70:       c=n                   ; get starting addr
              ?c#0    x             ; just finishing 1st PGM ?
              goc     DCPL05        ; no, keep going
              dadd=c
              ?s3=1                 ; has any PGM been DECMPL ?
              gonc    DCPL60        ; no, don't clear sub stack
              .public DCPLRT
DCPLRT:       gosub   GETPC         ; clear the subroutine stack
              .public DCRT10
DCRT10:       c=0
              dadd=c
              regn=c  11
              regn=c  12
              gosub   PUTPC
DCPL60:       c=regn  14
              st=c
              ?s9=1
              rtn nc
              .public ERRTA
ERRTA:        gosub   ERROR
              xdef    MSGTA
; *
; * Two-byte rows
DCPL40:       c=c+c   pt            ; row 9 or 10 ?
              goc     DCPL50        ; yes, simply skip 1 byte
              ?c#0    pt            ; row 12 ?
              goc     DCPL55        ; no, it's row 11
              c=c+1   xs            ; is it a LBL.NN ?
              goc     DCPL50        ; yes, skip 1 byte
              c=c+1   xs            ; is it an X<>.NN ?
              goc     DCPL50        ; yes
; * ALBL or END here
DCPL42:       gosub   INCADA        ; skip over the link
              gosub   NXBYTA        ; load the third byte
              rcr     12            ; move it to C[3:2]
              c=c+1   pt            ; is it an ALBL ?
              goc     DCPL35        ; yes, TEXT string follows
              goto    DCPL70        ; goto take care of END
DCPL50:       gosub   NXL3B2
DCPL51:       goto    DCPL25
; * GTO.NN and XEQ.NN here (clear 3-digit link)
DCPL45:       gosub   GTBYTA        ; get the first byte again
              rcr     12            ; move it to C[3:2]
              c=0     xs            ; zero first digit of link
              rcr     2
              gosub   PTBYTA        ; put it back to mem
              gosub   NXBYTA        ; get next byte
              pt=     1
              c=0     wpt           ; zero last two digits of link
              bcex    w             ; save the reg. in B
              c=b     w
              gosub   PTBYTA        ; put byte
              c=b
              rcr     12
              goto    DCPL50        ; increment 1 byte
; * GTO.0-14 here (1-byte link)
DCPL55:       gosub   NXBYTA        ; get the link byte
              pt=     1
              c=0     wpt
              bcex    w             ; save the reg. in B
              c=b     w
              gosub   PTBYTA
              c=b     w
              rcr     12
              goto    DCPL51
; *
; * XECROM - display ROM function
; * Called from DFILLF when it has an EXCROM function.
; * Called with A.X having the 1st byte of a 2-byte FC, PT=1.
; *
XECROM:       acex    x
              rcr     13
              g=c                   ; save 1st byte in G
              abex    w
              gosub   NXTBYT        ; get the second byte
              pt=     2
              c=g                   ; put 2 bytes together in C[3:0]
              gosub   GTRMAD        ; find it in the ROM
              goto    XROMNF        ; ROM not plugged in
              acex    w
              rcr     11            ; C.M _ XADR
              gosub   ENLCD
              ?s3=1                 ; XTYPE=0 ?
              gonc    XROM10        ; yes, microcode function
              c=c+1   m
              c=c+1   m             ; point to third byte of ALBL
              cxisa
              a=c     x
              a=a-1   x
              rcr     3             ; C[3:0] _ 1st byte addr
              c=c+1
              bcex    w             ; save 1st byte addr in B
              gosub   OUTROM        ; send "XROM" to LCD
              s8=     0             ; clear S8 for TXRW10
              golong  TXTROM        ; display text string from ROM
XROM10:
              gosub   PROMF2
XROMRT:       golong  DF150

; *
; * ROM not plugged in, display ROM ID & FC #
; *
XROMNF:       gosub   ENLCD
              gosub   OUTROM        ; send "XROM" to LCD
              c=b                   ; get ROM ID
              rcr     3
              a=c     x
              a=0     s
              gosub   GENNUM
              frsabc
              pt=     1
              lc      15
              slsabc
              abex    x             ; get function #
              a=0     s
              gosub   GENNUM
              goto    XROMRT

              .public SRBMAP
              .public TBITMP
              .public TBITMA
              .public XROM


; *  TBITMP - test bit map
; *- Test the correct bit map (shifted/unshifted) to
; *- determine whether a particular key has been
; *- assigned or not
; *- IN:  A[2:1]= logical keycode (0:79 form)
; *-      chip 0 selected
; *- OUT: C=0 implies bit not set
; *-      C#0 implies bit set
; *-      M= bit map
; *-      chip 0 & appropriate register is selected
; *- USES: C[13:0], A[13:0], M[13:0]
; *
; * TBITMA entry - same as TBITMP except KC is in A[1:0] and is
; * in 1-80 form on ENTRY

TBITMA:       a=a-1   x             ; decrement K.C.
              asl                   ; A[2]_COL
TBITMP:       pt=     2             ; C[2]_4
              lc      4             ; -
              s0=     0             ; S0_shiftset
              lc      8             ; -
              pt=     1             ; -
              c=a-c   pt            ; -
              goc     1$            ; -
              a=c     pt            ; -
              s0=     1             ; -
1$:           pt=     5             ; position ptr at column
              goto    2$            ; -
3$:           inc pt                ; -
              inc pt                ; -
2$:           a=a-1   xs            ; -
              gonc    3$            ; -
              asl     x             ; A[2]_row
              ?a<c    xs            ; row<4?
              goc     4$            ; yes
              inc pt                ; set ptr
              a=a-c   xs            ; -
4$:           c=0                   ; position row,col bit
              ?pt=    0             ; -  ( top row keys?)
              rtn c                 ; -  (yes)
              c=c+1   pt            ; -
              legal
              goto    5$            ; -  (yes)
6$:           c=c+c   pt            ; -
5$:           a=a-1   xs            ; -
              gonc    6$            ; -
              a=c                   ; A_mask
              c=regn  15            ; -
              ?s0=1                 ; shiftset?
              goc     7$            ; nope
              c=regn  10            ; -
7$:           m=c                   ; M_C_bit map
              c=c.a                 ; row,col bit set?
              rtn                   ; -


; *  SRBMAP - set/reset bit map
; *- Toggle the bit designated by the mask found in
; *- register C.
; *- IN:  C[13:0]= bit map mask (result of TBITMP)
; *-      M[13:0]= bit map
; *-      The appropriate register must be selected
; *- OUT: chip 0 selected
; *- USES: C[13:0], M[13:0], A[13:0]

SRBMAP:       ?c#0                  ; set ?
              goc     SRBM10        ; yes, reset
              c=m                   ; -
              c=a+c   pt            ; set it
              legal
              goto    .+4           ; -
SRBM10:       c=m                   ; -
              acex                  ; -
              c=a-c                 ; -
              data=c                ; restore bit map
              rtn                   ; return

; *  XROM - execute rom function
; *- Locates ROM function and prepares it for execution.
; *- If the function is a user language program, a transfer
; *- is made to the XEQC program segment.  If the function
; *- is microcoded, a jump is made directly to the function's
; *- execution point.
; *  IN:  first byte of FC is in G
; *       second byte of FC is in ST and in C[1:0]
; *       PT=2
; *       numeric argument, if any, is in B.X
; *       alpha argument, if any, is in REG 9
; *- OUT: for microcode FCNs, SS0 UP, numeric arg in A.X, alpha arg in
; *             REG 9, NFRPU  on the stack
; *       for user language FCNs, current addr saved in R10[3:0],
; *             new addr in C[3:0], exits to XGI57
; *- USES: 1 subroutine level

XROM:         c=b                   ; save numeric argument
              n=c                   ;  in N
              c=g                   ; restore FC to
              c=st                  ;  C[3:0]
              gosub   GTRMAD
              goto    XRM20         ; couldn't find it
; * GTRMAD returns to P+2 with found address in A[3:0]
              ?s3=1                 ; user language?
              goc     XRM10         ; yes
                                    ; microcode FCN
              c=regn  14            ; put up SS0
              st=c
              c=n                   ; retrieve numeric arg to A.X
              acex
              rcr     11
              gotoc

XRM10:                              ; user language FCN
              abex                  ; save new addr in B
              gosub   SAVRTN        ; save old addr in R10
              c=b                   ; put new addr in C[3:0]
              golong  XGI57

XRM20:        golong  ERRNE         ; report error

; *******************************************************
; * TXTLBL - text of label string
; * This is the front end for text LBL
; * Given a PC in A[3:0] pointing at the first byte
; * of an alpha LBL this routine displays the alpha text
; * string.
; * For ROM S2=1. For RAM S2=0.
; * Sets status for no prompt and LCD not full.
; *
; * TXTLB1 - same as TXTLBL except clears S4 on entry.
; *     S4 is used to decide whether to clear the display
; *     before putting up the text string.  S4=0 implies
; *     clear the display, s4=1 implies don't clear first.
; *******************************************************
TXTLB1:       s4=     0             ; remember to clear display
TXTLBL:       s8=     0             ; no prompt
              s1=     0             ; LCD not full
              ?s2=1                 ; ROM or RAM??
              goc     ROMSTG        ; ROM
              gosub   INCADP        ; set PT=3 inc adr
              gosub   NXBYTA        ; get # chr
              gosub   INCADA        ; skip assign bit
              goto    CLRL
ROMSTG:       a=a+1                 ; inc adr
              legal
              gosub   NXBYTO        ; get # chr
              a=a+1
CLRL:         c=c-1   x
              bcex    x
              abex                  ; count in A, adr in B
              gosub   ENLCD
              ?s4=1                 ; skip clearing the display?
              gsubnc  CLRLCD        ; no. clear the display
              golong  TXTSTR

              .public STBT30
              .public STBT31
STBT30:       ?s8=1                 ; last PGM needs packing ?
              gonc    STBT31        ; no
              bcex    w
              m=c
              bcex    w
STBT31:       s8=     0
              cstex
              ?s2=1
              gonc    STBT32
              s8=     1
              s2=     0
              s1=     1
STBT32:       cstex
              rtn
; *
; * OUTROM - shift "XROM " into the LCD from the right end
; *
; * For entry, LCD must be enabled
; * USES C[6:0] and one additional subroutine level
; *
              .public OUTROM
OUTROM:       gosub   MESSL
              .con    24            ; X
              .con    18            ; R
              .con    15            ; O
              .con    13            ; M
              .con    0x220         ; BLANK
              rtn

              .public NEWT_COLDST
NEWT_COLDST:  pt=     4
              lc      6             ; disable MMU
              wcmd
              golong  ROMCHK

; * Reserve 2 words at the end of CN11 for the chip 2 checksum
; * trailer.
              .fillto 0x3fe

REVLV2:       .con    7             ; REV level= G
CKSUM2:       .con    0000
