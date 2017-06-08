;;; This is HP41 mainframe resurrected from list file output. QUAD 0
;;;
;;; REV.  6/81A
;;; Original file CN0B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @0-1777
; *

              .section QUAD0

#if defined(HP41CX)
#define PauseCounter 80
#define REG00        0x19c
#else
#define PauseCounter 92
#define REG00        0xef
#endif

;;; Entry points
              .public ADRFCH
              .public ALPDEF
              .public BCDBIN
              .public BIGBRC
              .public CLCTMG
              .public COLDST
              .public DROWSY
              .public DRSY05
              .public DRSY25
              .public DRSY51
              .public END2
              .public END3
              .public ERRNE
              .public ERROF
              .public GOTINT
              .public GTAI40
              .public GTAINC
              .public INCGT2
              .public INTINT
              .public MSGDLY
              .public NFRC
              .public NFRENT
              .public NFRFST
              .public NFRKB
              .public NFRKB1
              .public NFRNC
              .public NFRNIO
              .public NFRPR
              .public NFRPU
              .public NFRSIG
              .public NFRX
              .public NFRXY
              .public QUTCAT
              .public RUNNK
              .public STMSGF
              .public TONSTF
              .public WKUP70
              .public XAVIEW
              .public XCUTB1
              .public XCUTE
              .public XCUTEB
              .public XNNROW
              .public XROW1
              .public XVIEW

              legal

              golnc   LSWKUP

              golong  DSWKUP

; **************************************************
; * The following routine takes a binary register
; * number from status and returns that register
; * in C, its address in N, and X in M. It sends
; * illegal addresses to error "NONEXISTENT."
; * It also handles indirect address. Cycle times
; * average about 30 for direct and 60 for indirect
; * USES: A,B,C,M,N,ACTIVE POINTER, S9,S8,S7, DADD, + 2 sub levels
; * may exit to ERRNE
; * IN: ADDR IN S7:0 (may be indirect)
; *     no peripheral enabled
; * OUT: C = C(effective addr)
; *      N = effective addr
; *      DADD = effective addr
; *      M = X register contents
; *      S7 = 0
; **************************************************

ADRFCH:       c=0                   ; get X
              dadd=c
              c=regn  3
              m=c                   ; X is stored in M
              c=st                  ; get address from status
              c=0     xs            ; clear 9 from XS
              s7=     0             ; kill indirect flag
              cstex                 ; put original status back
              ?s6=1                 ; stack rcl?
              gonc    OVRSTK        ; no
              ?s5=1
              gonc    OVRSTK        ; no
              ?s4=1
              gonc    OVRSTK        ; no
              pt=     1             ; set to clear high bits
              c=0     pt            ; clear high bits
              dadd=c                ; put out address
              n=c                   ; save address in N
              c=data                ; get register
              goto    FCHRTN        ; done
OVRSTK:       acex                  ; save relative address
              c=regn  13            ; set status register
              rcr     3             ; move REG0 to position
              c=c+a   x             ; compute adr of reg
              n=c                   ; save adr for calng routn
              gosub   CHKADR        ; check adr, val rtns in B

              c=b                   ; bring rcl value to C
FCHRTN:       ?s7=1                 ; indirect
              rtn nc                ; done if not indirect
              gosub   BCDBIN        ; do BCD BIN

              s7=     0             ; clear indirect flag
              goto    OVRSTK        ; new adr start over

              .fillto 0x26

; ******************************************************
; * This routine is a special "ROW" for X<>NN
; ******************************************************

XNNROW:       c=c-1   xs            ; restore byte 1
              c=c-1   xs
              legal
              gosub   INCGT2

              acex
              st=c
              rcr     13
              g=c
              goto    ADRGSB

XROW0:        golong  ROW0
XROW10:       golong  ROW10
XROW11:       golong  ROW11
XROW12:       golong  ROW12
XROW13:       golong  XGTO
XROW14:       golong  XXEQ

; ********************************************************
; * One-byte store and recall functions enter here to
; * be transmographied into two-byte functions
; ********************************************************
XROW2:
XROW3:
              c=c-1   pt            ; high digit -2
              c=c-1   pt
              csr     x             ; create byte two
              csr     wpt           ; create byte 1
              lc      9
              pt=     3
              goto    REGADR

; ********************************************************
; * Two-byte RCLS, STOS, DSP format etc comprise row 9
; * XROW9 gets byte two, fetches X (in M), fetches
; * register NN (in B), and leaves the address of NN
; * in N for all data related functions (0-11). It then
; * does a sixteen-way branch to sort out the row.
; ********************************************************

XROW9:        gosub   INCGT2        ; get byte two
              acex                  ; bring back to C
REGADR:       st=c                  ; save byte 2
              rcr     13            ; move to G position
              g=c                   ; save in G
              c=c+c   pt            ; sep out 0-7
              gonc    ADRGSB        ; do rcl etc
              c=c+c   pt            ; sep out dsp & tone
              goc     TONETC
ADRGSB:       gosub   ADRFCH        ; get X,RNN, and ADR

              bcex                  ; save value in RNN
BIGBRC:       pt=     12            ; set for G load
              c=g                   ; get byte one back
              pt=     3
              golong  XCUTB1        ; do 256-way branch

; *******************************************************
; * This section sorts out indirect TONE, FIX, ENG, and
; * SCI from direct. If indirect, goes through address
; * fetch otherwise goes immediately to 256-way branch.
; *******************************************************

TONSTF:       ?s7=1                 ; indirect
              rtn nc                ; no do branch
              s7=     0             ; clear indirect bit
              gosub   ADRFCH        ; get reg

              gosub   BCDBIN        ; convert to binary

              st=c                  ; save binary status
              ?s8=1                 ; more than one digit
              rtn nc                ; 256-way branch
              golong  ERRDE         ; yes then DATA ERROR

              .fillto 0x60

ROWTBL:       goto    XROW0         ; ROWTBL must be at @140
              goto    XROW1         ; other logic makes use of
              goto    XROW2         ; the fact that rowtbl is in
              goto    XROW3         ; the first 256 words of chip 0
              goto    XROW4         ; and on an even boundary of
              goto    XROW5         ; 16 words.
              goto    XROW6         ;
              goto    XCUTEB        ; row 7
              goto    XCUTEB        ; row 8
              goto    XROW9
              goto    XROW10
              goto    XROW11
              goto    XROW12
              goto    XROW13
              goto    XROW14
              golong  TEXT          ; row 15

TONETC:       gosub   TONSTF

              goto    BIGBRC

XROW1:        a=c                   ; save FC in A
              pt=     2
              lc      13            ; split off digit entry
              ?a<c    xs
              golc    DERUN         ; digit entry

                                    ; NOTE - We go to derun with
                                    ; the FC in A[3:2] and the
                                    ; ptr at 1.
              gosub   GTAINC        ; get alpha operand

              acex
              a=c
                                    ; must go to XCUTEB with
                                    ; FC back in C[3:2] and PT=3
              goto    XCUTEB
ROW7:         clr st                ; for ISG DSE comp mesg
              goto    XCUTEB

XROW5:
XROW6:        n=c
              c=c+c   m
              stk=c                 ; puts address of NFRX on stack
              setdec
              goto    MATH
XROW4:        cnex
              c=regn  2
              a=c
              gosub   CHK_NO_S

MATH:         c=regn  3
              gosub   CHK_NO_S2

              clr st
              cnex
; * (Fall into xcuteb here)
; *
; * XCUTEB - execute, part B
; * INPUT CONDITIONS: FC in C[3:2], PT=3, assumes nonprogrammable
; *     XCUTB1 assumes FC in C[13:12]
; *
XCUTEB:       rcr     4
XCUTB1:       ldi     0x14          ; @12000\256 main FCN table
              rcr     9
              cxisa
              lc      1
              rcr     11
              gotoc
; *
; *
; *
; * RSTKB - Reset and debounce keyboard
; * USES C.X
; * Waits 5 millisec after first seeing key reset before
; * allowing a second key to be sensed.
; *
; * Wait loop is 4 words long.
; * 5 MILLISEC/ 4*155 MICROSEC = 8
; *
; * RST05 entry point is for debounce only
; *
              .public RSTKB
              .public RST05
RSTKB:        rst kb
              chk kb
              goc     RSTKB
RST05:        ldi     8
RST10:        rst kb
              chk kb
              c=c-1   x
              gonc    RST10
              rtn

              .fillto 0xa2
ERROF:        gosub   ERROR         ; overflow treated as error
              xdef    MSGOF
NFRNC:                              ; !!    assumes chip 0 on
              gosub   OVFL10        ; fill X and Y from N and C

              cnex                  ; get Y, save X.
              ?pt=    10
              goc     XBAD          ; go if X overflowed
              gosub   OVFL10

              ?pt=    10
              goc     YBAD          ; go if Y overflowed
FILLY:        regn=c  2             ; fill in Y value
              cnex                  ; get X out of storage
              bcex                  ; put X in 9. goto fill X and LastX
              goto    FILLXL
XBAD:         gosub   OVFL10        ; still need to convert Y to 9 if neg

YBAD:         acex                  ; save Y value while get flags
              c=regn  14
              rcr     6             ; get error and overflow flags for status
              st=c
              acex                  ; put Y back into C
              ?s7=1                 ; overflow flag set?
              goc     FILLY         ; if so fill Y and go to FILLXL
              .public ERRIGN
ERRIGN:       ?s6=1                 ; error flag set?
              gonc    ERROF         ; if not goto error: OVERFLOW
              s6=     0             ; turn off error flag
              c=st
              rcr     8
              regn=c  14
              goto    NFRC          ; no print, leave push alone
; *
; * NFRSIG is used by SIGMA+, SIGMA-, CLX, and CLST.
; * NFRENT is used by ENTER.
NFRSIG:       gosub   PRT1
NFRENT:       s11=    0             ; clear pushflag
              goto    NFRC

NFRKB1:       ?s9=1                 ; key already reset?
NFRKB:        gsubnc  RSTKB

              goto    NFRC

              .fillto 0xca
              goto    NFRX          ; must be 0xca for row 5
              nop
NFRX:                               ; !! assumes chip 0 on
              gosub   OVFL10        ; must be 0xcc for row 6

              bcex                  ; save X in B
              ?pt=    10
              gonc    FILLXL
              c=regn  14
              rcr     6
              st=c
              ?s7=1                 ; overflow flag?
              gonc    ERRIGN
              goto    FILLXL
; *
; * Fill thru @331 - gets spacing right so that NFRPU ends up
; * at @360 and there are no inline NOPs
; * PCTOC - program counter to C
; * This little subroutine simply copies the address of the rom word
; *- after the calling gosub into C and returns. It is intended to
; *- facilitate the writing of routines in plug-in roms for such things
; *- as calling another rom chip or for other routines requiring
; *- knowledge of the current absolute address of the ROM.
; *
; hth313: This routine was not exported with a .public in the
;         original source, so I added that. 17/May/2017
              .public PCTOC
PCTOC:        c=stk
              stk=c                 ; hth313: this could just be gotoc
              rtn

              .fillto 0xda
NFRXY:                              ; !!    assumes chip 0 on
              gosub   OVFL10

              bcex                  ; save X in B
              ?pt=    10
              gonc    DROPST        ; if no overflow go drop stack
              c=regn  14
              rcr     6
              st=c
              ?s7=1                 ; overflow flag?
              gonc    ERRIGN        ; if not set go check error flag
              .public DROPST
DROPST:       c=regn  1             ; get Z
              regn=c  2             ; put into Y
              c=0
              dadd=c
              c=data                ; get T
              regn=c  1             ; put into Z

              .public FILLXL
FILLXL:       c=regn  3             ; get old X
              regn=c  4             ; fill LastX
              bcex                  ; get new X from B
              regn=c  3             ; fill X
NFRPR:        gosub   PRT1

              .fillto 0xf0          ; 0x00F0 is put on the stack
                                    ; at RUNNK - NFRPU must be
                                    ; at 0x00F0
NFRPU:        s11=    1             ; set push
NFRC:         sethex
              sel p
              c=0                   ; re-enable chip 0
              dadd=c
              c=regn  14
              st=c
NFRFST:
              ?lld                  ; test low battery
              gonc    LOWBRT
              ?s6=1                 ; lowbat?
              goc     LOWBRT        ; yes
              s6=     1             ; set lowbat
              gosub   STOST0        ; store status set 0

              gosub   ANNOUT        ; turn on bat annunciator

LOWBRT:                             ; low battery logic return to main flow

              ?f13=1                ; does a peripheral want
                                    ; service?
              goc     IOSERV        ; yes
              ?s2=1                 ; I/O flag?
              gonc    NFRNIO        ; no
IOSERV:       gosub   IORUN         ; yes


NFRNIO:                             ; normal function return, no I/O
              ?s13=1                ; running?
              gonc    DRWSYL        ; no
                                    ; !!! check sstflag here?

              .public RUNING        ; nulls re-enter here
RUNING:                             ; running
              chk kb
              gonc    RUNNK
              c=keys
              rcr     3
              c=0     xs
              a=c     x             ; keycode to A.X
              ldi     0x18          ; hex 18 = off key
              ?a#c    x
              golnc   OFF

              ldi     0x87          ; hex 87 = R/S key
              ?a#c    x
              goc     IGNKEY        ; not runstop
              gosub   RSTSEQ        ; stop the program

              golong  NFRKB


IGNKEY:       rst kb                ; try to reset keyboard
              chk kb

RUNNK:                              ; running, no key hit
              pt=     4             ; put NFRPU on the
              c=0     m             ; subroutine stack
              lc      15            ; here
              stk=c                 ; NFRPU assumed = @360
; *
; * NXTBYT - next byte
; * - Increments PGMCTR in place
; * - Places byte pointed to by new value of PGMCTR in C[13:12]
; * - for ram only, S8=1 if byte num = 0 otherwise S8=0.
; *   If S8=0 then C[11:10] contains the next byte in program memory.
; * - For ROM, S8 is left undefined, and only the first byte is
; *   brought into C.
; * - Assumes chip 0 selected and PT=3, leaves PT=3, uses C.
; *
              c=regn  12            ; PGMCTR to C[3:0]
              ?s10=1                ; ROM flag?
              goc     NEXROM        ; yes
              s8=     0
              c=c-1   pt            ; decrement byte number
              goc     NXTBT1        ; byte 6 desired
              regn=c  12            ; replace PGMCTR
              dadd=c                ; turn on the right sleeper chip
              rcr     4             ; byte number to C.S
              ldi     0x14          ; TBLGBR\16=@0500\16
              rcr     10
              gotoc

NXTBT1:       lc      6             ; desired byte is byte #6
              c=c-1   x
              regn=c  12
              pt=     3
              dadd=c
              c=data
              goto    NXBEND

NEXROM:       c=c+1                 ; increment PGMCTR
              regn=c  12            ; put PGMCTR back
              rcr     11
              cxisa                 ; new byte to C.X
              goto    NXROM1

DRWSYL:       goto    DROWSY
; *
; *
; * STOST0 - store status set 0 back to register 14
; * ENTRY REQUIREMENTS: chip 0 enabled, status set 0 in status bits
; * DESTROYS C (leaves a copy of register 14 in C)
; *
              .public STOST0
STOST0:       c=regn  14
              c=st
              regn=c  14
              rtn

              .fillto 0x140

TBLGBR:                             ; table for get byte rotate
                                    ; must be on 16-byte word boundary
              goto    GBYTR0        ; new byte num = 0
              goto    GBYTR1
              goto    GBYTR2
              goto    GBYTR3
              goto    GBYTR4
GBYTR5:       c=data                ; NOTE no byte 6 this path
              rcr     12
              goto    NXBEND
GBYTR4:       c=data
              rcr     10
              goto    NXBEND
GBYTR3:       c=data
              rcr     8
              goto    NXBEND
GBYTR2:       c=data
              rcr     6
              goto    NXBEND
GBYTR1:       c=data
              rcr     4
              goto    NXBEND
GBYTR0:       c=data
              s8=     1
NXROM1:       rcr     2
NXBEND:                             ; end of next byte
              ?s0=1                 ; is a printer connected?
              gonc    NOPRT         ; no
              gosub   PRT2          ; in TRACE mode, print
                                    ; next instruction

              .public NOPRT         ; for the printer
NOPRT:

; *
; * XCUTE - execute
; * - Decodes and sends to execution the byte found in
; *   C[13:12].  If S8=0 then C[11:10] contains the
; *   next byte.
; * - ON INPUT: HEXMODE, PTR P = 3, status set 0 up and valid
; * - selects ram chip 0.
; *
XCUTE:        ldi     6             ; ROWTBL\16
                                    ; ROWTBL must be in 1st 256 bytes of ROM
              dadd=c                ; select RAM 0
              rcr     10
              gotoc


; * DROWSY - refresh display and try to sleep
; *
DROWSY:       s9=     1             ; keyboard already reset
DRSY05:       gosub   ANNOUT        ; refresh annunciators

              ?s5=1                 ; MSGFLG?
              goc     DRSY25        ; yes
              ?s3=1                 ; PRGMMODE?
              gonc    DRSY10        ; no
              gosub   DFRST8        ; DFILLF with scroll & no prompt

              goto    DRSY25
DRSY10:       ?s7=1                 ; ALPHAMODE?
              gonc    DRSY20        ; no
              s8=     0             ; scroll & no prompt
              gosub   ARGOUT

              goto    DRSY25
DRSY20:       c=regn  3             ; get X
              gosub   DSPCRG        ; display contents of C reg

DRSY25:
; * SST (prgmmode only) and bst (prgmmode & normal mode) enter
; * at DRSY25 to bypass both main lcd update and annunciator
; * update.  Entry conditions are the same as for DRSY51.
              ?s9=1                 ; keyboard reset yet?
              goc     DRSY30        ; yes
              ldi     81            ; delay 25 millisec
                                    ; for debounce
DRSY26:       c=c-1   x
              gonc    DRSY26
              gosub   RSTKB


; * Entry point added for HP-41CX
              .public DRSY30
DRSY30:       s4=     0             ; clear SSTFLAG
              gosub   STOST0

              ?s1=1                 ; pausing?
              goc     PAUSLP        ; yes
; *
; * Light sleep wakeup logic
; *
              .public LSWKUP
LSWKUP:       gosub   0x4000        ; gosub diagnostic

              gosub   PACH11        ; leaves SS0 up

                                    ; PACH11 goes to MEMCHK
              .public WKUP10        ; parse PKSEQ enters here
WKUP10:       chk kb
              goc     WKUP20
              ldi     8             ; I/O service
              gosub   ROMCHK        ; needs chip 0,SS0,hex,P selected

              ?s2=1                 ; I/O flag?
              goc     WKUP10        ; yes
                                    ; going to light sleep now
              c=regn  14
              rcr     2
              st=c                  ; put up SS1
              ?s3=1                 ; stayon?
              .public DRSY50
DRSY50:                             ; off enters here with
                                    ; display turned off
              gsubnc  ENLCD         ; no

              powoff



DRSY51:                             ; this entry used to bypass
                                    ; default display logic
                                    ; ENTRY REQ: hex, chip 0 on,
                                    ; S9 sys whether KB has
                                    ; been reset, SS0 up,
                                    ; P sel.
              gosub   ANNOUT
              goto    DRSY25

; *
; * pause loop
; *

PAUSLP:       gosub   PGMAON        ; turn on prgm annunciator
              ldi     PauseCounter  ; initialize pausetimer
              a=c     x             ; A.X=pausetimer
; * Pausetimer set empirically to match hp67 on a benchmark PGM
; * consisting of 100 pse's followed by fix 9, stop.
; * This timing was subsequently screwed up by extending ROMCHK's
; * search from addresses 6-F down to 5-F.  HP-41C's PSE is now
; * .1-.2 sec longer than HP-67's.  DRC 10/20/79
; * Changed to use a #define instead, as the HP-41CX extends it
; * into page 3 as well.  hth313 5/Jun/2017
PAUS10:       chk kb                ; is a key down?
              goc     WKUP20        ; yes
              ldi     12
              gosub   RMCK05
              a=a-1   x             ; has pause expired?
              gonc    PAUS10        ; no, not yet
              golong  RUN           ; yep

WKUP20:       c=keys
              .public WKUP21        ; add for ADV I/O on 6/15/81
WKUP21:       pt=     3
              c=c+c   pt            ; OFF key? (OFF KC=18HEX)
              golnc   PARSE         ; no
OFFXFR:       golong  OFF           ; yes

; *
; * Deep sleep wakeup logic.
; *
              .public DSWKUP        ; wake up from deep sleep
DSWKUP:       gosub   0x4000        ; GOSUB diagnostic
                                    ; chip 4

; * On wakeup from deep sleep, the display may be either off (in the
; * case where the user or a program turned the calculator off
; * explicitly) or on (in the case where the calculator went from
; * light sleep to deep sleep automatically).
              disoff                ; get the display to a known
                                    ; state
              gosub   PACH11        ; PACH11 goes to MEMCHK

              chk kb                ; did the on key wake us up?
              goc     WKUP25        ; yes
              ldi     10            ; no
              gosub   ROMCHK

              ?s2=1                 ; I/O flag?
              gonc    DRSY50        ; nope - go back to sleep
              .public WKUP25
WKUP25:
                                    ; initialize status bits
              c=regn  14
              gosub   PACH12        ; decompiles & returns with R14 in C,
                                    ; SS0 up(S0-S7=0), C.X= 0
              rcr     6
              cstex                 ; put up SS3
              s1=     0             ; clear catalog flag
              s5=     1             ; set audio enable flag
              s6=     0             ; clear error ignore flag
              s7=     0             ; clear out-of-range flag
              cstex
              rcr     2             ; clear flags 12-23
              c=0     x
              rcr     6
              regn=c  14
              s13=    0             ; clear running flag
              gosub   RSTKB
; * Check for master clear here
; * The protocol for master clear is to press and hold the
; * backarrow key while simultaneously hitting the ON key.
; * This sequence was moved ahead of the I/O buffer check
; * to allow the user to recover from an infinite loop
; * (733-752) by using master clear 12/21/81 WCW
              chk kb                ; another key down?
              gonc    WKUP60        ; no
              ldi     0xc3          ; yes. see if it is BKARROW (KC FOR BKARROW)
              a=c     x
              c=keys
              rcr     3
              pt=     1
              ?a#c    wpt
              gonc    WKUP90        ; master clear
WKUP60:                             ; release all I/O buffers
              c=regn  13
              bcex                  ; chainhead to B.X
              ldi     191
              a=c                   ; current reg addr to A.X
WKUP30:       a=a+1   x
WKUP40:       ?a<b    x             ; still below chainhead?
              gonc    WKUP50        ; no - done.
              c=a     x

              dadd=c
              c=data
              ?c#0    w             ; is this reg occupied?
              gonc    WKUP50        ; no - done.
              c=c+1   s             ; is it a key reassignment?
              goc     WKUP30        ; yes
              c=0     s             ; no. must be an I/O buffer
              data=c                ; release it
              rcr     10            ; rotate size to C[1:0]
              c=0     xs
              a=a+c   x             ; skip over buffer
              legal
              goto    WKUP40

WKUP50:       ldi     7             ; deep sleep
              dadd=c                ; re-enable chip 0
              gosub   ROMCHK
              gosub   PKIOAS        ; gosub I/O area pack subr.
                                    ; returns with chip 0 disabled
              c=0                   ; re-enable chip 0
              dadd=c
              distog                ; turn the display back on
WKUP70:       c=regn  14
              rcr     11
              st=c
              ?s0=1                 ; flag 11?
              golnc   NFRC          ; no
                                    ; goto NFRC to initialize
                                    ; lowbat before going to
                                    ; DROWSY
              s0=     0             ; yes. clear flag 11
              c=st
              rcr     3
              regn=c  14
              .public WKUP80        ; for card reader load&go
WKUP80:       disoff                ; turn off display during beep
              gosub   TONE7X

              distog                ; turn display back on
              golong  RUN           ;start running the user's PGM

; *
; * MEMCHK (memory check) - Check integrity of ROM and RAM
; *
; * MEMCHK performs three quick tests of RAM and ROM in an
; * effort to determine whether any plug-in modules or the
; * batteries have been removed.
; *
; * 1. Test digits 6:0 of reg 13 to see whether the warm start
; * constant (@551) is there. if not, cold start.
; * 2. Read/write/read/restore REG0-1 to judge whether the label
; * chain is intact, if not, cold start.
; * 3. If the user PC is on ROM, verify that the first word of the
; * rom chip is non-zero to judge whether the ROM module is still
; * plugged in.  if not, set the pc to the top of program memory in
; * RAM. (see CHKRPC comments below)
; *
; * ON EXIT, chip 0 is enabled, SS0 is up, hexmode.
; * USES A and C.
; * Doesn't call any subroutines (must not, because MEMCHK is called
; * during partial key sequences). Exits via PUTPCX.
; * If PC is in RAM, normally returns in 31 word-times.
; * If PC is in ROM, normally returns in 39 word-times.
; *
              .public MEMCHK
MEMCHK:       rst kb                ; these three states
              chk kb                ; necessary because of
              sethex                ; problems with CPU wakeup
              c=0     x
              pfad=c                ; turn off peripheral chips
              dadd=c                ; turn on chip 0
              ldi     0x169         ; warm start constant
              a=c     x
              c=regn  13
; ************************************************************************
; * WKUP90 added 12/22/81 to provide a means for the relocated backarrow
; * test gonc (724) to reach COLDST (1062).  Since the jump at 1021 is a
; * goc, the master clear sequence jumps in at WKUP90. The rcr 6  in-
; * sures the the contents of C are not equal to A.  The X field of C
; * will be X00 following the rcr.  The 00 remains from 705.
; ************************************************************************
WKUP90:       rcr     6
              ?a#c    x             ; cold start?
              goc     COLDST        ; yes
                                    ; now hexmode is assumed
              rcr     11            ; REG0 to C.X
              c=c-1   x             ; C.X=REG0-1
              dadd=c
              c=data                ; get C(REG0-1)
              a=c                   ;& save in A
              c=-c-1  m

; * We invert the bit pattern in digits 12:3.  Characteristically,
; * when a nonexistent data storage register is read, the data
; * is either all ones or all zeroes.  Inverting part of the register
; * guarantees that, if the register exists, either what we read
; * originally or the partially inverted pattern will be different
; * from all zeroes and from all ones.
              data=c                ; write it back
              c=data                ; read it again
              c=-c-1  m             ; invert it again
              ?a#c                  ; nonexistent register?
              goc     COLDST        ; yes
              data=c                ; restore the register

              c=0     x             ; re-enable chip 0
              dadd=c
              c=regn  14            ; put up SS0
              st=c

; * CHKRPC (check ROM PC) - confirms that, if ROMFLAG is set, the
; * ROM chip pointed to by the user PC is actually plugged in.
; *
; * On entry, chip 0 must be enabled.
; * If ROMFLAG is clear, returns in 2 word-times and uses nothing.
; * If ROMFLAG is set, uses A[3:0] and C and PT and usually returns
; * in 8 word-times
; *
              .public CHKRPC
CHKRPC:       ?s10=1                ; ROM flag?
              rtn nc                ; no. all finished.
              c=regn  12            ; GET PC
              c=0     x             ; C[3:0]=addr of 1st word
              rcr     11            ; on chip
              cxisa
              ?c#0    x
              rtn c
              s10=    0             ; chip is not there
              c=regn  13
              rcr     3             ; C.X=reg0
              pt=     3
              c=0     pt
              a=c     wpt
              golong  PUTPCX

; *
; * COLD START INITIALIZATION
; *
COLDST:       sethex
              clrabc
              m=c
              n=c
              g=c
              st=c
              f=sb
              stk=c
              stk=c
              stk=c
              stk=c
              sel q
              pt=     13
              sel p
              s13=    0
              s12=    0
              s11=    0
              s10=    0
              s9=     0
              s8=     0
              gosub   MSGA
              xdef    MSGML         ; "MEMORY LOST" message
; * Is the lcd enable in the next line really necessary?
              gosub   ENLCD
              gosub   RSTKB
              ldi     0x3ff         ; set up A.X for ILOOP
; * I think this constant could just as well be @777, which would
; * result in faster cold starts, but for now i'm leaving well enough
; * alone.  DRC 3/26/79
              a=c
              c=0
              wrten                 ; clear annunciators
              disoff
              distog
              pfad=c
ILOOP:        acex
              dadd=c
              acex
              data=c
              a=a-1   x
              gonc    ILOOP

              ldi     REG00         ; initialize reg0 (OEF or 19C)
              rcr     8
              ldi     REG00 + 11    ; initialize SIGMADDR (0FA or 1A7)
              rcr     3
              ldi     REG00 - 1     ; initialize chain head (0EE or 19B)
              regn=c  13
              c=0     m
              c=c+1
              regn=c  12            ; PGMPTR (00EF)
              dadd=c                ; put permanent end at chainhead
              c=0                   ; location
              pt=     5
              lc      12
              ldi     32
              regn=c  (REG00 - 1) & 15
              c=0                   ; initialize status bits
              dadd=c
              pt=     7
              lc      2             ; turn on audio enable
              lc      12            ; set digit grouping & DP flags
              pt=     4
              lc      4             ; #digits_4
              lc      8             ; set fixflag
              regn=c  14            ; store status sets except SS0
              s5=     1             ; set MSGFLG
; * ROMCHK assumes SS0 is up, clears S2 (IOFLAG), and stores SS0
; * back to reg 14
              ldi     6             ; cold start
              gosub   ROMCHK
              ldi     0x169         ; warm start constant
              a=c     x
              c=regn  13
              rcr     6
              acex    x
              rcr     8
              regn=c  13
              golong  WKUP70


; * INCGT2 - increment PGMCTR and validate byte#2
; * INPUT: C as left by row decode (FC in digits 3:2, 2nd byte
; *     may be in digits 1:0).  PT=3. Status set 0 up.
; * USES A and C
; * Returns with valid bytes in A[3:0], PT=3, status set 0 up.
; * Leaves S8 alone
; *
INCGT2:       a=c                   ; save first byte in A[3:2]
              ?s13=1                ; running?
              goc     INCG1         ; yes
              ?s4=1                 ; SSTFLAG?
              rtn nc                ; keyboard - do nothing.

INCG1:        c=regn  12            ; get PGMCTR
              ?s10=1                ; ROMFLAG?
              gonc    INCG2         ; RAM
              c=c+1                 ; ROM
              regn=c  12            ; put PGMPTR back
              rcr     11
              cxisa
              acex    xs            ; put the two bytes together
              a=c     x
              rtn

INCG2:        ?s8=1                 ; is byte 2 bad?
              gonc    INCG3         ; byte 2 is good
              lc      6             ; increment PGMCTR across A
              c=c-1   X             ; register boundary
              regn=c  12            ; put PGMCTR back
              dadd=c                ; get second byte
              c=data
              rcr     12
              pt=     1
              a=c     wpt
              pt=     3             ; restore pointer
              c=0
              dadd=c                ; re-enable status chip
              rtn

INCG3:        c=c-1   pt            ; increment PGMCTR
              regn=c  12            ; put PGMCTR back
              rtn


; **********************************************************
; * ROW10 includes flags, EXEC ROM, non-programmable
; * functions and execute indirect. Flags are the only
; * functions in ROW10 which can be preprocessed. In the
; * ROW 10 routine error checking is done and a mask
; * is built with a one in the position of the flag
; * of interest.
; **********************************************************
ROW10:        gosub   INCGT2        ; get byte 2
              acex
              st=c                  ; save byte 2
              pt=     2
              g=c
              .public P10RTN
P10RTN:       c=c+c   xs            ; SEP XEC ROM
              golnc   XROM

              s9=     0             ; test only flag set
              c=c+c   xs            ; SEP set and clears
              gonc    FLAGS
              s9=     1             ; these 2 test onlys
              c=c+c   xs
              gonc    FLAGS
              c=c+c   xs            ; spare FC?
              rtn     c             ; yes
              golong  BIGBRC        ; XEQ/GTO indirect

FLAGS:        c=0     xs            ; clear for error checks
              ?s7=1                 ; indirect flag?
              gonc    CONFLG        ; no
              s7=     0             ; do indirect access
              gosub   ADRFCH
              golong  PACH10

CONFLG:       acex                  ; move binary flag number to A
              b=a                   ; save N in B
              ldi     30            ; load decimal 30
              a=a-c   x             ; check to see if setclr flag
              goc     ALLOK         ; yes then all OPs OK
              ?s9=1                 ; test only flag?
              gonc    ERRNE         ; no this one set or clears
              ldi     26            ; subtract balance of flags
              a=a-c   X             ; if NC NN>55
              gonc    ERRNE
; *
; * The entry point "ALLOK" was added by Steve Chou on 02-11-81
; * for the function "STOFLAG" in the Advanced Programming ROM
; * (hth313: This was renamed Extended Functions module.)
; *
              .public ALLOK
ALLOK:        abex                  ; no errors at this point
              ldi     8             ; count down by 8s
              bcex
              c=0                   ; set C=1 and address chip 0
              dadd=c
              c=c+1
SHF8:         rcr     2             ; shift one right 8 at a time
              a=a-b   X             ; count n down
              gonc    SHF8
              goto    PSTDBL
DBL:          c=c+c                 ; shift back by carry amount
PSTDBL:       a=a+1   x             ; count back carry
              gonc    DBL
              bcex                  ; save mask
              c=regn  14            ; get status set
              acex                  ; save in A
              golong  BIGBRC        ; do 256-way branch
ERRNE:        gosub   ERROR
              xdef    MSGNE         ; "NONEXISTENT"
; *************************************************
; * This routine takes a standard floating point
; * number, strips off an absolute integer less than
; * 1000, and converts that integer to binary.
; * If the floating point input is a fraction zero
; * is returned, if larger than 999 a NONEXISTENT
; * error is generated. Input is in C, output is
; * in C.X, character data also generates error.
; * USES: A.X, C, S8, and 1 additional subroutine level
; * IN: C=floating point number
; *     no peripheral enabled
; * OUT: C.X = binary number
; *      chip 0 enabled
; * may exit to ERRAD or ERRNE
; *************************************************
BCDBIN:       c=c-1   S             ; check for character
              c=c-1   S
              golc    ERRAD
              a=c     x             ; move exponent
              c=0     s
              s8=     0             ; clear zero to 9 flag
              c=0     x
              dadd=c
              ?a#0    xs            ; negative exponent?
              rtn c                 ; yes we are done
              rcr     12            ; move digit 1 to 0
              a=a-1   x             ; decrement exponent
              goc     GOTINT        ; done if X=0
              s8=     1             ; set flags for 10 or larger
              rcr     13            ; rotate next digit in
              a=a-1   X             ; exp=1?
              goc     GOTINT        ; yes
              rcr     13            ; shift again
              a=a-1   x             ; X=2
              gonc    ERRNE         ; value too large for adr

; *******************************************************
; * The following routine takes a BCD integer in C.X
; * (3 digits) and converts it to binary in C.X
; *
; * IN: C.X= bcd number,   C[4:3]= 00
; * ASSUME: hexmode
; * OUT: C.X= binary number.   hexmode
; * USES: A.X, C, +1 sub level       (no ST, no PT, no DADD)
; *******************************************************
GOTINT:       rcr     2             ; get first digit
              gosub   INTINT
INTINT:       c=c+c   x             ; multiply by 10
              a=c     x
              c=c+c   x
              c=c+c   x
              a=a+c   x
              c=0     x
              rcr     13            ; shift in next digit
              c=c+a   x             ; combine 10s
              rtn

; *
; *  GTAINC - get alpha label and increment program
; *           counter
; *- Get an alpha label from various locations depending
; *- on the mode of operation, and format the alpha
; *- label appropriately
; *- IN:  S9=1 implies an address is returned in M
; *-      A[3:2]= function code
; *-      chip 0 selected
; *- OUT: M[13:0]= alpha label (right-justified)
; *-       or alpha label address
; *       PC set at last byte of alpha label
; *- USES: A[13:0], B[13:0], C[13:0], M[13:0]
; *- USES: 1 subroutine level

GTAINC:       pt=     3             ; -
              b=a                   ; copy FC from A[3:2]
              c=b                   ; to B[3:2] and C[3:2]
              ?s13=1                ; running?
              goc     GTAI10        ; yes
              ?s4=1                 ; SSTFLAG?
              goc     GTAI10        ; yes
              c=regn  9             ; M_ALPHA string (KYBRD)
              ?s9=1                 ; ADDR in M?
              goc     1$            ; yes
              m=c                   ; -
1$:           rtn                   ; -
GTAI10:       ?s10=1                ; ROM?
              gonc    GTAI40        ; nope
              c=regn  12            ; B[6:3]_PGMCTR    (ROM)
              rcr     11            ; -
              c=c+1   m             ; -
              bcex                  ; C[3:2]_F.C.
              c=c+c   pt            ; ALBL?
              goc     GTAI22        ; yes
              c=b                   ; XEQ/GTO F.C.
              cxisa                 ; string operand ADDR?
GTAI26:       b=a                   ; save F.C. & K.C.
              a=c     m             ; A[6:3]_PGMCTR
              rcr     1             ; A[13]_#CHARS
              c=c-1   s             ; -
              a=c     s             ; -
              c=0                   ; -
              pt=     1             ; -
GTAI30:       acex                  ; get a char
              c=c+1   m             ; -
              cxisa                 ; -
              acex                  ; -
              acex    wpt           ; -
              rcr     2             ; position char
              a=a-1   s             ; chars finished?
              gonc    GTAI30        ; nope
              goto    1$            ; -
2$:           rcr     2             ; -
1$:           ?c#0    wpt           ; -
              gonc    2$            ; -
              m=c                   ; M_ALPHA string
              acex                  ; A[3:0]_F.C. & K.C.
              abex                  ; -
              pt=     3             ; -
              goto    GTAI20        ; B[3:0]_PGMCTR
GTAI22:       c=b                   ; position PGMCTR
              c=c+1   m             ; -
              cxisa                 ; -
              rcr     1             ; -
              c=0     x             ; -
              rcr     10            ; -
              abex                  ; -
              c=a+c   m             ; -
              c=c+1   m             ; -
GTAI20:       rcr     3             ; place PGMCTR
              bcex    wpt           ; -
              c=regn  12            ; -
              c=b     wpt           ; -
              regn=c  12            ; -
              rtn                   ; -

GTAI40:       s9=     0             ; -
              c=c+c   pt            ; ALBL?
              gonc    GTAI50        ; nope
              gsblng  GETPCA        ; increment
              gsblng  INCADA        ; -
              goto    GTAI55        ; -
GTAI50:       gsblng  GETPCA        ; A[13]_#CHARS
GTAI55:       gsblng  NXBYTA        ; -
              rcr     1             ; -
              a=c     s             ; -
              c=0                   ; -
GTAI60:       a=a-1   s             ; chars finished?
              goc     GTAI70        ; yes
              m=c                   ; -
              gsblng  NXBYTA        ; -
              cstex                 ; shift char in
              c=m                   ; -
              cstex                 ; -
              rcr     2             ; -
              goto    GTAI60        ; -
GTAI70:       gosub   RTJLBL        ; right-justify
              m=c                   ; save alpha string in M
              pt=     3             ; -
              gsblng  PUTPC         ; place PGMCTR
              abex                  ; A[3:0]_F.C. & K.C.
              c=regn  14            ; restore SS0
              st=c
              rtn                   ; -
; *
; ******************************************************
; * VIEW ROUTINE
; ******************************************************
; *
XAVIEW:       gosub   PRT11
              ?s7=1                 ; alpha mode?
              gonc    AVW10         ; no
              ?s13=1                ; running?
              rtn nc                ; no - keyboard, alpha mode
                                    ; default display is the same
                                    ; as aview - don't set MSGFLG
AVW10:
              s8=     0             ; scroll & no prompt
              s9=     1             ; keyboard already been reset
              gosub   ARGOUT

              goto    XVIEWA

XVIEW:        gosub   PRT10
              c=b
              .public PR10RT        ; for the printer
PR10RT:                             ; note the reg to be
; * viewed is expected in C when the PRT10 logic returns here
; * (it was in B when we went off to PRT10)
              gosub   DSPCRG

XVIEWA:       gosub   STMSGF        ; set message flag

              ?s0=1                 ; does a printer exist?
              goc     XVW10         ; yes
              rcr     8             ; no, check printer enable flag
              st=c
              ?s2=1                 ; did the user set it?
              goc     STOPS         ; yes - stop
XVW10:
MSGDLY:       gosub   BLINK

STMSGF:       c=0     x

; * GOSUB LDSST0 might be used here in place of the 4 inst seq
; * C=0 X, DADD=C, C=REGN 14, ST=C. An analysis of who calls
; * STMSGF and MSGDLY must be done to see if they can afford
; * another subroutine level
              dadd=c
              c=regn  14
              st=c
              s5=     1             ; set MSGFLAG
              goto    RSTMS2

; *
; * RSTSEQ - reset status bits at end of key sequence
; * Clears MSGFLG, DATAENTRY, PKSEQ, CATALOGFLAG, SHIFTSET, PSEFLAG
; * also clears running flag (S13)
; * Chip 0 must be enabled on entry
; * On Exit, SS0 is up and C contains a copy of the status register
; * Uses only the C register and S0-S7
; *
              .public RSTSEQ
              .public RSTSQ
RSTSEQ:       s13=    0             ; clear running
RSTSQ:        c=regn  14
              rcr     2
              st=c                  ; load SS1
              s1=     0             ; clear PKSEQ
              c=st
              rcr     12
              st=c                  ; load SS0
              s1=     0             ; clear pausing
              goto    RSTMSC
;                  THESE COMMENTS ACCURATE    RSW  6-13-80
; *
; *
; * RSTMSC - reset miscellaneous status bits
; * Resets CATALOGFLAG, SHIFT, DATAENTRY, and MSGFLAG
; * On entry, REG 14 in C except SS0 in ST, & chip 0 enabled.
; * On exit, status sets have been stored back to chip 0, chip 0 is enabled,
; *     SS0 is up (and C has a copy of the status sets).
; *
; * RSTMS1 - same as RSTMSC except sets up C and ST on entry
; * DATOFF - Exactly the same as RSTMS1
; * RSTMS0 - Same as RSTMS1, except calls ENCP00 first, thereby
; *     using an additional subroutine level
; *
; * USES: C, S0-S7,            (NO PT, +0 sub levels[except RSTMS0])
; *
              .public RSTMS0
              .public DATOFF
              .public RSTMS1
              .public RSTMSC
RSTMS0:       gosub   ENCP00
DATOFF:
RSTMS1:       c=regn  14
              st=c
RSTMSC:       rcr     6
              cstex                 ; put up SS3
              s1=     0             ; clear catalog flag
              cstex
              rcr     10
              cstex                 ; put up SS1
              s0=     0             ; clear shift
              s2=     0             ; clear data entry
              cstex
              rcr     12
              s5=     0             ; clear MSGFLAG
RSTMS2:       c=st
              regn=c  14
              rtn


              .public XPRMPT
; *
; * PROMPT - this function combines AVIEW and R/S
; *
XPRMPT:       gosub   PRT7
              gosub   RSTMS0        ; clear MSGFLG (in case we're
                                    ; in alpha mode) & leave
                                    ; SS0 up
              s8=     0             ; set up for ARGOUT
              ?s7=1                 ; alpha mode?
              gonc    PATCH8        ; no.
P8RTN:
              .public STOPS         ; error calls stops
STOPS:        c=regn  14            ; retrieve SS0
              st=c
              .public STOPSB
STOPSB:                             ; stop subroutine
                                    ; stop a running or pausing
                                    ; user program
                                    ; on entry, SS0 is up
                                    ; uses 1 subroutine level
                                    ; and C. leaves chip 0
                                    ; selected.
              s1=     0             ; clear pause flag
              gosub   STOST0

              .public PSESTP
PSESTP:                             ; enter from pause FCN
              s13=    0             ; clear running flag
              rtn

ALPDEF:       c=stk                 ; get right def
              c=c+a   m
              cxisa                 ; get low 10 bits
              ?c#0    x             ; if zero done cat
              gonc    QUTCAT
              pt=     3
              lc      1             ; build adr in ROM 4
              rcr     11            ; move to mantissa
END2:         acex                  ; save in A
; * Entry point valid for HP-41CX
              .public END2CX
END2CX:       gosub   CLLCDE        ; enable and clear LCD
              acex
              gosub   PROMF2
              gosub   LEFTJ         ; left-justify string
END3:         gosub   ENCP00        ; turn off LCD
              gosub   BLINK
              gosub   PRT12         ; send display to printer
              gosub   RSTANN
              ?s4=1                 ; single step?
              golnc   CNTLOP        ; if running CAT continue
CLCTMG:       c=regn  14            ; set status for RTN to KBD
              st=c
              s5=     1
              c=st
              rcr     6
              st=c
              s1=     1
KBD:          c=st
              rcr     8
              regn=c  14
              golong  NFRKB
QUTCAT:       c=regn  14            ; catalog finish
              st=c
              s5=     0
              c=st
; * Entry point added for HP-41CX
              .public QUTCX
QUTCX:        rcr     6
              st=c
              s1=     0
              goto    KBD
; *
; * PATCH8 - Post-release fix to avoid putting the ALPHAREG to the LCD
; * and setting MSGFLAG when prompt is executed in ALPHAMODE.  This is
; * desirable because the ALPHAREG is the default display in alpha mode.
; *
PATCH8:       gosub   ARGOUT        ; put ALPHAREG to LCD
              gosub   STMSGF        ; set MSGFLG
              goto    P8RTN
; *
; * PATCH4 - This post-release patch speeds up the execution of the
; *          run portion of R/S
; *
              .public PACH4
PACH4:        ldi     167           ; set up 100ms wait
PTCH4A:       rst kb                ; is the key still down?
              chk kb
              golnc   XRS45         ; no, go run!
              c=c-1   x             ; time out over?
              gonc    PTCH4A        ; no, keep checking the key
              golong  LINNUM        ; display the starting step

; *
; * PACH10 - Post-release patch to fix a bug in "SF IND NN"
; *
              .public PACH10
PACH10:       gosub   BCDBIN
              ?c#0    xs            ; addr>255?
              golc    ERRNE         ; yes
              pt=     2             ; restore 1st byte
              c=g                   ; of FC to C[3:2]
              golong  P10RTN

; *
; * PACH11 - Post-release fix to display driver synchronization
; * problem, 3/26/79.  The two display driver chips re-synchronize
; * each time the cpu comes wide awake, no matter whether from light
; * sleep or deep sleep.  Each time the C register contains both ones
; * and zeroes, the display drivers sort themselves out.  This process
; * continues until a display read instruction is executed.  However,
; * if the data line floats while the display drivers are trying to
; * sort themselves out, and if the level on the data line drifts,
; * the display drivers may get confused and tank the system.
; * This patch ensures that the display drivers get synchronized and
; * then disable the synchronization logic before any microcode
; * floats the data line (as by reading from a nonexistent data
; * storage chip in CHKADR or FNDEND).
; *
              .public PACH11
PACH11:       ldi     0x2fd
              dadd=c                ; enable nonexistent data chip 2FD
              pfad=c                ; enable display
              flldc                 ; non-destructive read
              golong  MEMCHK

; *
; * PACH12 - Post-release fix to decompile on wakeup when machine goes
; * to sleep in program mode.  DRC 10/20/79
; *
              .public PACH12
PACH12:       c=0     x
              regn=c  14
              golong  DECMPL
