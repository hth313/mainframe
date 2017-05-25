;;; This is HP41 mainframe resurrected from list file output. QUAD 1
;;;
;;; REV.  6/81A
;;; Original file CN1B
;;;

#include "hp41cv.h"

; * HP41C mainframe microcode addresses @2000-3777

              .section QUAD1


              .public AFORMT
              .public ANNOUT
              .public ANN_14
              .public BLANK
              .public CHKFUL
              .public CHRLCD
              .public CPGMHD
              .public DEROW
              .public DERW00
              .public DF060
              .public DF150
              .public DF160
              .public DF200
              .public DFILLF
              .public DFKBCK
              .public DFRST8
              .public DFRST9
              .public GENNUM
              .public LDSST0
              .public MEMLFT
              .public OFSHFT
              .public PROMF1
              .public PROMF2
              .public PROMFC
              .public ROMH05
              .public ROMH35
              .public ROMHED
              .public ROW120
              .public ROW933
              .public ROW940
              .public RSTANN
              .public RW0110
              .public RW0141
              .public TXRW10
              .public TXTROW
              .public TXTSTR
              .public XMSGPR
              .public XR_S

; *
; * Row jump table
; *
              goto    ROW0_
              goto    ROW1
              goto    ROW2
              goto    ROW3
              goto    `ROW4-8`
              goto    `ROW4-8`
              goto    `ROW4-8`
              goto    `ROW4-8`
              goto    `ROW4-8`
              goto    ROW09
              goto    ROW10
              goto    ROW11_
              goto    ROW12_
              goto    RO1314
              goto    RO1314
              golong  TXTROW
ROW0_:        ldi     0xCF          ; prompt string in C,F
ROW010:       a=a-1   x             ; operand minus one
              legal
              goto    DF120
ROW1:         golong  DEROW         ; this is a digit entry row
ROW2:         ldi     0x90          ; prompt string in 9,0
              goto    DF120
`ROW4-8`:     gosub   PROMFC
              golong  DF150
ROW3:         ldi     0x91          ; prompt string in 9,1
DF120:        a=0     pt            ; A[1] _ 0
              b=a     x             ; save the operand in B
              a=c     x
              gosub   PROMFC        ; output prompt string
              abex    x             ; A.X _ operand

; * Next instruction (S0=0) may not be necessary.
              s0=     0             ; say two-digit operand
              goto    ROW931
ROW09:        goto    ROW9
ROW11_:       ldi     0xD0          ; prompt string in 13,0
              goto    ROW010
ROW12_:       ldi     0xce
              ?a<c    x             ; is it LBL NN or X<>NN?
              gonc    ROW910        ; yes
              golong  ROW120
RO1314:       pt=     0
              a=0     pt
              gosub   PROMFC
              gosub   NBYTA0        ; skip one byte (three-byte FC)
              gosub   NXTBYT
              cstex
              s7=     0
              cstex
              goto    ROW930
ROW10:        ldi     0xa8          ; test for XECROM FC
              ?a<c    x             ; is it a XECROM FC ?
              golc    XECROM        ; yes
              ldi     0xae
              ?a<c    x             ; is it a XEQ/GTO IND ?
              goc     ROW910        ; no
              gosub   NBYTAB        ; get operand
              cstex
              gosub   ENLCD
              ?s7=1                 ; is it a XEQ ?
              gonc    1$            ; no
              ldi     0xe0          ; load XEQ FC
              goto    2$
1$:           ldi     0xd0          ; load GTO FC
2$:           gosub   PROMF1
              goto    ROW933
; *
; * Numerical operand
; * ROW 9
; *
ROW9:         s0=     1
              ldi     0x9c          ; test for 1- or 2-digit operand
              ?a<c    x             ; 1-digit operand?
              gonc    .+2           ; yes
; *
; * Numerical operand
; * B[3:0] has addr point to one byte before operand
; * If S0=1 means 1-digit operand
; * If S0=0 means 2-digit operand
; *
ROW910:       s0=     0
              gosub   PROMFC        ; prompt the function first
              gosub   NBYTA0        ; load operand
ROW930:       a=c     x             ; save operand in a temp
              gosub   ENLCD         ; enable LCD chip
ROW931:       acex    x             ; load operand back to C.X
              cstex                 ; move operand to status bits
              ?s7=1                 ; indirect ?
              gonc    ROW935        ; no
ROW933:       s7=     0
              cstex
              s0=     0
              bcex    x
              gosub   MESSL
              .con    9             ; I
              .con    14            ; N
              .con    0x204         ; D
              gosub   BLANK         ; output a blank
              abex    x
              goto    ROW936
ROW935:       cstex
              a=c     x             ; A[1:0] _ operand
ROW936:       a=0     xs
              ldi     102
              ?a<c    x             ; numerical operand ?
              gonc    ROW940        ; no
              a=0     s
              a=a+1   s
              ?s0=1                 ; 1-digit numerical operand
              goc     1$            ; yes
              a=a+1   s
              legal
1$:           gosub   GENNUM        ; output operand

; *
; * DFILLF exit point
; *
DF150:        ?s1=1                 ; display full ?
              gsubnc  LEFTJ         ; no, left-justify
DF160:        golong  LDSST0        ; enable chip 0
ROW940:       ldi     112
              ?a<c    x             ; capital A,B,C,D,E ?
              goc     CAPABC        ; yes
              ?a#c    x             ; is it a T's
              gonc    RT            ; yes
              ldi     116
              ?a#c    x             ; is it a LastX ?
              gonc    RL            ; yes
              ?a<c    x             ; is it small A,B,C,D,E ?
              gonc    SMLABC        ; yes
              ldi     113           ; it is an X, Y or Z
                                    ; but in the reverse order
              c=a-c   x
              rcr     1             ; C.S _ offset
              ldi     26            ; load a Z'S
ROW945:       c=c-1   s
              goc     ROW960
              c=c-1   x
              legal
              goto    ROW945

RT:           ldi     92
ROW950:       c=a-c   x
              legal
ROW960:       slsabc
              goto    DF150
CAPABC:       ldi     101
              goto    ROW950
SMLABC:       ldi     122
              c=a-c   x
              c=c+1   xs
              legal
              goto    ROW960
RL:           ldi     104
              goto    ROW950
; *
; *
; * ROW 1 - including digit entry and AGTO, AXEQ
; * A[2:0] has the function code B[3:0] points to 1st byte of
; * digit entry string, if it's a digit entry FC.
; *
DEROW:
              ldi     0x1d
              ?a<c    x             ; is it a digit entry FC ?
              gonc    RW0110        ; no, either AGTO or AXEQ
              goto    DERW70
; *
; * Digit entry starts here
; *
DERW00:       ldi     0x1a
              ?a<c    x             ; is it a digit ?
              goc     DERW50        ; yes
              ?a#c    x             ; is it a D.P.?
              goc     DERW10        ; no
              frsabc
              cstex
              s6=     1             ; set D.P.
              pt=     6             ; check for european notation
              acex    pt
              c=c+c   pt
              goc     DERW05
              s7=     1             ; set comma
DERW05:       cstex
              slsabc
              goto    DERW60
DERW10:       c=c+1   x
              ?a#c    x             ; is it an EEX ?
              goc     DERW20        ; no
              gosub   BLANK
              ldi     5             ;          "E"
              goto    DERW55
DERW20:       ldi     0x2d          ;  it must be a CHS
              goto    DERW55
DERW50:       acex    x
              pt=     1
              lc      3
DERW55:       gosub   CHRLCD
DERW60:       gosub   NBYTA0        ; enbale chip 0
                                    ; & get next byte
              abex                  ; put the PGMPTR back to B
              c=0     xs
              a=c     x             ; A.X _ next byte
DERW70:       gosub   ENLCD
              ldi     0x1d
              pt=     1
              ?a#c    pt            ; is this byte a row 1 FC ?
              goc     DF190         ; no
              ?a<c    x             ; is it a digit entry FC ?
              goc     DERW00        ; yes
DF190:        ?s8=1                 ; prompt ?
              gonc    DF200         ; no
              ldi     0x1f
              gosub   CHRLCD
DF200:        golong  DF150
RW0110:       asl     x             ; convert FC from 1D to D0
              a=0     xs            ; or from 1E to E0
              gosub   PROMFC
              gosub   NBYTA0
              abex
RW0140:       a=c     x
RW0141:       s8=     0
; *
; * TXTSTR - text string
; * A[0] has the length of the string. B[3:0] points to one byte
; * before 1st char.
; * If S2=1, alpha string is known in ROM
; * If S2=0, string is in RAM
; *
; * TXTROM - sets S2 and drops into TXTSTR
; *
; * TXRW10 - identical to TXTSTR
; *
; * TXTROW - copies S10 (ROMFLAG) into S2 and falls into TXTSTR
; *
TXTROW:       s2=     0
              ?s10=1                ; ROMFLAG?
              gonc    TXTSTR        ; no
              .public TXTROM
TXTROM:       s2=     1             ; yes
TXTSTR:
TXRW10:       pt=     1
              a=0     pt
              acex    x
              c=0     m
              c=0     xs
              rcr     11
              a=c     m             ; A.M _ char counter
              gosub   ENLCD
              frsabc
              ldi     0x107
              slsabc
TXRW30:       a=a-1   m             ; all done ?
              goc     DF190         ; yes
              abex    w
              gosub   ENCP00
              pt=     3             ; set up for NXBYTA
              ?s2=1                 ; ROM?
              gsubc   NXBYTO        ; yes
              ?s2=1                 ; same question
              gsubnc  NXBYTA        ; no
              abex
              a=c     x             ; A.X _ char
              gosub   ENLCD
              acex    x
              gosub   ASCLCD
              gosub   CHKFUL        ; see if LCD full
              goto    TXRW30

ROW120:       abex
              gosub   INCAD
              gosub   NXTBYT        ; load operand
              b=a     w             ; save PC in B
              a=c     x
              gosub   ENLCD
              pt=     1
              a=a+1   pt            ; is it a LBL ?
              gonc    ROW122        ; no, it's an END
              ldi     0xcf          ; load LBL FC
              gosub   PROMF1        ; prompt the function
              gosub   ENCP00        ; enable chip 0
              abex
              gosub   INCAD
              abex
              a=a-1                 ; char counter -1 (skip KC)
              legal
              golong  RW0141
ROW122:       acex    wpt
              c=c-1   pt            ; restore the "END"
              st=c
              ldi     0xc0          ; prompt "END"
              gosub   PROMF1
              ?s10=1                ; are we in ROM ?
              goc     ROW125        ; yes, prompt "END" only
              ?s5=1                 ; final END ?
              gonc    ROW125        ; no
              disoff
              rabcr
              rabcr
              ldi     0x44
              slsabc
              gosub   REGLFT
              a=c     x
              a=0     s
              gosub   ENLCD
              gosub   GENNUM
              ldi     0x20
              slsabc
              rabcl                 ; read in leftmost char
              pt=     0
              ?c#0    pt            ; is it a blank ?
              gonc    1$            ; yes, throw it away
              srsabc                ; is an "E", put it back
1$:           ldi     0x60          ; load a dot
              srsabc                ; shift in left end
              distog
ROW125:       s1=     0
              goto    DF040
; *
; * DFILLF _ display one program step
; *
; * Calling sequence:
; *          PGMPTR _ point to last byte of previous step
; *          GOSUB DFILLF
; *          If private, display "PRIVATE" and return
; *          else display one line of program memory
; * Four entry points :
; * 1. DFILLF - normal entry
; * 2. DFRST9 - reset S9 remember keyboard not been reset yet
; *             reset S8 say no prompt & scroll
; * 3. DFRST8 - only reset S8
; * 4. DFKBCK - spend approximately 100 millisec checking for
; *             key up before dropping into DFRST9
; * USES S0,S1,S2, A,B,C. assumes nothing.
; * Not true! Calls LINNUM. See comments on LINNUM.
; * Uses at least two subroutine levels
; * Return with chip enabled & status set #0 enabled
; * Except on the key up path out of DFKBCK the chip enable and
; * status set are unchanged.
; *
DFKBCK:       ldi     200
              s9=     1             ; assume KB will be reset
DF010:        rst kb
              chk kb
              rtn nc
              c=c-1   x
              gonc    DF010
DFRST9:       s9=     0             ; say keyboard not reset yet
DFRST8:       s8=     0             ; say no prompt, scrolling
DFILLF:       s1=     0             ; say lcd notl full yet
              s0=     0             ; assume 2nd operand
              gosub   ENCP00
              gosub   LINNUM        ; load line #
              a=c     x             ; A.X _ line #
              b=a     x             ; save line # in B.X
              ?s12=1                ; private ?
              gonc    DF030         ; not private
XMSGPR:       gosub   MSG
              xdef    MSGPR         ; say "PRIVATE"
              goto    DF040
DF030:        gosub   CLLCDE
              a=0     s
              gosub   GENNUM        ; output line #
              ?b#0    x             ; line# = 0 ?
              goc     DF050         ; no
              ?s10=1                ; are we in ROM ?
              goc     DF040         ; yes, no prompt for line#=0
              gosub   REGLFT
              a=c     x             ; A.X _ mem left
              a=0     s
              gosub   ENLCD
              gosub   GENNUM
DF040:        golong  DF150
DF050:        ldi     0x20
              slsabc                ; output a blank
DF060:        gosub   ENCP00        ; enable chip 0
              c=regn  14            ; set up for D.P.(comma) check
              a=c
              gosub   GETPC         ; load program pointer
DF100:        gosub   NXTBYT        ; next byte
              pt=     1
              ?c#0    wpt           ; is it a null ?
              gonc    DF100         ; yes, skip it
              b=a                   ; save the PGMPTR in B
              c=0     xs
              a=c     x             ; A.X _ function code
              rcr     2
              ldi     0x40          ; jump table start from
                                    ;   QUAD 1
              rcr     10
              gotoc

; *
; * REGLFT - pushes " REG " into LCD from right end & falls into
; *     MEMLFT
; * Assumes LCD enabled on entry
; * See MEMLFT for exit conditions
; * Uses one additional subroutine level and uses C[6:0] - see
; *     MEMLFT for additional register usage
; *
              .PUBLIC REGLFT
REGLFT:       gosub   MESSL
              .con    32            ; blank
              .con    18            ;  R
              .con    5             ;  E
              .con    7             ;  G
              .con    0x220         ;  blank
; *
; * MEMLFT - compute how many unused reg left in mem
; * Assumes nothing.
; * Returns with # of reg left in C[2:0] and chip 0 enabled.
; * Uses A and C. Uses one additional subroutine level.
; *
MEMLFT:       gosub   ENCP00
              c=regn  13            ; load chain head
              c=0     m
              a=c     w
              goto    MEMLF2
MEMLF1:       c=c-1   x             ; point to next reg.
              a=c     w
              dadd=c
              c=data                ; load the reg.
              ?c#0    w             ; zero in it ?
              goc     MEMLF3        ; no, reach end of mem
              a=a+1   m             ; count 1
MEMLF2:       ldi     0xc0
              ?a#c    x             ; reach reg.(C,0) ?
              gonc    MEMLF3        ; yes
              acex    w
              goto    MEMLF1
MEMLF3:       acex
              rcr     3
              rtn
; *
; * CHRLCD - output a char to LCD and check scrolling
; * If S1=1 means display already full. Then after sending the char
; * to display check if a delay is required by calling scroll routine.
; * The LCD code is expected in C[2:0]. Assumes LCD enabled.
; * USES A.X, C    May set S1,S9  May rtn via SCROL0
; * May use a subroutine level
; *
BLANK:        ldi     0x20          ; output a blank
CHRLCD:       slsabc
CHKFUL:       ?s1=1                 ; LCD already full ?
              goc     CKFL10        ; yes, do delay before return
              ldi     0x20
              a=c     x
              rabcl                 ; read the leftmost character
              srsabc                ; put it back
              c=0     xs
              ?a#c    x             ; is it a blank ?
              rtn nc                ; yes, no need for scrolling yet
              s1=     1             ; remember LCD full
CKFL10:       golong  SCROL0

; *
; * PROMFC - output a prompt string for a microcode function
; *
; * PROMFC entry: A[1:0]=MAINFRAME FC, LCD need not be enabled
; * PROMF1 entry: C[1:0]=MAINFRAME FC, LCD must be enabled
; * PROMF2 entry: C[6:3]=XADR, lcd enabled
; * All entry points use C and leave S8=0 and LCD enabled
; * PROMFC and PROMF1 leave PT=2
; * PROMFC uses a subroutine level to call ENLCD
; *
PROMFC:       gosub   ENLCD
              c=a     x             ; C.X _ FC
PROMF1:       rcr     2
              ldi     0x14          ; main function table
                                    ;   start from @12000
              rcr     9
              cxisa                 ; load XADR
              pt=     3
              lc      1
              rcr     11
PROMF2:       s8=     1             ; initialize final char flag
PMPT20:       c=c-1   m
              cxisa                 ; get character
              c=0     xs
              cstex
              ?s6=1                 ; special character?
              gonc    PMPT30        ; no
              c=c+1   xs            ; yes. set bit for display CREG
              s6=     0
PMPT30:       ?s7=1                 ; final character?
              gonc    PMPT40
              s8=     0             ; yes
              s7=     0
PMPT40:       cstex
              slsabc                ; put char to LCD
              ?s8=1                 ; more chars?
              goc     PMPT20        ; yes
              ldi     0x20
              slsabc                ; output a blank
              rtn
; *
; * GENNUM - convert a hex number to decimal & output to LCD
; * Calling sequence:
; *         A.X _ hex number
; *         A.S _ # of output digits. If A.S=0, # of output
; *               Digits will be either 2, 3 or 4.
; *         If output to LCD is desired, enter with LCD chip enabled.
; *         If LCD is to remain unchanged, enter with a nonexistent
; *             data storage chip (i.e. chip 1) enabled.
; *         GOSUB  GENNUM
; * Leaves # of digits in B.S
; * Leaves digit string in A.M left-justified
; * Returns active pointer=0 for historical reasons
; * USES A,C,B[13]. Doesn't call any subroutines.
; * Doesn't change which chip (sleeper or lcd) is enabled.
; *
GENNUM:       b=a     s
              c=0     w
              setdec
              acex    x
              a=c     w
              rcr     2             ; C[0] _ most sign. digit
              c=c+1   x             ; convert it to decimal
              c=c-1   x
              c=c+c                 ; multiply it by 16
              c=c+c
              c=c+c
              c=c+c
              asl     x
              acex    x
              rcr     2             ; C[0] _ second digit
              c=c+1   x             ; convert it to decimal
              c=c-1   x
              c=a+c   x
              acex    s             ; A.S _ least sign. digit
              c=c+c                 ; multiply it by 16
              c=c+c
              c=c+c
              c=c+c
              a=0     x
              acex    w
              rcr     13            ; C[0] _ least sign. digit
              c=c+1                 ; convert it to decimal
              c=c-1
              c=a+c   w
              sethex
              ?b#0    s             ; output digits = 0 ?
              goc     GENN20        ; no
              pt=     13
              lc      4
              a=c     s             ; determine min. output digits
              rcr     4
              ?c#0    s             ; needs 4 digits ?
              goc     GENN40        ; yes
              rcr     13
              a=a-1   s
              ?c#0    s             ; needs 3 digits ?
              goc     GENN40        ; yes
              rcr     13
              a=a-1   s             ; two digits
              legal
              goto    GENN40
GENN20:       a=b     s
GENN25:       a=a-1   s
              goc     GENN30
              rcr     1
              goto    GENN25
GENN30:       abex    s
GENN40:       rcr     1             ; copy digit string to A.M
              a=c     m
              b=a     s             ; copy # of digits to B.S
              rcr     13            ; left-justify digit string in C
              pt=     0             ; as advertised for exit
GENN55:       a=a-1   s
              rtn c
              ldi     0x3
              rcr     13
              slsabc
              goto    GENN55

; *
; * AFORMT - format a number and put it to alpha string
; * Called by ARCL, the number is expected in B
; * Assumes nothing. USES A,B,C. Returns with chip 0 enabled.
; * Calls APPEND to put the char in alpha reg.
; * Calls format, 2 sub levels.
; *
AFORMT:       c=0     x
              dadd=c                ; enable chip 0
              c=b     w             ; load the number
              gosub   FORMAT
              s8=     0             ; assume fix mode
              ?pt=    3             ; fix mode ?
              gonc    1$            ; yes
              s8=     1             ; SCI or ENG mode
1$:           acex                  ; LOAD DISPLAY REG.A
              m=c                   ; SAVE IN M
              ?c#0    s             ; mantissa negative ?
              gsubc   APND_         ; yes
              sel q
              pt=     12            ; Q=12
AFMT10:       sel q
AFMT11:       ?pt=    13            ; just done with exp ?
              rtn c                 ; yes, we are all done
AFMT12:       lc      3
              inc pt
              abex    pt
              ?a<c    pt            ; encounter a blank ?
              goc     AFMT30        ; yes, end of mantissa
              ?a#c    pt            ; is it a digit only ?
              gonc    AFMT20        ; yes
              abex    pt
              gosub   APNDDG        ; output the digit first
              sel q
              c=b     pt
              c=c+c   pt            ; is it a comma ?
              gonc    1$            ; no, it is a D.P.
              ldi     0x2c          ; comma
              goto    2$
1$:           ldi     0x2e          ; D.P.
2$:           dec     pt
              sel p
              gosub   APND10
              goto    AFMT10
AFMT20:       gosub   APNDDG        ; output the digit
              sel q
              dec pt
              ?pt=    2             ; end of mantissa ?
              gonc    AFMT10        ; not yet
AFMT30:       ?s8=1                 ; fix mode ?
              rtn nc                ; yes, all done
              pt=     1
              c=m
              ?c#0    pt
              goc     1$
              dec pt
1$:           sel p
              ldi     0x45          ; E
              gosub   APND10
              c=m
              ?c#0    xs            ; exp negative ?
              gsubc   APND_         ; yes
              goto    AFMT10
; *
; * APNDDG (including APND-, APND10, APND20) has been moved to
; * QUAD 0 to fill up a hole there
; *
; *  ROMHED - locate rom head address
; *- Returns the address of the begin statement at
; *- The start of a program in ROM
; *- IN:  chip 0 selected
; *- OUT: A[3:0]= ROM head address
; *- USES: C[13:0], status bit 12 & A[3:0]
; *-
; *  ENTRY POINT- ROMH05
; *- IN: PT= 3
; *-     C[6:3]= ROM address

ROMHED:       pt=     3             ; -
              c=regn  12            ; get PGMCTR
ROMH05:       rcr     11            ; -
              s12=    0             ; -
              goto    .+2           ; -
ROMH06:       c=c-1   m             ; find begin stmt
              cxisa                 ; -
              c=c-1   xs            ; -
              goc     ROMH06        ; -
              c=c-1   xs            ; -
              goc     ROMH06        ; -
              c=c-1   xs            ; set privacy bit
              goc     ROMH35        ; -
              s12=    1             ; -
ROMH35:       rcr     3             ; A[3:0]_head addr
              a=c     wpt           ; -
              rtn                   ; -


; *  CPGMHD - current program head
; *- Returns the address of the begin statement in
; *- ROM and the address of the first step of a
; *- program in RAM
; *- IN:  A[3:0]= program counter (must be the address of a link,
; *               i.e., the first byte of a global LBL or END)
; *       no peripheral enabled.
; *-      PT= 3
; *- OUT: A[3:0]= current program head address
; *-      PT=  3
; *- USES: A[3:0], C[13:0], B[4:0]
; *- USES: 1 subroutine level

CPGMHD:       ?s10=1                ; ROMFLAG?
              gonc    CPGM10        ; nope
              acex    wpt           ; -
              goto    ROMH05        ; -
              .public CPGM10        ; for card reader & printer
CPGM10:       gsblng  GTLINK        ; get link
CPGM15:       ?c#0    x             ; chain end?
              golnc   FSTIN         ; yes
              gsblng  UPLINK        ; no, traverse chain
              c=c+1   s             ; alpha LBL?
              goc     CPGM15        ; yes
              golong  INCAD2        ; A[3:0]_head address

              .public ALCL00
              .public KEYOP
              .public RAK60
; *
; * KEYOP - keycode operand - parse logic for assign FCN
; *
KEYOP:                              ; on entry, chip 0 is on,
                                    ; ptr=1, C.X=0x01F,
                                    ; A[1:0]=0x1F
              gosub   OFSHFT
              gosub   ENLCD
              ldi     0x20
              slsabc                ; insert blank
KYOP10:       gosub   NEXT1
                                    ; on return from next, PT=1,
                                    ; LCD chip on, SS PTEMP1 up
                                    ; & B.X=" "
                                    ; & N[2:1]=logical KC(0-79)
              .public KYOPCK        ;   for Wand 11/26/79
KYOPCK:
              nop                   ; BKARROW is a legal operand
              ?s6=1                 ; shift key?
              gonc    KYOP40        ; no
              c=n                   ; retrieve logical KC to C[2:1]
              c=c+c   pt            ; shift already on?
              goc     KYOP11        ; yes
              ldi     45            ; no   "-"
              slsabc                ; put hyphen to LCD
              goto    KY11A
KYOP11:       rabcr                 ; shift off hyphen
KY11A:
              gosub   TOGSHF        ; toggle the shift flag
              gosub   ENLCD
              goto    KYOP10

KYOP40:
              ldi     0xc3
              a=c
              c=keys
              rcr     3             ; KC to C[1:0]
              ?a<c    wpt           ; KC>C3?
              gonc    KYOP50        ; no. legitimate key
              gosub   BLINK         ; yes. USER, PRGM or ALPHA key
              goto    KYOP10

KYOP50:
              c=0
              c=keys
              rcr     3
              lc      3
              c=c+1   x
              slsabc                ; send row to LCD
              a=c     x             ; copy ASCII row to A.X
              ldi     0x34          ; "4"
              s8=     0             ; assume ROW#4
              ?a#c    x             ; ROW#4?
              goc     KYOP60        ; yes, not "ENTER" row
              s8=     1             ; "ENTER" row
KYOP60:       c=n                   ; recover log KC to C[2:1]
              csr     x             ; log KC to C[1:0], 0 to C[2]
              a=c     x             ; save log KC in A.X
              csr     x             ; log col to C[0]
              pt=     1
              lc      3
              ?s8=1                 ; "ENTER" row
              gonc    KYOP70        ; no
              ?c#0    pt            ; a key to the right of "ENTER"?
              goc     KYOP80        ; yes - don't inc column #
KYOP70:       c=c+1   pt            ; increment column #
KYOP80:       slsabc                ; send col to LCD
              a=a+1   x             ; KC internal form (1-80)
              legal
              golong  NULT_3

; *
; * ALCL00 - logic to map local alpha operands onto numeric operands
; *
ALCL00:
              a=c                   ; character to A.[1:0]
                                    ; remainder of A is zero
              ldi     0x41          ; "A"
              ?a<c    X             ; char<"A"?
              rtn c                 ; not local
              ldi     0x4b          ; "K"
              ?a<c    x             ; char<"K"?
              gonc    ALCL50        ; no. test for lower case
              ldi     37            ; map 65 onto 102
ALCL10:       c=a+c   x
              rcr     13
              bcex    x             ; argument to B[2:1],
                                    ; FC to C[1:0]
              pt=     1
              a=c     wpt           ; FC to A[1:0]
              ldi     0x1e          ; FC for AXEQ
              ?a#c    wpt           ; FC # AXEQ?
              gonc    ALCL20        ; this is AXEQ
              c=c-1   x             ; convert AXEQ to AGTO
              ?a#c    wpt           ; FC # AGTO?
              goc     ALCL30        ; not AGTO
ALCL20:       rcr     10            ; new FC to C[4:3]
              a=c                   ; new FC to A[4:3]
              abex    x             ; merge argument with value
              golong  NLT020        ;  in A[4:1]

ALCL30:       ldi     0xcd          ; FC for ALBL
              ?a#c    wpt           ; FC # ALBL?
              goc     ALCL40        ; not ALBL.
              rcr     1
              c=c+1   s
              c=c+1   s             ; LBL NN FC (CF) to C[13:0]
              legal
              goto    ALCL20

ALCL40:       abex    x             ; FC back to B.X
              rtn

ALCL50:       ldi     0x061         ; test for lower case a...e
                                    ; small a
              ?a<c    x             ; char<small a?
              rtn c                 ; yes. not local
              ldi     0x66          ; small f
              ?a<c    x             ; char<small f?
              rtn nc                ; no. not local
              ldi     26            ; map 97 to 123
              goto    ALCL10
; *
; * Enter here from parse NEWFCN logic in user mode when the
; * bit in the bit map is set.
RAK60:                              ; bit set in bit map
              c=n                   ; recover KC from N
              rcr     1             ; setup
              a=c                   ; for
              a=a+1   x             ; -
              s1=     0             ; GCPKC
              gosub   GCPKC         ; find reassigned FCN
              ?s3=1                 ; RAM?
              goc     RAK100        ; yes
              pt=     3
              ?c#0    pt            ; XROM FC?
              goc     RAK70         ; yes
              a=c                   ; -
              a=0     xs            ; must be mainframe
              golong  NAME4A

              .public RAK70         ; for Wand XROM
; * Entry point add for Wand on 3-13-79
; *
RAK70:                              ; XROM
              n=c                   ; save FC in N
              gosub   GTRMAD
; * GTRMAD returns XADR in A[3:0]
              goto    RAK90         ; missing ROM
              acex
              cmex                  ; put XADR to M
              ?s3=1                 ; user language?
              goc     RAK80         ; yes
              c=n                   ; retrieve FC from N
              golong  NAME4D

RAK80:                              ; ROM user language
                                    ; XROM FC in N[3:0]
                                    ; XADR in M[3:0]
              s2=     1             ; STRING in ROM
              goto    `NM44@X`

RAK90:        gosub   CLLCDE        ; missing rom
              gosub   XROMNF
              gosub   ENCP00
              s9=     0             ; say addr unknown
              c=n                   ; XROM to C
              gosub   STORFC
              golong  NM44_5

RAK100:                             ; RAM
              m=c                   ; save addr in M
              gosub   PRT4          ;  print dataentry, if any
              c=m                   ; recover address
              pt=     3
              gosub   GTLNKA        ; get # of chars
              rcr     13            ; # of chars to
              a=c     s             ;  A.S
              a=a-1   s             ; skip over keycode
              a=a-1   s
              legal
              gosub   NXBYT3        ; move ptr to keycode
              c=0                   ; initialize string
RAK110:       n=c                   ; save string in N
              gosub   NXBYTA
              cstex
              c=n
              cstex
              rcr     2
              a=a-1   s
              gonc    RAK110
              gosub   RTJLBL
              n=c
              c=0     x
              dadd=c
              c=n
              regn=c  9
              ldi     0x1e          ; FC for AXEQ
              rcr     12
              gosub   STORFC
              s2=     0             ; RAM
`NM44@X`:     golong  NAM44_

; * OFSHFT - turn off shiftset and shift annunciator
; * Requires chip 0 enabled on input
; * Destroys C
; * Uses one subroutine level
; * Returns via ENCP00
; *
OFSHFT:       c=regn  14
              rcr     1
              cstex                 ; get status set 1/2
              s4=     0             ; clear shiftset
              cstex
              rcr     13
              regn=c  14
              gosub   ENLCD
              readen
              cstex
              s7=     0             ; reset bit for shift annunciator
              cstex
              wrten
              golong  ENCP00


; ***************************************************
; * This routine sets all annunciators.
; * On entry, any data storage or peripheral chip may be enabled.
; * On exit, chip 0 is enabled, reg 14 is in C, and
; *     SS0 is in ST
; * Uses 0 subroutine levels.  Uses A.X
; ***************************************************

RSTANN:       gosub   RSTMS1
ANN_14:       regn=c  14            ; save reg 14
ANNOUT:       ldi     0x80          ; load low bat const
              acex    x
              asl     x
              c=0
              pfad=c
              dadd=c
              c=regn  14
              st=c                  ; bring up SS0
              ?s13=1                ; running?
              goc     SETPGM        ; yes. turn on PRGM annun
              ?s3=1                 ; PGM mode
              gonc    LOWBAT        ; no
SETPGM:       a=a+1   x
              a=a+1   x
LOWBAT:       ?s6=1                 ; low battery?
              goc     ALPHA         ; yes
              a=0     xs            ; clear low bat
ALPHA:        ?s7=1
              gonc    SHIFT_
              a=a+1
SHIFT_:       rcr     2
              st=c
              ?s0=1
              gonc    RAD_
              ldi     0x80
              a=a+c   x
RAD_:         ?s4=1
              goc     RADSET
GRAD_:        ?s5=1
              gonc    USER
              a=a+1   xs
              a=a+1   xs
RADSET:       a=a+1   xs
USER:         rcr     5
              st=c
              ?s0=1
              gonc    FLAGS
              a=a+1   xs
              a=a+1   xs
              a=a+1   xs
              a=a+1   xs
FLAGS:        rcr     5
              c=0     xs
              c=c+c
              rcr     1
              c=0     xs
              c=c+c
              c=c+c
              a=a+c
              ldi     0x10
              dadd=c
              ldi     0xfd
              pfad=c
              acex
              wrten
LDSST0:       c=0     x
              pfad=c
              dadd=c
              c=regn  14
              st=c
              rtn

XR_S:                               ; execute R/S
              rcr     6
              cstex                 ; put up SS3
              ?s1=1                 ; catalog flag?
              golc    R_SCAT        ; yes. goto catalog FCN.
              st=c                  ; retrieve SS0
              ?s3=1                 ; program mode?
              gonc    XRS20         ; no
XRS10:
              ldi     0x84          ; FC for stop
              golong  PARS56

XRS20:        ?s1=1                 ; pauseflag?
              goc     XRS10         ; yes
              gosub   PACH4         ; check for key down for about 100ms.

; *
; * If key is let up, go run. Otherwise put up description of step.
; * This is a patch to speed up execution of R/S.
; *
              ?s12=1                ; privacy?
              gonc    XRS25         ; no
              s8=     0             ; yes
              gosub   MSGA
              xdef    MSGPR         ; "PRIVATE"
              goto    XRS40

XRS25:        c=regn  15
              ?c#0    x             ; line number # 0?
              goc     XRS30         ; yes, non-zero
              c=c+1   x             ; zero. set to 1
              regn=c  15
XRS30:        gosub   DFKBCK        ; display next step
              ?s9=1                 ; keyboard reset yet?
XRS40:        gsubnc  NULTST        ; no
              .public XRS45
XRS45:        gosub   PRT8
              gosub   RSTANN

              .public RUN
RUN:                                ; get a user program running
              s13=    1             ; set running flag
              c=regn  15            ; set line # TO FFF
              c=0     x
              c=c-1   x
              regn=c  15
              c=regn  14
              st=c                  ; put up SS0
              c=c+c   xs
              c=c+c   xs            ; data entry flag?
              gonc    RUN11         ; no
                                    ; yes. must be pause
                                    ; termination
              gosub   PRT4          ; print dataentry string
              gosub   RSTMS1        ; clear msgflg, dataentry flag, etc.
RUN11:        s1=     0             ; clear pausing
              c=regn  14            ; put
              c=st                  ;  SS0
              regn=c  14            ;   back
; *
; * Logic for CLD enters at NWGOOS.
; * Entry condition: SS0 up
; *
              .public NWGOOS
NWGOOS:       gosub   PGMAON        ; turn on prgm annunciator
                                    ; & enable LCD
              ?s5=1                 ; MSGFLAG?
                                    ; MSGFLG can only be set
                                    ; here on pause termination
              goc     RUN20         ; yes
              gosub   CLLCDE
              ldi     0x2e          ; east goose
              srsabc
              gosub   ENCP00
RUN20:        golong  NFRPU         ; can't be a RTN because

; * XR/S is XKD and doesn't have NFRPU on the stack
; *
; * INTARG - zero the alpha reg and store the char in G as the
; *          first char.
; *
              .public INTARG
INTARG:       c=0     w
              regn=c  8
              regn=c  7
              regn=c  6
              c=g
              regn=c  5
              rtn

              .public STORFC
; *
; * STORFC - store function code to reg 10
; * On entry, desired FC is in C[3:0], left-justified in that field.
; * On exit, FC (4 digits) stored to reg 10[4:1]
; *     Reg 10[0] is scratch, A[4:0] and C are used, and PT=4.
; *
STORFC:       rcr     13
              pt=     4
              a=c     wpt
              c=regn  10
              acex    wpt
              regn=c  10
              rtn
; *
; * MESSL - left shift into lcd from right end
; * Calling sequence: gosub MESSL
; *                   .con  1st char, LCD form
; *                   .con  2nd char, ...
; *                   ...
; *                   .con  final char + @1000
; * Special characters (those having LCD CREG=1) can only be used
; * as the final character of the message.
; * Assumes LCD enabled on entry.
; * Uses C[6:0] and leaves LCD enabled on exit
; *
              .public MESSL
MESSL:        c=stk
MESS10:       cxisa
              slsabc
              c=c+1   m
              ?c#0    xs
              gonc    MESS10
              gotoc
; *
; * ENLCD - enable lcd driver chip
; * USES C.X ONLY
; *
              .public ENLCD
ENLCD:        ldi     0x10
              dadd=c                ; disable sleeper chips
              ldi     0xfd
              pfad=c                ; turn on LCD driver chip
              rtn
