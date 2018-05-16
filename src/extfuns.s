;;; Extended functions for HP-41CX

#include "hp41cx.h"

CHKCST:       .equlab 0x7cdd

              .section PAGE3

              .con    25            ; XROM #25
              .con    (FatEnd - FatStart) / 2 ; number of entry points
FatStart:     .fat    Header
              .fat    ALENG
              .fat    ANUM
              .fat    APPCHR
              .fat    APPREC
              .fat    ARCLRC        ; 5
              .fat    AROTAT
              .fat    ATOX
              .fat    CLFL
              .fat    CLKEYS
              .fat    CRFLAS        ; 10
              .fat    CRFLD
              .fat    DELCHR
              .fat    DELREC
              .fat    EMDIR
              .fat    FLSIZE        ; 15
              .fat    GETAS
              .fat    GETKEY
              .fat    GETP
              .fat    GETR
              .fat    GETREC        ; 20
              .fat    GETRX
              .fat    GETSUB
              .fat    GETXX
              .fat    INSCHR
              .fat    INSREC        ; 25
              .fat    PASN
              .fat    PCLPS
              .fat    POSA
              .fat    POSFL
              .fat    PSIZE         ; 30
              .fat    PURFL
              .fat    RCLFLAG
              .fat    RCLPT
              .fat    RCLPTA
              .fat    REGMOV        ; 35
              .fat    REGSWP
              .fat    SAVEAS
              .fat    SAVEP
              .fat    SAVER
              .fat    SAVERX        ; 40
              .fat    SAVEX
              .fat    SEKPT
              .fat    SEKPTA
              .fat    `SIZE?`
              .fat    STOFLAG       ; 45
              .fat    `X<>F`
              .fat    XTOA
              .fat    CXHeader
              .fat    ASROOM
              .fat    CLRGX         ; 50
              .fat    ED
              .fat    EMDIRX
              .fat    EMROOM
              .fat    GETKEYX
              .fat    RESZFL        ; 55
              .fat    `ΣREG?`
              .fat    `X=NN?`
              .fat    `X≠NN?`
              .fat    `X<NN?`
              .fat    `X<=NN?`      ; 60
              .fat    `X>NN?`
              .fat    `X>=NN?`
FatEnd:       .con    0, 0


#if 0
;;; **********************************************************************

               Extended memory file structure

  The extended memory can be composed by up to three modules. The
  first module we call the base module which contains 128 registers of
  memory and is located at memory address 040-0BF (hex).

  The first file always start from the base module which is always
  present when using extended memory.

  The second kind of module we call the extended memory module. It
  contains 239 registers and is located at address 201-2EF if it is
  plugged into port 1 or 3, or will be at address 301-3EF if it is
  plugged into port 2 or 4. Up to two extended memory modules can be
  present at the same time to get the full capacity of the extended
  memory. But the module have to be plugged in horizontally opposite
  port.

  The linkage among these three discontinue memory is as follows:
  The base module is always the beginning of extended memory. Then it
  will link to 2EF or 3EF depending on which module is plugged in
  first. If the two extended memory modules are plugged in at the same
  time, the base module will be linked to address 2EF first (the
  module in port 1 or 3).
  The lowest register in every module (040 for base module, 201/301
  for the others) is used for the linkage between modules. It contains
  the following information:

   13 12 11 10  9  8  7  6  5  4  3  2  1  0
  -------------------------------------------
  |  |  |        |         |       |        |
  -------------------------------------------
             D        C        B        A

  A - module id
      0BF for base module
      2EF for ex.mem module in port 1 or 3
      3EF for ex.mem module in port 2 or 4
  B - next module id = 2EF or 3EF (= 000 if no module connected)
  C - previous module id = 040 or 2EF or 3EF
  D - in base module this is current file number
      don't care in ex.mem module

  File header information:
  Every file start with a register which contains the file name. The
  file name can be up to 7 characters with trailing blanks. The next
  register is called the file header. it contains:

   13 12 11 10  9  8  7  6  5  4  3  2  1  0
  -------------------------------------------
  |  |  |  |  |  |         |       |        |
  -------------------------------------------
   D                 C        B        A

  A - file size in number of registers (not including the file name
      and header register)
  B - for program file = program length in number of bytes
      for data file    = current register pointer
      for ASCII file   = current record pointer
  C - for program file = don't care
      for data file    = don't care
      for ASCII file   = current character pointer
  D - file type  = 1 - program file
                 = 2 - data file
                 = 3 - ASCII file

  The ASCII file is contains records of ASCII strings. Every record
  compose a byte of record length at the beginning and is followed by
  the ASCII string. The record length can be up to 254. After the last
  record, there is always an "FF" indicating the end of file.

  End of memory mark:
  At the end of the last file in memory, there is always a register
  containing "FFFFFFFFFFFFFF" to indicate the end of memory.
  After files have been created, pulling out any extended memory
  module will cause all or some files to be lost.
  1. If pulling out the base module, all files are lost.
  2. If pulling out any ex.mem module, any partial file left will be
     lost.
  3. If the end of memory mark is missing, last file will be lost.

;;; **********************************************************************
#endif
              .name   "CLKEYS"
;;; The goto-next-line instruction that appear before enromX is because
;;; the ROM chip used (HP part no. 1LG9) requires that the enromX is
;;; preceded by an instruction whose high bit is zero. This is customarily
;;; handled by placing a goto-next-line instruction before the enromX.
;;; Ref: HP SDS-II manual page 39.
CLKEYS:       goto    .+1
              enrom2
              golong  CLKEYS2

              .name   "-EXT FCN 2D"
Header:
              .name   "ASROOM"
ASROOM:       goto    .+1
              enrom2
              golong  ASROOM2

              .name   "-CX EXT FCN"
CXHeader:

              .name   "PSIZE"
PSIZE:
              gosub   `X<999`
              n=c
              c=regn  11            ; save user rtn stack in reg. 9&8
              regn=c  9
              c=regn  8
              pt=     4             ; save reg.8[5:4] in g
              g=c
              pt=     3
              a=c
              c=regn  12
              acex    wpt
              regn=c  8
              c=n
              s9=     0
              gosub   SIZSUB        ; try to do the new size
              c=regn  8             ; restore part of reg.8 first
              pt=     4
              cgex
              regn=c  8
              ?s9=1                 ; enough room to do the new size
              gonc    PSIZ10        ; yes
              .public NORMEX
NORMEX:       gosub   LDSST0
              ?s13=1
              goc     NO_ROOM
              ?s4=1
              golong  PACKE

              .public NO_ROOM
NO_ROOM:      gosub   APERMG
              .messl  "NO ROOM"
              golong  APEREX
PSIZ10:       enrom2
              golong  PSIZ10_2

              .name   "EMDIRX"
EMDIRX:       gosub   CHECKX
              enrom2
              golong  EMDIRX2

              .public DUPFER
DUPFER:       gosub   APERMG
              .messl  "DUP FL"
              golong  APEREX

              .name   "ΣREG?"       ; 56
`ΣREG?`:      c=regn  13
              rcr     11
              a=c     x
              rcr     6
              a=a-c   x
              nop
              golong  ATOX20

              .name   "PASN"
PASN:         gosub   GTPRNA
              c=m
              regn=c  9
              c=regn  3
              ?c#0    xs
              gonc    LB_3118
              .public PASNER
PASNER:       gosub   APERMG
              .messl  "KEYCODE"
              golong  DISERR

              .public STOPS1
STOPS1:       enrom1
              golong  STOPS
LB_3118:      enrom2
              golong  PASN10

              .name   "X=NN?"
`X=NN?`:      goto    .+1
              enrom2
              golong  `X=NN? 2`

              .name   "X≠NN?"
`X≠NN?`:      goto    .+1
              enrom2
              golong  `X≠NN? 2`

              .name   "X<NN?"
`X<NN?`:      goto    .+1
              enrom2
              golong  `X<NN? 2`

;;; **********************************************************************
;;; * ALEN - Alpha length
;;; *   Recall the alpha length to the X register
;;; *
              .name   "ALENG"
ALENG:        gosub   ALEN
              goto    ATOX20        ; put the number to X

;;; **********************************************************************
;;; * ALEN - Routine to compute the alpha length
;;; *   input: Dont' care
;;; *   output: A.X=C.X= Alpha length
;;; *   used A[3:0], B[3:0], C, PT=3, S2, S3, +2 sub level
;;; *
              .public ALEN
ALEN:         gosub   FAHED
              ?s2=1
              gonc    ALEN10
              a=0     x
              goto    ALEN20
ALEN10:       c=0
              ldi     5             ; C[3:0]= addr of alpha end
              bcex    wpt
              gosub   CNTBY7        ; count the # of bytes between the
                                    ; two addresses
              a=a+1   x
ALEN20:       c=a     x
              rtn

;;; **********************************************************************
;;; * ATOX - Alpha to X
;;; *   Shift the leftmost char of the alpha register into the
;;; *   X register.
;;; *   If alpha empty, it will leave a zero in the X register
              .name   "ATOX"
ATOX:         gosub   FAHED         ; get the leftmost char addr, the char
                                    ; will be in G
              ?s2=1                 ; alpha empty
              gonc    ATOX10        ; no
              b=0
              goto    ATOX30
ATOX10:       c=0     x
              gosub   PTBYTA        ;  shift off the char
              pt=     0
              c=g
              c=0     xs
ATOX15:       a=c     x
ATOX20:       gosub   `BIN-D`       ; convert the binary to decimal
ATOX30:       golong  RCL           ; recall the number to X

              .name   "FLSIZE"
FLSIZE:       s0=     1
              gosub   FLSHAP        ; get file entry
              c=n
              goto    ATOX15

              .name   "SIZE?"
`SIZE?`:      gosub   FNDEND
              c=0
              dadd=c
              c=regn  13
              rcr     3
              a=a-c   x
              gonc    ATOX20        ; size = 0
              a=0
              goto    ATOX20

;;; **********************************************************************
;;; * BIN-D - Routine to convert a binary number to a normalized
;;; *         number
;;; *   input  : A.X = binary number
;;; *   output : B = normalized decimal number
;;; *            chip 00 enable
;;; *   used A, B, C, S0   +1 sub level
;;; * BIN-D3 - special entry with s0=1 as input
              .public `BIN-D`, `BIN-D3`
`BIN-D`:      s0=     0
              a=0     s
`BIN-D3`:     ldi     16
              dadd=c                ; unselect RAM
              c=0     x
              pfad=c               ; unselect peripherals
              gosub   GENNUM        ; convert to decimal digits
;;; * Now B.S = # of decimal digits
;;; *     A.M = left justified decimal digits
              c=0
              dadd=c                ; select chip 00
              ?s0=1                 ; come from BIN-D3?
              rtn c                 ; yes, return here
              c=b     s
              pt=     11
              c=c-1   s             ; compute the exp of the number
BIND10:       c=c-1   s
              goc     BIND20
              c=c+1   x
              dec pt
              legal
              goto    BIND10
BIND20:       a=0     wpt
              a=c     x             ; A.X = exp of the number
              .public LB_3194
LB_3194:      a=0     s
              .public BIND25
BIND25:       pt=     12            ; shift out leading zeroes
BIND30:       ?a#0    pt
              goc     BIND40
              asl     m
              a=a-1   x
              gonc    BIND30
              a=0
BIND40:       b=a
              rtn

;;; **********************************************************************
;;; * FAHED - Routine to find the addr of the first char of the
;;; *         alpha register
;;; *   input  : don't care
;;; *   output : if s2 = 1, alpha register empty
;;; *            if s2 = 0, then ;
;;; *            A[3:0] = addr of first character
;;; *            G = first character in the alpha register
;;; *            PT = 3
;;; *   used  A[3:0], C, PT, S2,   +1 sub level
              .public FAHED
FAHED:        gosub   ADR608        ; load addr hex 6008
              s2=     0
FAHD10:       gosub   INCADA        ; skip over leading nulls
              gosub   GTBYTA
              c=0     xs
              ?c#0    x
              goc     FAHD20
              ldi     5
              c=0     pt
              ?a#c    wpt           ; reached alpha end ?
              goc     FAHD10        ; not yet
              s2=     1
FAHD20:       pt=     0
              g=c                   ; save first character in G
              pt=     3
FAHD30:       c=regn  8             ; save alpha head in reg.8[13:10]
              rcr     10
              c=a     wpt
              rcr     4
              regn=c  8
              rtn

              .public ADR608
ADR608:       c=0
              dadd=c
              c=regn  8
              ldi     8
              pt=     3
              lc      6
              pt=     3
              a=c     wpt
              goto    FAHD30

              .name   "ANUM"
ANUM:         gosub   FAHED         ; get address of alpha head
              ?s2=1                 ; alpha empty?
              rtn c                 ; yes, don't do anything
              goto    .+1
              enrom2
              golong  ANUM2

              .name   "AROT"
AROTAT:       goto    .+1
              enrom2
              golong  AROT2

;;; **********************************************************************
;;; * ENB1GO - Go to a location in bank1 from any other bank.
;;;
              .public ENB1GOH, ENB1GO
ENB1GOH:      sethex
ENB1GO:       c=stk      ; pointer is after the call to here
              cxisa                 ; get lower 8 bits
              rcr     4
              csr     m             ; move them right
              csr     m
              rcr     10
              c=c+1   m             ; point to address of upper 8 bit
              cxisa                 ; read upper part
              rcr     9             ; put address in C[6:3] address field
              goto    .+1
              enrom1                ; enable bank 1
              gotoc                 ; go

;;; **********************************************************************
;;; * TOBNK1 - return to bank 1
              .public TOBNK1
TOBNK1:       goto    .+1
              enrom1
              rtn

              .public RMAD_PAGE3
RMAD_PAGE3:   lc      3             ; Scan FAT in page 3
              pt=     6
              cxisa
              ?a#c    x
              rtn c
              c=c+1   m
              c=b     x
              a=c
              cxisa
              ?a<c    x
              rtn nc
              golong  RMAD25

              .public CXCAT
CXCAT:        c=c-1   s             ; CAT 3?
              goc     1$            ; yes
              c=c-1   s
              golc    EMDIR
              c=c-1   s
              golc    ALMCAT
              c=c-1   s
1$:           golong  CAT3
              golong  KEYCAT

              .public CAT2CX, CAT2_
CAT2CX:       rcr     8
              bcex    s
CAT2_:        c=0
              abex    x
              a=a-1   x
              c=c+1   m
              pt=     6
              lc      4
              pt=     6
11$:          c=c+1   pt
              goc     2$
              cxisa
              a=a-c   x
              gonc    11$
3$:           golong  CAT2CX_20
2$:           lc      3
              pt=     6
              cxisa
              a=a-c   x
              goc     3$
              chk kb
              gonc    4$
              gosub   CAT_STOP
              ?a#c    x
              gonc    LB_3234
4$:           golong  QUTCAT
              .public LB_321D
LB_321D:      rcr     9
              pt=     1
              ldi     6
              a=c
5$:           c=c-1   m
              cxisa
              c=c+c   wpt
              golc    CAT2CX_10
              a=a-1   x
              gonc    5$
              chk kb
6$:           golong  END2CX
              gosub   LDSST0
              ?s4=1
              goc     6$
              gosub   CAT_STOP
              ?a#c    x
              goc     6$
LB_3234:      golong  BSTCAT

              .name   "X<=NN?"
`X<=NN?`:     goto    .+1
              enrom2
              golong  `X<=NN? 2`

;;; **********************************************************************
;;; * X<256 - routine to get int(X) and check if int(X) < 256
;;; *   input  : chip 0 enable
;;; *              if int(X) >= 256 will exit to "DATA ERROR"
;;; *              if X has a string, will say "ALPHA DATA"
;;; * X<999 - get int(X) and check if int(X) < 1000
;;; *   input  : chip 0 enable
;;; *   output : A.X = C.X = int(decimal number)
;;; *   used  A, B.X, C, S8    +2 sub levels
              .public `X<256`, `X<999`, LB_3242
`X<999`:      c=regn  3
              a=c
LB_3242:      ldi     1000
              goto    INT10
`X<256`:      c=regn  3
              a=c
              ldi     256
INT10:        bcex    x
              acex
              gosub   CHK_NO_S      ; see if it is a number
              sethex
              a=c
              ?a#0    xs            ; is the number < 1 ?
              goc     INT20         ; yes, its integer is zero anyway
              ldi     3
              ?a<c    x             ; is the number < 1000 ?
INTER:        gonc    INT_DE        ; no, say "DATA ERROR"
              acex
INT20:        gosub   BCDBIN        ; convert the number to binary
              a=c     x             ; A.X = the binary of the number
              ?a<b    x             ; is the number too big ?
              gonc    INTER
              rtn

              .public LB_325C, LB_3260
LB_325C:      c=c-1   s
              c=c-1   s
              golc    ERRAD
LB_3260:      sethex
              a=c     x
              c=0     s
              c=0     x
              ?c#0    m
              rtn nc
              ?a#0    xs
              rtn c
              rcr     12
              a=a-1   x
              goc     GOTINT_
              rcr     13
              a=a-1   x
              goc     GOTINT_
              rcr     13
              a=a-1   x
INT_DE:       golnc   ERRDE
GOTINT_:      golong  GOTINT

LB_3274:      gosub   CHECKX
              gosub   LB_3260
              c=c-1   x
              goc     INT_DE
              bcex    x
              gosub   SRHBUF
              goto    .+2
              goto    LB_3292
              a=a+1   x
              gosub   `NEWM.X`
3$:           c=b     x
              c=c-1   x
              goc     LB_3294
              bcex    x
              gosub   ALMSST
              goto    3$
              goto    LB_3292

              .public RMCK03
RMCK03:       lc      3             ; poll vector in page 3?
              pt=     6
              cxisa
              ?c#0    x
              gonc    LB_3290
              gotoc                 ; yes, go and do it
LB_3290:      rcr     4
              gotoc
LB_3292:      c=0     x
              rtn
LB_3294:      c=m
              rtn

;;; **********************************************************************
;;; * TGLSHF - toggle shift annunciator                       1-12-81 RSW
;;; *
;;; * IN & ASSUME:  S7= existing state of shift annunciator (1= on, 0= off)
;;; * OUT: chip 0 enabled, S7 in opposite state with matching annunciator
;;; * USES: C, S7, +1 sub level, DADD, PFAD
;;; *       (no PT, no arith mode, no timer chip access)
;;; *
;;; **********************************************************************

              .public TGLSHF2, TGLS10, LB_3298, LB_3299
TGLSHF2:      gosub   ENLCD
LB_3298:      readen      ; read annunciators
LB_3299:      ?s7=1                 ; shift set ?
              gonc    TGLS10        ; no, set it
              s7=     0             ; yes, clear it
              cstex
              s7=     0             ; clear shift annunciator
              goto    TGLS20
TGLS10:       s7=     1             ; set shift
              cstex
              s7=     1             ; set shift annunciator
TGLS20:       cstex
TGLS30:       wrten
              golong  ENCP00


;;; **********************************************************************
;;; * CHKLB - check low battery                               2-6-81 RSW
;;; *
;;; * IN & ASSUME: hexmode
;;; * OUT: low battery annunciator set if low battery is detected
;;; *      (chip enable= chip 0 or same as input)
;;; * USES: C, DADD, PFAD, +1 sub level
;;; *       (no ST, no PT, no timer chip access)
;;; *
;;; * EXEC TIME: 28 word times including GSB & RTN if battery is low
;;; *
;;; **********************************************************************

              .public CHKLB2        ; entry point is in page 5, the routine
                                    ; was moved here, so we use a new label
CHKLB2:       ?lld                  ; low battery ?
              rtn nc                ; no
              gosub   ENLCD         ; yes
              readen                ; read annunciators
              rcr     1
              cstex
              s7=     1             ; set low batt enunciator
              cstex
              rcr     13
              goto    TGLS30

              .name   "POSA"
POSA:         goto    .+1
              enrom2
              golong  POSA2

XPOANF:       goto    .+1           ; go to CX function in ROM 5.2
              enrom2
              golong  XPOANF2

XPOAFN:       goto    .+1           ; go to CX function in ROM 5.2
              enrom2
              golong  XPOAFN2

              .public RMCK10_B1
RMCK10_B1:    goto    .+1           ; enable bank 1 and to to RMCK10
              enrom1
              golong  RMCK10

              .public LB_32C5
LB_32C5:      a=0     pt            ; lifted out from ALMBST
              b=a     x
              c=b     x
              rtn

              .name   "X>NN?"
`X>NN?`:      goto    .+1
              enrom2
              golong  `X>NN? 2`

;;; from DSPA80
;;; This code deals with turning the calculator off and the
;;; shift flag status. I believe the original Time module had
;;; a bug in that if the SHIFT annunciator was on, pressing
;;; ON key to turn if off when an alarm occured gave the
;;; clock display. I think the following code changes/fixes
;;; that, but it needs to be investigated.  hth313
              .public LB_32D2
LB_32D2:      gosub   ENLCD
              ldi     18
              ?a#c    wpt
              goc     LB_32E2
              readen
              cstex
              ?s7=1
              goc     LB_32DE
              s7=     1
              goto    LB_32DF
LB_32DE:      s7=     0
LB_32DF:      cstex
              wrten
              goto    LB_32ED
LB_32E2:      ldi     112
              ?a#c    wpt
              gonc    LB_32F1
              gosub   OFSHFT10
              ldi     24
              ?a#c    wpt
              golong  ALM169
LB_32ED:      c=0                   ; disable LCD
              pfad=c
LB_32EF:      golong  DSPA82
LB_32F1:      readen
              c=c+c   pt
              gonc    LB_32ED
              gosub   OFSHFT10
              ?s4=1
              goc     LB_32EF
              gosub   RSTKB
              gosub   PUGALM
              goto    LB_32FF
              golong  ALM171
LB_32FF:      golong  ALM210

;;; **********************************************************************
;;; * CNTBY7 - "Count bytes for 7 bytes per register" computes
;;; *          # of bytes between two addresses.
;;; *   input  : A[3:0] = starting addr (higher addr)
;;; *            B[3:0] = ending addr (lower addr)
;;; *   output : A[3:0] = number of bytes between the two addresses
;;; *                     (NOTE: If the two addresses are the same,
;;; *                            # of bytes between them is zero.
;;; *                            If they are one byte different, # of
;;; *                            bytes between then is one, etc ..)
;;; *            PT = 3
;;; *   used A[3:0], B[3:0], C, S2, S3    +0 sub levels
;;; * CNTBYE - special entry point for addresses in the external
;;; *          memory
;;; *   output : A[3:0] = # of bytes
;;; *            if S2=1, memory discontinuity detected
;;; *   used A[7:0], B[3:0], C, PT=3, S2, S3,   +1 sub level

              .public CNTBYE, CNTBY7
CNTBYE:       c=b     x
              ?a#c    xs            ; two addresses in the same module?
              gonc    CNTBY7        ; yes
              gosub   NXTMDL        ; advance to next module
              ?s2=1                 ; memory discontinuity ?
              rtn c                 ; yes, error exit
              c=b     x             ; get end addr again
              ?a#c    xs            ; are we in end module yet ?
              gonc    CTBE30        ; yes
              ldi     238           ; add one module to start addr
              goto    CTBE40
CTBE30:       c=0     x
CTBE40:       b=a     xs            ; force to the same module
              a=a-b   x             ; A.X = # of regs in next module
              a=a+c   x             ; add 238 if crossed 3 modules
              b=a     x             ; B.X= # of regs over stating module
              acex
              a=c
              rcr     4             ; C[3:0]=starting addr
              a=c     wpt
              gosub   ENRGAD        ; get end reg addr of this module
              a=a+b   x             ; add next module regs to start addr
              bcex    x             ; move end addr to module end reg
CNTBY7:       pt=     3
              c=0
              a=a-b   pt
              gonc    CBYT10
              a=a-1   x
              a=a-1   pt
CBYT05:       a=a-1   pt
CBYT10:       a=a-1   pt
              goc     CBYT20
              c=c+1   x
              gonc    CBYT05
CBYT20:       a=a-b   x
              bcex    wpt
              a=0     pt
              acex    wpt
              a=c     wpt
              c=c+c   wpt
              c=c+c   wpt
              c=c+c   wpt
              acex    wpt
              a=a-c   wpt
              a=a+b   wpt
              rtn

              .public CLRALMS2
CLRALMS2:     gosub   SRHBUF        ; locate alarm buffer
              goto    1$
              rtn                   ; no alarm buffer
1$:           c=a     x
              c=c+1   x
              m=c
LB_333A:      gosub   PUGA10
              rtn
              goto    LB_333A

              .public LB_333E
LB_333E:      gosub   LDSST0
              golong  OFF

              .name   "RCLFLAG"
RCLFLAG:      c=regn  14            ; get status register
              ldi     511
              rcr     3             ; C=1FFXXXXXXXXXXX
              bcex
              golong  RCL

              .name   "STOFLAG"
STOFLAG:      goto    .+1
              enrom2
              golong  STOFLAG2

              nop

              .public CAT_STOP
CAT_STOP:      c=keys
              rcr     3
              c=0     xs
              a=c     x
              pt=     0
              c=c+c   pt            ; check for "ON" key
              gonc    1$
              sel p                 ; yes, turn OFF
              enrom1
              gosub   LDSST0
              golong  OFF
1$:           ldi     135           ; R/S key
              rtn

              .name   "GETKEY"
GETKEY:       goto    .+1
              enrom2
              golong  GETKEY2

              .public DDATE2
DDATE2:       gosub   CHECKX        ; error if X= alpha data
              s7=     0             ; not "DDAYS"
              s5=     1             ; integer part
              gosub   INTFRC        ; get integer part of X
              c=-c-1  s             ; complement the sign of the #days
`DT+10`:      m=c                   ; save integer part in M
              ldi     2             ; use date from Y register
              gosub   CHECK         ; error if Y= alpha data
              s0=     1             ; date from Y
              s1=     1             ; add X or Y to DATA ERROR
              gosub   YMDDAY        ; convert it to Julian days
              gosub   NDAYS         ; A= positive normalized F.P. #days
              a=a-1   s             ; A= negative number of days
              c=m                   ; get the integer back to C
              gosub   AD2_10        ; add integer to Julian days
;;; * No overflow possible since the day number calculated from the date is
;;; * at most 999999 which can't cause the maximum number in X (9,99999999 E99)
;;; * to overflow.
;;; * No underflow is possible since only the integer part of X is used, and
;;; * the day number calculated from the date is an integer.
              ?s7=1                 ; called from "DDAYS" ?
              goc     TNFRXY        ; yes, output the number of days
              ?c#0    s             ; negative result ?
              goc     `DT+15`       ; yes
              a=0                   ; no, output low end of calendar
              goto    `DT+24`
`DT+15`:      a=c                   ; A= -( days since 10-15-1582 )
              ldi     5
              gosub   UNNORM        ; unnormalize
              goto    `DT+25`       ; (P+1) OK, A= #DDDDDD0000000
              setdec                ; (P+2) outside calednar range
              a=0
              a=a-1                 ; A= DDDDDD= 999999
              nop
`DT+24`:      gosub   RNGERR        ; return only if range error ignore= 1
`DT+25`:      asl
              gosub   DAYMD         ; C= positive normalized F.P. date
TNFRXY:       golong  NFRXY

              .public DDAYS2
DDAYS2:       s1=     1             ; add X or Y to "DATA ERROR"
              gosub   `X-YMDD`      ; convert X to Julian days
              gosub   NDAYS         ; normalize number of days
              s7=     1             ; called from DDAYS
              goto    `DT+10`

              .name   "PCLPS"
PCLPS:        goto    .+1
              enrom2
              golong  PCLPS2

              .name   "CLRGX"
CLRGX:        goto    .+1
              enrom2
              golong  CLRGX2

              .name   "X<>F"
`X<>F`:       gosub   `X<256`
              gosub   SWPBIT
              c=regn  14            ; place status byte to
              rcr     12            ;  REG.14[13:12]
              acex    wpt
              rcr     2
              regn=c  14
              gosub   SWPBIT
              gosub   `BIN-D`
              c=b
              regn=c  3
              golong  ANNOUT

;;; **********************************************************************
;;; * SWPBIT - routine to reverse the 8 bits in A[1:0]
;;; *   input  : A[1:0] = the 8 bits
;;; *   output : A[1:0] = swapped 8 bits
;;; *            PT     = 1
;;; *   used A.X, C.X, PT    +0 sub levels
SWPBIT:       pt=     9
              asl     x             ; A[2:1] = status byte
              acex    x             ; C[2:1] = remaining status byte
STS30:        a=0     xs            ; A[1:0] = switched status byte
              c=c+c   x
              gonc    STS40
              a=a+1   xs
STS40:        acex    x
              c=c+c   x
              c=c+c   x
              c=c+c   x
              csr     x
              acex    x
              dec pt
              ?pt=    1
              gonc    STS30
              rtn

              .public PWOF10
PWOF10:       c=st
LB_33E3:      wrscr
              clr st                ; clear "run label" bit
                                    ; turn display off at exit
                                    ; not light sleep wakeup
                                    ; remember powoff
              s7=     1             ; clear running flag
              s13=    0
              golong  ALM185

              .public LB_33E9, LB_33EE
LB_33E9:      b=0     s             ; file type wild card
              c=0
              ldi     812
              m=c
LB_33EE:      s3=     1

;;; **********************************************************************
;;; * CUR# - routine to load current file number to C.X
;;; *
;;; * Note: This was originally CUR#=0, but was changed compared to
;;; *       Extended Functions to not clear the file number,
;;; *       but rather load current file number to C.X
              .public `CUR#`
`CUR#`:       ldi     0x40          ; select base module link register
              dadd=c
              c=data
              rcr     9             ; current file to C.X
              rtn

              .public LB_33F5
LB_33F5:      ldi     0x40
              dadd=c
              c=data
              rcr     6
              a=c     x
              rcr     3
              acex    x
              rcr     5
              data=c
              rtn

;;; **********************************************************************
;;; * NXCHR - routine to point to the next byte in the ex.mem
;;; *   input  : A[3:0] = current address
;;; *            PT = 3
;;; *            IF S3=1, when it moves to the next module, it will
;;; *                     update the base reg in both modules
;;; *               S3=0, will not update the base registers
;;; *
;;; * NXREG - special entry point to point to next reg
;;; *   output : A[3:0]= next addr
;;; *            PT = 3
;;; *   used  A[7:0], C, S2,   +1 sub level
;;; *
              .public NXCHR, NXREG, NXCH30
NXCHR:        gosub   INCADA        ; point to next byte
              goto    NXCH10
NXREG:        a=a-1   x             ; point to next reg
NXCH10:       ldi     64
              ?a#0    xs            ; in base module ?
              gonc    NXCH20        ; yes
              ldi     1
              c=a     xs
NXCH20:       ?a#c    x             ; pointing at last reg of the module ?
              rtn c                 ; no
              gosub   NXTMDL        ; point to next module
              ?s3=1                 ; want to update base reg ?
              rtn nc                ; no
NXCH30:       pt=     1

;;; * At this point, A.X=C.X=NEF where N=2 or 3

              c=0     wpt           ; change C.X= N01 to point to the lower
              c=c+1   wpt           ;   register in this module
              dadd=c
              c=0                   ; fix up next module base reg
              pt=     6
              acex    wpt
              a=c     wpt
              rcr     12
              pt=     5
              c=0     wpt
              acex    x
              a=c     x
              data=c
              rcr     6             ; update current base reg
              dadd=c
              c=data
              rcr     3             ; load next module addr
              acex    x
              a=c     x
              rcr     11
              data=c
              goto    NXMDRT

;;; **********************************************************************
;;; * NXTMDL - get next module address
;;; *   input  : A.X = reg addr within current module
;;; *   output : A.X = highest register address of next module
;;; *            if A.X = 0  there is no next module
;;; *            if S2=1 next module is not connected to current module
;;; *            A[7:4] = input of A[3:0]
;;; *            PT = 3
;;; *   used A[7:0], C, S2, PT=3   +0 sub levels
              .public NXTMDL
NXTMDL:       c=a                   ; save A[3:0] to A[7:4]
              rcr     4
              pt=     3
              acex    wpt
              rcr     10
              a=c
              ldi     64
              ?a#0    xs            ; currently in base module ?
              gonc    NXMD01        ; yes
              ldi     1
              c=a     xs
NXMD01:       dadd=c
              ldi     0x2ef
              a=c     x
              c=data                ; get lowest reg of the module
              rcr     3             ; C.X = next module addr
              ?a#c    x             ; next module addr = 2EF ?
              gonc    NXMD05        ; yes
              a=a+1   xs            ; A.X = hex 3EF
              ?a#c    x             ; next module addr = 3EF ?
              goc     NXMD10        ; no, no next module connected
NXMD05:       pt=     1

;;; * At this point, A.X=C.X=NEF where N=2 or 3.

              c=0     wpt           ; load C.X = N01
              c=c+1   wpt
              dadd=c
              c=data                ; get lowest reg of next module
              ?a#c    x             ; is next module initialized ?
              gonc    NXMDRT        ; yes, A.X=highest reg addr of next module

;;; * NXMDRT set pt=3 and returns

NXMD10:       s2=     1             ; discontinue memory flag
              c=a
              rcr     4             ; C.X=current reg addr
              a=c     xs            ; A.X = 0EF/2EF/3EF
              ldi     0x201
              ?a#0    xs            ; currently in base module ?
              goc     NXMD30        ; no
              a=c     x             ; A.X=hex 201
              dadd=c
              data=c                ;  write to next module
              c=data
              ?a#c    x             ; reg 2-1 exist ?
              gonc    NEWMDL        ; yes, plug it back in
              acex    x             ; hex 201 back to C
NXMD20:       c=c+1   xs            ; C.X = hex 301
NXMD25:       a=c     x             ; A.X = hex 301
              dadd=c
              data=c
              c=data
              ?a#c    x             ; reg 301 exist ?
              gonc    NEWMDL        ; yes
NONXMD:       a=0     x             ; no next module
              goto    NXMDRT

NEWMDL:       pt=     1

;;; * Both jumps to NEWMDL are done with A.X=C.X=N01 where N=2 or 3,
;;; * so changes the 01 to EF as required, and C.XS already
;;; * contains the correct value for the A=C X, (see above for falling in)

              lc      14
              lc      15
              a=c     x             ; A.X = 2EF/3EF
NXMDRT:       pt=     3
              rtn
NXMD30:       ?a#c    xs            ; currently at reg 201 ?
              goc     NXMD40        ; no, check reg 201
              c=c+1   xs            ; currently at reg 201, check 301
NXMD40:       dadd=c                ; check next module
              c=data
              rcr     3
              ?a#c    x             ; is it pointing at current one ?
              gonc    NONXMD        ; yes, no next module
              ldi     0x201
              ?a#c    xs            ; currently at reg 201 ?
              goc     NXMD25        ; no, see if reg 201 exist
              goto    NXMD20        ; yes, see if reg 301 exist

;;; **********************************************************************
;;; * ADVREC - advance addr to point to next record
;;; *   input  : A[3:0] = addr of current record length
;;; *            PT= 3
;;; *   output : A[3:0] = first byte addr or next record
;;; *   used A[7:0], B[3:0], C, S2, PT,  +1 sub level
;;; * ADVREB - similar to "ADVREC" except the record length in B.X as input
              .public ADVREC, ADVREB
ADVREC:       gosub   GTBYTA
              c=0     xs
              c=c+1   x             ; C.X= record length + 1
              bcex    x
ADVREB:       abex    x             ; A.X= record length
              ldi     7
              c=0     m
              goto    1$
2$:           c=c+1   m
1$:           a=a-c   x
              gonc    2$
              c=a+c   x
              c=c+c   x
              rcr     11
              bcex    pt            ; B[3]= # of remaining bytes * 2
              abex    x
              rcr     6
              bcex    x             ; B.X = # of registers
              goto    ADVADR

;;; **********************************************************************
;;; * ADVADR - advance address in external memory
;;; *   input  : A[3:0] = current address
;;; *            B[2:0] = number of registers to advance
;;; *            B[3]   = plus half of this # of bytes
;;; *   output : A[3:0] = advanced address
;;; *            PT = 3
;;; *            if S2 = 1, discontinuity detected in memory
;;; *            if A.X = 0, memory overflow
;;; *   used A[7:0], B[3:0], C, S2, PT=3,   +1 sub level
;;; * ADVAD1 - advance one register in external memory
;;; *   input  : A[3:0] = current address
;;; *   output : same as "ADVADR"
;;; *   used   : same as "ADVADR"
              .public ADVADR, ADVAD1
ADVAD1:       c=0
              c=c+1
              pt=     3
              bcex    wpt
ADVADR:       gosub   ENRGAD        ; get lowest reg addr of current module
              c=a-c   x             ; C.X=# of remaining regs in this module
              abex    x             ; A=# of regs, B = current reg addr
              ?a<c    x             ; enough room in current module ?
              gonc    ADVA20        ; no, has to go to next module
              abex    x             ; B=# of regs, A = current reg addr
              a=a-b   x             ; A.X = advanced reg addr
              pt=     3             ; see if we need to advance bytes ?
              a=a-b   pt            ; advance remaining bytes
              rtn nc                ; enough bytes in the same reg
              a=a-1   pt
              a=a-1   pt            ; point to byte addr in next reg
              legal
              goto    ADVAD1        ; advance one more reg
ADVA20:       a=a-c   x             ; A.X = remaining regs to go -1
              abex    x             ; A = start addr, B = regs to go
              gosub   NXTMDL        ; get addr of next module
              ?a#0    x             ; is there a next module ?
              rtn nc                ; no
              goto    ADVADR

;;; **********************************************************************
;;; * GTINDX - get index from X in form RRR.BBBEEE
;;; *   input  : if S5=1, the index is a register block specification
;;; *            if S5=0, otherwise
;;; *            if S2=1, will decode X as RRR.BBBXXXXXXXXX
;;; *             (if S2=1, entry must be at GTIND2)
;;; *   output : if S5=0, then N[2:0]= EEE
;;; *                          N[5:3]= reg addr of BBB
;;; *                          N[8:6]= reg addr of RRR
;;; *                     C=N
;;; *            if S5=1, then N[2:0]= reg addr of BBB
;;; *                          N[5:3]= reg addr of RRR
;;; *            if S2=1, then N[5:3]= RRR
;;; *                          N[2:0]= BB
;;; *   used A, B, C, N, S2, S3, PT   +2 sub level
              .public GTINDX, GTIND2
GTINDX:       s2=     0             ; decode X as RRR.BBBEEE
GTIND2:       c=0
              dadd=c
              c=regn  3
              bcex
              c=b
              gosub   LB_325C       ; get binary of int(X)
              n=c
              s3=     0
GTIX10:       gosub   GTFRAB        ; get first 3 frac digit of X
              a=c     x
              c=n
              rcr     11
              acex    x
              n=c
              ?s3=1                 ; get second 3 digit of frac(X) yet ?
              goc     GTIX20        ; yes
              s3=     1
              goto    GTIX10
GTIX20:       ?s2=1                 ; for the function "STOFLAG" ?
              rtn c                 ;  yes
              c=regn  13            ; reg0 to A.X
              rcr     3
              a=c     x
              c=n                   ; convert register indices to
              rcr     3             ;  absolute address and
              c=a+c   x             ;  check that they exist
              rcr     3
              c=a+c   x
              ?s5=1                 ; for the function "REGMOVE"?
              gonc    GTIX30        ; yes
              gosub   CHKADR
              rcr     11
              n=c
              golong  CHKADR
GTIX30:       rcr     8
              n=c
              rtn

;;; **********************************************************************
;;; * GTFRA - get first 3 fraction digits of a number
;;; *   input  : A = the number
;;; *   output : C.X = binary of the fraction digits
;;; *            B = fraction of the number times 1000
;;; *   used A, B, C, S3  +1 sub level
;;; * GTFRAB - save as "GTFRA" except the input number is in B
              .public GTFRA, GTFRAB
GTFRAB:       abex
GTFRA:        setdec
              ?a#0    xs            ;  the number < 1 ?
              goc     GTFR20        ; yes
GTFR10:       asl     m
              a=a-1   x
              gonc    GTFR10
GTFR20:       ldi     3
              ?s2=1                 ; decode  as RRR.B ?
              gonc    GTFR30        ; no
              c=c-1   x
              s3=     1             ; loop only once in GTIND2
GTFR30:       a=a+c   x             ; multiply by 1000 (or 100)
              b=a
              acex
              sethex
              golong  BCDBIN

;;; **********************************************************************
;;; * ENRGAD = get lowest register address of current module
;;; *   input  : A[3:0] = reg addr in current module
;;; *   output : C[3:0] = lowest reg addr of current module
;;; *   used  C[3:0]  +0 sub levels
              .public ENRGAD
ENRGAD:       ldi     64
              ?a#0    xs            ; current at base module ?
              rtn nc                ; yes
              ldi     1
              c=a     xs
              rtn

;;; **********************************************************************
;;; * GTPRNA - get the program from alpha registers
;;; * GTPRAD - get addr of the program whose name is given in alpha
;;; *          register
;;; *   used A, B[3:0], C, M, PT, S0-6, S8, S9   +3 sub levels
;;; * GTFLNA - get the file name from alpha register
;;; *
;;; * The file name will be terminated by either a comma or end of
;;; * alpha register. A file name has to be exactly 7 chars. It will
;;; * be truncated or filled with trailing blanks if it is longer or
;;; * short than 7 chars. The addr of a delimiter will be saved
;;; * in reg.8[13:10] every time for later use.
;;; *
;;; * GTPRNA and GTFLNA use 1 sub level; GTPRAD uses 3 sub levels
;;; * ALNAM2 uses 1 level if S1=0, 3 levels if S1=1
;;; *
;;; * Status used :
;;; *  S5 : set to "0" at beginning, will be set the "1" for any
;;; *       non-null char in alpha register
;;; *  S6 : set to "0" at beginning, will be set the "1" if a comma
;;; *       is encountered
;;; *  S3 :
;;; *       S3=1 the file will be shifted into M from left end
;;; *       S3=0                 //                   right end
;;; *  S1 : when S3=1 :
;;; *        if S1=1, get the program address
;;; *           S1=0, don't try to get the program address
;;; *  output : M = program name or file name
;;; *           A[3:0] = program head addr
;;; *           A[7:4] = program end addr
;;; *           Reg.8[13:10] = last char addr
;;; *  error exit : if name not found will exit to "NAME ERROR"
              .public GTPRNA, GTPRAD, GTFLNA, ALNAM2
GTPRNA:       s1=     0
              goto    GTPRN0
GTPRAD:       s1=     1
GTPRN0:       s3=     1
              goto    ALNAM1
GTFLNA:       s3=     0
              s1=     0

ALNAM1:       c=0
              dadd=c
              c=regn  8             ; put alpha head addr to Reg.8[13:10]
              pt=     13
              lc      6
              lc      0
              lc      0
              lc      8
              regn=c  8
ALNAM2:       s5=     0             ; clear null string flag
              s6=     0             ; reset comma flag
              c=0
              m=c
              dadd=c
              c=regn  8
              pt=     3
              rcr     10
              bcex    wpt           ; put last addr in "B"
              pt=     13
              lc      7
              acex    s             ; char counter in A(13)
              goto    ALNA20
ALNA10:       gosub   INCADA        ; get next byte
              gosub   GTBYTA
              b=a     wpt           ; addr to B
              pt=     1
              ?c#0    wpt           ; is it a blank?
              gonc    ALNA20        ; yes
              a=c     wpt           ; check for comma
              ldi     44            ; comma
              ?a#c    wpt           ; is it a comma?
              goc     ALNA12        ; no
              s6=     1
              goto    ALNA30
ALNA12:       s5=     1             ; set non-null string flag
              ?a#0    s             ; 7 chars yet ?
              gonc    ALNA20        ; yes
              a=a-1   s             ; dec. char count
              c=m
              ?s3=1                 ; shift char to M from left ?
              gonc    ALNA16        ; no, from right
              acex    wpt           ; shift char to M from left
              rcr     2
              goto    ALNA17
ALNA16:       rcr     12            ; shift char to M from right
              acex    wpt
ALNA17:       m=c
ALNA20:       pt=     3
              abex    wpt           ; addr back to A
              ldi     5
              c=0     pt
              ?a#c    wpt           ; end of "A" reg
              goc     ALNA10        ; not yet
              b=a     wpt           ; addr to B
ALNA30:       c=m
              ?a#0    s             ; 7 chars yet ?
              gonc    ALNA40        ; yes
              ?s3=1                 ; shift from left ?
              gonc    ALNA35        ; no, from right
              rcr     2
ALNA33:       m=c
ALNA34:       a=a-1   s
              legal
              goto    ALNA30
ALNA35:       rcr     12     ; shift blank to M from right
              pt=     1
              lc      2
              lc      0
              goto    ALNA33
ALNA40:       c=c+1                 ; is the file name = FFFFFFF ?
              goc     FILNER        ; if so, say "NAME ERR"
              pt=     3
              c=regn  8
              rcr     10
              c=b     wpt
              rcr     4
              regn=c  8             ; store addr in Reg.8[13:10]
              ?s5=1                 ; alpha empty ?
              goc     ALNA60        ; no
              ?s3=1                 ; looking for file name ?
              gonc    FILNER        ; yes, say "NAME ERR"
              ?s1=1                 ; only looking for prog name ?
              rtn nc                ; yes, alpha empty is O.K.
              ?s10=1                ; current prog in ROM ?
              gonc    ALNA55        ; no
ROMERR:       gosub   ERROR         ; say "ROM"
              xdef    MSGROM
ALNA55:       gosub   GETPC         ; get current prog counter
              goto    ALNA70
ALNA60:       ?s1=1                 ; want to get prog addr ?
              rtn nc                ; no
              c=m
              regn=c  9
              gosub   ASRCH         ; search for the prog
              a=c                   ; save addr in A
              ?c#0                  ; found it ?
              gonc    FILNER        ; no, say "NAME ERR"
              ?s9=1                 ; micro code function ?
              goc     FILNER        ; yes, say "NAME ERR"
              ?s2=1                 ; program in ROM ?
              goc     ROMERR        ; yes, say "ROM"
              pt=     3
ALNA70:       gosub   FLINKA        ; find prog end addr
              rcr     4
              a=c                   ; A[7:4] = prog end addr
              rcr     4
              a=c     wpt           ; A[3:0] = prog end addr
              golong  CPGM10        ; get program head addr

              .public FILNER
FILNER:       gosub   APERMG
              .messl  "NAME"
              golong  DISERR

              .public GETREC
              .name   "GETREC"
GETREC:       s7=     1
              goto    GTRC05_1

              .public ARCLRC
              .name   "ARCLREC"
ARCLRC:       s7=     0
GTRC05_1:     goto    .+1
              enrom2
              golong  GTRC05

              .public LB_3581, LB_3583
LB_3581:      gosub   TGLSHF
LB_3583:      ?s1=1
              rtn nc
              c=m
              rcr     3
              a=c     x
              rcr     3
              ?s6=1
              gonc    LB_3591
              ?s2=1
              goc     LB_358E
              a=0     x
LB_358E:      ?s2=1
              gonc    LB_3591
              c=0     x
LB_3591:      rcr     3
              acex    x
              rcr     3
              pt=     7
              c=0     wpt
              a=c
              setdec
              a#0?
              goc     LB_359E
              ?s0=1
              gonc    LB_35AA
              pt=     4
              a=a+1   pt
LB_359E:      asr
              a=a+1   x
              a=a+1   x
              pt=     12
              goto    LB_35A5
LB_35A3:      asl     m
              a=a-1   x
LB_35A5:      ?a#0    pt
              gonc    LB_35A3
              ?s0=1
              gonc    LB_35AA
              a=a-1   s
LB_35AA:      sethex
              gosub   RSTKBT
              gosub   ENCP00
              c=regn  3
              regn=c  4
              acex
              regn=c  3
              gosub   PRT1
              golong  LB_563F       ; enable chip 0 and exit

;;; **********************************************************************
;;; * TXTEND - find the addr of the end of a text file
;;; *   input  : N= file header
;;; *            if S6 = 0 - find new record #
;;; *                    1 - point to current pointer
;;; *               S5 = 0 - go all the way to the end of file
;;; *                    1 - stop at current record #
;;; *               S8 = 0 - go to next record when advancing
;;; *                    1 - don't point to next record when at
;;; *                        end of record
;;; *   output : M[11:8] = current end of file mark addr
;;; *            B[6:4] = last record # + 1
;;; *            B[13:10] = current or last record addr
;;; *            if S1=1 - file empty
;;; *            if S2=1 - memory discontinuity detected
;;; *   used  A[7:0], B, C, S0, S1, S2, PT=3    +2 sub levels
;;; * CUREC# - routine to get the addr of current record
;;; *   input  : N = file header
;;; *   output : if S0=1 - the given record # > last record #
;;; *            then B[13:10]= last record addr
;;; *                 B[9:7]  = last record length
;;; *                 M[11:8] = end of file mark addr
;;; *            if S0=0 - found the given record
;;; *            then B[13:10]= the given record addr
;;; *                 B[9:7]  = the given record length
;;; *                 M[11:8] = current char addr
;;; *   used A[7:0], B, C, S0, S1, S2, PT=3   +2 sub levels
              .public TXTEND, `CUREC#`, `TOREC#`, TXTE10
TXTEND:       a=0     x
              ?s6=1                 ; find new rec # ?
              gonc    `REC#10`      ; yes
`CUREC#`:     s6=     1             ; stop at current record
              c=n
              rcr     3
              a=c     x
`REC#10`:     c=b
              rcr     4
              acex    x
              rcr     10
              bcex
`TOREC#`:     c=n
              rcr     10            ; C.X = header reg addr
              a=c     x
              pt=     3
              a=0     pt
              gosub   NXCHR         ; point to first byte in file
              s0=     0
              s1=     1
              c=b                   ; save first record addr in B[13:10]
              rcr     10
              c=a     wpt
              rcr     4
              bcex
TXTE10:       gosub   GTBYTA        ; get the record length
              c=0     xs
              b=c     x             ; save the record length in B.X
              c=c-1   xs            ; C.XS = F
              c=c+1   x             ; is this byte = "FF" ?
              goc     TXTE60        ; yes, got the end of text mark
              c=b
              rcr     4
              ?s6=1                 ; find new rec # ?
              goc     TXTE20        ; no
              c=c+1   x
              legal
              goto    TXTE40
TXTE20:       c=c-1   x             ; reached current rec # ?
              gonc    TXTE40        ; not yet
              s1=     0             ; current record exists
              rcr     6             ; save current rec addr in B[13:10]
              c=a     wpt
              rcr     11            ; save current rec len in B[9:7]
              c=b     x
              rcr     7
              bcex
              ?s5=1                 ; stop at current record ?
              gonc    TXTE50        ; no
              c=n
              rcr     6             ; C.X= current char #
              acex    x
              ?a<b    x             ; current char # < rec length ?
              goc     TXTE30        ; yes
              ?s8=1                 ; for DELREC or DELRECX ?
              goc     TXTE30        ; yes don't point to next record
              acex    x
              c=0     x             ; point to beginning of next record
              rcr     11
              c=c+1   x
              rcr     11
              n=c
              b=0     m             ; force it to follow the same path again
              goto    TXTE50
TXTE30:       acex    x
              c=c+1   x             ; C.X= current char # +1
              bcex    x
              gosub   ADVREB
              goto    TXTE70
TXTE40:       rcr     10
              bcex
TXTE50:       bcex    x
              c=c+1   x             ; pass current record
              bcex    x
              gosub   ADVREB        ; point to next record length
              ?s2=1                 ; memory discontinuity ?
              rtn c                 ; yes (are these two states needed?)
              goto    TXTE10
TXTE60:       s0=     1             ; reached end of file
TXTE70:       c=m                   ; save end of file mark addr in M[11:8]
              rcr     8
              acex    wpt
              rcr     6
              m=c
              rtn

;;; **********************************************************************
;;; * NWREC# - set new record #
;;; *   input  : B[6:4]= new record #
;;; *            M.X = new record length
;;; *            N= file header
;;; * UPREC# - update current record #
;;; *   input  : B[6:4]= current record #
;;; *            M.X= additional string length
;;; *            N= file header
;;; * UPRCAB - special entry point
;;; *   input  : A.X= current record #
;;; *            B.X= character position
;;; *            N= file header
;;; *   used  A.X, C,   +0 sub levels
              .public `NWREC#`, UPRCAB, STRCAB, `INREC#`
`NWREC#`:     c=b
              rcr     4
`INREC#`:     a=c     x             ; A.X= last record # + 1
              c=m
              bcex    x             ; B.X = alpha length
STRCAB:       c=n                   ; clear char pointer
              rcr     6
              c=0     x
              rcr     8
              n=c
UPRCAB:       c=n
              rcr     10            ; C.X = file header addr
              dadd=c
              rcr     7             ; C.X = current record pointer
              acex    x
              rcr     3
              abex    x
              c=a+c   x             ; extend char pointer
              rcr     8
              data=c
              rtn

              .name   "SAVEAS"
              .public SAVEAS
SAVEAS:       goto    .+1
              enrom2
              golong  SAVEAS2

              .public SWPT2
SWPT2:        s5=     1
              gosub   GTINDX
              c=0
              dadd=c
              c=regn  3
              a=c
              ldi     2
              gosub   UNNORM
              goto    LB_363F
              golong  ERRDE
LB_363F:      acex
              rcr     7
              bcex
              gosub   INITMR
              c=0
              dadd=c
              c=regn  13
              rcr     3
              a=c     x
              c=regn  3
              clr st
              ?c#0    s
              gonc    LB_364E
              s0=     1
LB_364E:      c=b
              ?c#0    xs
              gonc    LB_3652
              s4=     1
LB_3652:      acex    x
              rcr     6
              pt=     7
              c=0     wpt
              ?c#0    s
              gonc    LB_3659
              s4=     1
LB_3659:      acex    x
              rcr     8
              m=c
              gosub   CALCRC
              rcr     11
              bcex
              gosub   ENTMR
              regn=c  14
              s1=     1
              golong  LB_556C

              .name   "X>=NN?"
`X>=NN?`:     goto    .+1
              enrom2
              golong  `X>=NN? 2`

;;; **********************************************************************
;;; * FNDPIL - test if there is a HPIL module plug-in
              .public FNDPIL
FNDPIL:       c=0
              gosub   CHKCST        ; try to call a routine in HPIL module
              ?c#0                  ; if c=0 on return, we know it is there
              rtn c                 ; the module is not there
              gosub   APERMG
              .messl  "NO DRIVE"
              golong  APEREX

              .name   "POSFL"
              .public POSFL
POSFL:        gosub   CURFLT
              gosub   ALEN
              goto    .+1
              enrom2
              ?c#0    x
              golnc   APOSNF
              golong  APOS10

              .public RUNST2, LB_3698
RUNST2:       m=c
              gosub   LDSST0
              ?s13=1
              rtn c
              ?s4=1
              rtn c
LB_3698:      sethex
              c=stk
              c=c+1   m
              gotoc

              .name   "EMROOM"
              .public EMROOM
EMROOM:       goto    .+1
              enrom2
              golong  EMROOM2

              .public GETSUB, GETP
              .name   "GETSUB"
GETSUB:       s9=     0
              goto    RP100
              .name   "GETP"
GETP:         s9=     1
RP100:        goto    .+1
              enrom2
              golong  GETP2

              .public LB_36B7
LB_36B7:      enrom1                ; part of error return, ensure bank 1
              rcr     7
              regn=c  14
              rtn

KEYCAT:       c=0
              enrom1
              dadd=c
              s9=     0
LB_36BF:      regn=c  9
LB_36C0:      c=regn  9
              a=c     x
              gosub   TBITMP
              c#0?
              golong  LB_3756
              c=regn  9
              c=0     s
              c=c+1   s
              regn=c  9
              rcr     1
              a=c     x
              a=a+1   x
              s1=     0
              gosub   GCPKC
              a=c
              gosub   CLLCDE
              pt=     3
              ?s3=1
              goc     LB_36F6
              ?a#0    pt
              goc     LB_36DC
              gosub   PROMFC
              goto    LB_36E6
LB_36DC:      acex
              gosub   GTRMAD
              goto    LB_36EB
              ?s3=1
              goc     LB_36EF
              acex
              rcr     11
              gosub   PROMF2
LB_36E6:      gosub   LEFTJ
              gosub   ENCP00
              goto    LB_3706
LB_36EB:      s1=     0
              gosub   XROMNF
              goto    LB_3706
LB_36EF:      a=a+1
              a=a+1
              gosub   GTBYTO
              a=a+1
              s2=     1
              goto    LB_36FF
LB_36F6:      c=0     x
              pfad=c
              gosub   INCADA
              gosub   NXBYTA
              gosub   INCADA
              s2=     0
LB_36FF:      c=c-1   x
              b=a
              a=c     x
              s1=     0
              s8=     0
              gosub   TXTSTR
LB_3706:      c=regn  9
              a=c     x
              st=c
              ldi     48
              pt=     1
              ?a#c    pt
              gonc    LB_3712
              ldi     176
              ?a#c    pt
              goc     LB_3715
LB_3712:      ?a#0    xs
              gonc    LB_3715
              a=a-1   xs
LB_3715:      gosub   ENLCD
              c=regn  14
              c=regn  14
              pt=     1
              lc      8
              pt=     1
              ?s7=1
              gonc    LB_3723
              a=a+c   pt
              c=regn  14
              ldi     45            ; hyphen "-"
              regn=c  15
LB_3723:      a=a+1   xs
              acex    xs
              rcr     2
              acex    pt
              rcr     2
              c=c+1   s
              a=0     s
              a=a+1   s
              a=a+1   s
              gosub   GENN55
              gosub   ENCP00
              gosub   PRT12
              gosub   CHKLB2
              s9=     0
              c=regn  9
              pt=     12
              ?c#0    pt
              golc    LB_37A4
              ldi     900
LB_373C:      chk     kb
              goc     LB_3741
              c=c-1   x
              gonc    LB_373C
              goto    LB_3756
LB_3741:      gosub   CAT_STOP
              ?a#c    x
              goc     LB_374B
              c=regn  9
              pt=     12
              c=c-1   pt
              regn=c  9
              golong  LB_37CF
LB_374B:      ldi     403
LB_374D:      c=c-1   x
              gonc    LB_374D
              rst kb
              chk kb
              goc     LB_3756
              rst kb
              chk kb
LB_3754:      gosub   RSTKBT
LB_3756:      pt=     1
              lc      8
              pt=     1
              a=c     pt
              c=regn  9
              ?s9=1
              gonc    LB_3773
              a=a+c   pt
              goc     LB_376B
              c=c-1   xs
              gonc    LB_376B
              c=c-1   pt
              goc     LB_376E
              a=a-1   pt
              pt=     2
              lc      4
              lc      12
              pt=     1
              ?a<c    pt
              goc     LB_376B
              c=c-1   xs
LB_376B:      acex    pt
LB_376C:      regn=c  9
              goto    LB_3785
LB_376E:      c=0
              pt=     12
              c=c-1   pt
              s9=     0
              goto    LB_376C
LB_3773:      c=a+c   pt
LB_3774:      golnc   LB_36BF
              c=c+1   xs
              regn=c  9
              c=c+c   xs
              c=c+c   xs
              gonc    LB_3785
              c=c+c   pt
              c=c+c   pt
              goc     LB_3780
              ?c#0    xs
              gonc    LB_3785
LB_3780:      c=regn  9
              c=0     xs
              c=c+1   pt
              regn=c  9
              c=c+c   pt
LB_3785:      golnc   LB_36C0
              ?c#0    s
              gonc    LB_3790
              pt=     12
              ?c#0    pt
              gonc    LB_37AF
              s9=     1
              ldi     0x3f0
              goto    LB_3774

              .public LB_3790
LB_3790:      gosub   CLLCDE
              gosub   MESSL
              .messl  "CAT EMPTY"
              gosub   LEFTJ
              s8=     1
              gosub   MSG105
              golong  QUTCX
LB_37A4:      c=0
              pt=     7
              lc      2
LB_37A7:      chk     kb
              goc     LB_37B4
              ?lld
              gonc    LB_37AD
              c=c-1   m
              goc     LB_37AF
LB_37AD:      c=c-1   m
              gonc    LB_37A7
LB_37AF:      s7=     1
              gosub   TGLSHF2
              golong  QUTCAT
LB_37B4:      pt=     3
              sel p
              c=keys
              c=c+c   pt
              golc    LB_333E
              gosub   ENLCD
              c=regn  5
              st=c
              gosub   ENCP00
              ldi     5
              gosub   `KEY-FC2`
              .con    0xc2          ; SST
              .con    0x70          ; C
              .con    0x12          ; shift
              .con    0xc3          ; back arrow
              .con    0x87          ; R/S
              .con    0
              goto    LB_37EE
              goto    LB_37D2
              goto    LB_37E2
              goto    LB_37AF
              goto    LB_37E5
LB_37CF:      gosub   RSTKBT
              goto    LB_37A4
LB_37D2:      ?s7=1
              gonc    LB_37CF
              c=regn  9
              a=c     x
              b=a     x
              gosub   TBITMP
              gosub   SRBMAP
              abex    x
              asr     x
              a=a+1   x
              s1=     1
              gosub   GCPKC
              goto    LB_37E9
LB_37E2:      gosub   TGLSHF2
              goto    LB_37CF
LB_37E5:      c=regn  9
              pt=     12
              c=0     pt
              regn=c  9
LB_37E9:      s7=     1
              gosub   TGLSHF2
LB_37EC:      golong  LB_3754
LB_37EE:      ?s7=1
              gonc    LB_37EC
              s9=     1
              goto    LB_37E9

              .name   "GETAS"
              .public GETAS
GETAS:        goto    .+1
              enrom2
              golong  GETAS2

              .fillto 0x800
              .public GETXX, SAVEX
              .name   "SAVEX"
SAVEX:        s7=     1
              goto    GETX10
              .name   "GETX"
GETXX:        s7=     0
GETX10:       gosub   CURFLR
              c=n
              a=c     x             ; A.X= file size
              rcr     3
              c=c+1   x             ; C.X= current reg # + 1
              ?a<c    x             ; at EOF ?
              golc    EOFL
GETX20:       b=c     x
              b=0     pt
              rcr     7             ; C.X= file header addr
              dadd=c
              a=c     x
              rcr     4
              data=c
              gosub   ADVADR
              c=0
              dadd=c
              c=regn  3
              acex
              dadd=c
              ?s7=1
              goc     SAVX10
              c=data
              bcex
              golong  RCL
SAVX10:       acex
              data=c
              rtn

;;; **********************************************************************
;;; * SAPHSB - save alpha sub
;;; *   input  : chip 0 enable
;;; *            current working file is a text file
;;; *            if S8=0 leave byte for record length
;;; *               s8=1 adding chars only, no record length needed
;;; *   output : M[10:8]= current EOF mark addr or current pointer addr
;;; *            B[13:10]= current or last record addr
;;; *            B[9:7] = current record length
;;; *         if alpha is empty, it will exit to "NFRPU"
;;; * SAPHS5 - special entry point will not set S6=1
;;; *   input  : same as SAPHSB
;;; *   output : M[11:8] = current EOF mark address
;;; *            B[13:10] = first record address
;;; *            B[6:4] = new last record number
;;; *   both use  A, B, C, M, N, PT, S0-6   +3 sub levels
              .public SAPHSB, SAPHS5, LB_3837

SAPHSB:       s6=     1
SAPHS5:       gosub   ALEN
              ?a#0    x             ; alpha empty ?
              golong  NFRPU         ; yes, don't do anything
              c=regn  8             ; save alpha head addr in M[7:4]
              c=0     x
              rcr     6
              acex    x             ; save alpha length in M[2:0]
LB_3837:      m=c
              gosub   CURFLT        ; search for the current file
              gosub   TXTEND
              c=n                   ; B.X= file size in regs
              bcex    x
              b=0     pt
              rcr     10
              a=c     x             ; A.X= file header addr
              a=0     pt
              gosub   ADVADR        ; get last reg addr
              b=a     wpt
              c=m
              rcr     8
              a=c     wpt           ; A[3:0]= end of file mark addr
              gosub   CNTBYE        ; compute # of bytes between
              c=m                   ; get alpha length
              c=0     pt
              ?s8=1                 ; for char insert or append?
              goc     SAPH10        ; yes
              c=c+1                 ; reserve byte for record length
SAPH10:       ?a<c    wpt           ; enough room
              golc    EOFL          ; no, say "END OF FL"
              c=0
              c=stk                 ; get return addr
              rcr     4
              pt=     4
              lc      15
              stk=c                 ; push NFRPU on the stack
              rcr     10
              gotoc                 ; return to our caller

              .public SAVEP
              .name   "SAVEP"
SAVEP:        goto    .+1
              enrom2
              golong  SAVEP2

;;; Parto of ALM060
              .public LB_3863
LB_3863:      ?s4=1                 ; called from ALMNOW?
              golnc   ALM065
              s2=     0
              gosub   ALM200
              golong  ALM070

              goto    .+1
              enrom2
              golong  RSTKCA

              .public LB_386F
LB_386F:      a=c     x
              dadd=c
              c=data
              ?c#0    xs
              gonc    LB_3875
              a=a+1   x
LB_3875:      a=a+1   x
              rcr     1
              a=c     s
              rtn

              .public LB_3879
LB_3879:      lc      3             ; from SARO15 in cn9b
              pt=     0
              cxisa
              g=c
              c=c+1   m
              pt=     1
LB_387F:      c=c+1   m
              cxisa
              bcex    x
              c=c+1   m
              cxisa
              ?b#0    x
              goc     LB_388E
              ?c#0    x
              goc     LB_388E
              pt=     6
              lc      1
              lc      3
              lc      15
              golong  LB_263C

LB_388E:      bcex    x
              a=c
              rcr     5
              a=a+c   pt
              rcr     9
              acex    x
              rcr     12
              c=b     wpt
              n=c
              rcr     11
              acex    x
              c=c+c   xs
              c=c+c   xs
              c=c+c   xs
              gonc    LB_38B8
              c=c+1   m
              c=c+1   m
              a=c
              cxisa
              rcr     1
              a=c     s
              c=regn  9
              acex
              c=c-1   s
              c=c+1   m
LB_38A7:      c=c+1   m
              cxisa
              ?a#c    wpt
              goc     LB_38B6
              c=c-1   s
              asr
              asr
              ?c#0    s
              goc     LB_38B4
              ?a#0    wpt
              goc     LB_38B6
              s9=     0
              goto    LB_38D4
LB_38B4:      ?a#0    wpt
              goc     LB_38A7
LB_38B6:      rcr     5
              goto    LB_387F
LB_38B8:      a=c
              c=m
              acex
LB_38BB:      c=c-1   m
              cxisa
              ?c#0    wpt
              gonc    LB_38CE
              s8=     0
              cstex
              ?s7=1
              gonc    LB_38C5
              s7=     0
              s8=     1
LB_38C5:      cstex
              ?a#c    wpt
              goc     LB_38CE
              asr
              asr
              ?s8=1
              goc     LB_38D1
              ?a#0    wpt
              goc     LB_38BB
LB_38CE:      rcr     5
              golong  LB_387F
LB_38D1:      ?a#0    wpt
              goc     LB_38CE
              s9=     1
LB_38D4:      golong  SARO55
              .public LB_38D6
LB_38D6:      ?c#0    x             ; XKD?
              golnc   PARS59        ; XKD
              ldi     131
              a=c     x
              c=b
              rcr     3
              c=0     xs
              ?a#c    x
              goc     LB_38E6
              c=regn  14
              pt=     6
              c=c+c   pt
              c=c+c   pt
              c=c+c   pt
LB_38E6:      golong  PARS70
              c=regn  8
              rcr     13
              pt=     0
              a=a-1   pt
              ?a#c    pt
              goc     LB_38E6
              pt=     8
              c=-c-1  pt
              rcr     1
              regn=c  8
              golong  GTCNTR

              .public LB_38F4
LB_38F4:      sel q                 ; part of SW
              pt=     13
              sel p
              pt=     10
              ?c#0    pq
              golnc   TM10
              setdec
              a=0
              a=a-1
              pt=     8
              ?a#c    pq
LB_3900:      golnc   TM20
              c=0
              goto    LB_3900

              .public CLALMX2
CLALMX2:      gosub   INITMR
              gosub   LB_3274
              ?c#0    x
              gonc    LB_3913
LB_390A:      gosub   PUGALM
              rtn
              clr st
              golong  NXTALM

              .public CLALMA2
CLALMA2:      gosub   SRHBFI
              goto    LB_3914
LB_3913:      goto    LB_394A
LB_3914:      a=a+1   x
              c=0     x
              dadd=c
              c=regn  8
              pt=     6
              c=0     pq
              regn=c  8
              acex    x
              m=c
LB_391D:      gosub   LB_386F
              a=a-1   s
              goc     LB_395D
              c=m
              rcr     3
              acex    x
              rcr     11
              acex    s
              m=c
              gosub   FNDMSG
              c#0?
              gonc    LB_3947
              b=a     x
LB_392C:      c=m
              rcr     3
              dadd=c
              c=data
              a=c
              c=b     x
              dadd=c
              c=c-1   x
              bcex    x
              c=data
              a#c?
              gonc    LB_393D
              c#0?
              goc     LB_3947
              c=c+1   m
              a#c?
              goc     LB_3947
LB_393D:      ldi     4
              a=c     x
              c=m
              c=c+1   m
              c=c-1   s
              goc     LB_3959
              m=c
              ?a<b    x
              goc     LB_392C
LB_3947:      gosub   ALMSST
              goto    LB_391D
LB_394A:      gosub   APERMG
              .messl  "NO SUCH ALM"
              golong  APEREX
LB_3959:      ?a<b    x
              goc     LB_3947
LB_395B:      golong  LB_390A
LB_395D:      gosub   FNDMSG
              c#0?
              gonc    LB_395B
              goto    LB_3947

              .public RCLALM2
RCLALM2:      gosub   LB_3274
              ?c#0    x
              gonc    LB_394A
              c=0     x
              dadd=c
              c=regn  3
              regn=c  4
              c=regn  2
              bcex
              c=0     x
              dadd=c
              c=b
              data=c
              gosub   `A-DHMS`
              b=a
              pt=     8
              c=0     pq
              rcr     9
              dadd=c
              gosub   NORM
              regn=c  3
              abex
              gosub   DAYMDF
              regn=c  2
              c=m
              dadd=c
              c=data
              ?c#0    xs
              goc     LB_3986
              c=0
              dadd=c
              goto    LB_399A
LB_3986:      c=m
              c=c+1   x
              dadd=c
              c=data
              c=0     x
              rcr     2
              gosub   SDHMSC
              gosub   X20Q8
              csr
              c=a+c
              pt=     10
              c=0     pq
              rcr     11
              dadd=c
              c=c+1   x
              c=c+1   x
              gosub   NORM
LB_399A:      regn=c  1
              gosub   CLA
              c=m
              enrom2
              golong  LB_5A4F

              .name   "ED"
              .public ED
ED:           goto    .+1
              enrom2
              golong  ED2

              .public CRFLD, CRFLAS
              .name   "CRFLD"
CRFLD:        s7=     0
              goto    CRFL10

              .name   "CRFLAS"
CRFLAS:       s7=     1
CRFL10:       gosub   `X<999`       ; get the requested size and check
                                    ; if it is <= 999
              ?c#0    x             ; file size = 0 ?
              golong  ERRDE         ; yes, say "DATA ERROR"
              pt=     13            ; put the file type to C.S
              lc      2             ; data file type = 2
              ?s7=1                 ; create an ascii file ?
              gonc    CRFL20        ; no
              c=c+1   s             ; ascii file type = 3
CRFL20:       regn=c  9             ; save file size in Reg.9(X)
              gosub   GTFLNA        ; get file name
              s3=     1
              gosub   EFLSCH
              ?s0=1                 ; file already exists ?
              golc    0x30e8        ; yes, duplicate file error
CRF140:       c=0
              dadd=c
              c=regn  9
              a=c     x             ; A.X = requested file size
              a=a+1   x
              ?a<b    x             ; enough room ?
              golnc   NO_ROOM       ; no
CRF200:       c=0     m
              bcex                  ; save the header in B
              acex                  ; C[10:8]= addr of first available reg
              rcr     8             ; C.X= file name addr
              dadd=c
              a=c     x
              c=m
              data=c                ; store file name
              gosub   NXREG         ; point to file header reg
              c=a     x
              m=c                   ; save file header addr in M.X
              dadd=c
              c=b
              data=c                ; store file header
              n=c                   ; save file size in N.X
              s8=     1             ; set flag for writing EOF mark
CRF220:       ?s7=1                 ; create a text file?
              gonc    CRF250        ; no, it is a register file
              c=c-1   x
              n=c
              a=0     pt
              gosub   NXCHR
              ldi     255
              gosub   PTBYTA        ; store end of text mark
              acex    x             ; C.X= first reg addr
              m=c

;;; Now N.X= regs count, M.X= first reg addr
CRF250:       c=m
              a=c
              gosub   NXREG
              acex    x
              m=c
              dadd=c
              c=n
              c=c-1   x             ; all done ?
              goc     CRF270        ; yes
              n=c
              c=0
              data=c
              goto    CRF250
CRF270:       ?s8=1                 ; for clear file ?
              gonc    CRFLRT        ; yes, don't write EOF mark
              c=0
              c=c-1
              data=c
CRFLRT:       golong  NFRPU

;;; **********************************************************************
;;; * CLRFL - clear file
;;; *   File name is taken from alpha register. If alpha is empty,
;;; *   will generate "NAME ERR" error message.
;;; *
;;; *
              .public CLRFL

CLRFL:        s7=     0             ; assume it is a register file
              c=c-1   s
              goc     CLRF40        ; it is a register file
              s7=     1
CLRF40:       c=n
              rcr     10
              m=c
              a=c     x
              dadd=c
              rcr     7
              pt=     5
              c=0     wpt           ; set pointer to zero
              pt=     3
              rcr     11
              data=c
              s8=     0
              goto    CRF220

              .public CLRFL
              .name   "CLFL"
CLFL:         b=0     s
              gosub   FLSHAC
              c=n                   ; see what type it is
              c=c-1   s
              c=c-1   s
              gonc    CLRFL         ; not a prog file
              golong  FLTPER

;;; **********************************************************************
;;; * FLSHAP - get file entry
;;; *   input  : S0=0 - get current file entry
;;; *            s0=1 - get file entry by its name in the alpha register
;;; *                   if alpha is empty, it will default to current file
;;; * FLSHAB - special entry point
;;; * FLSHAC - special entry point
;;; *   output : N = file header
;;; *   used  A, B, C, M, N, PT, S0-7   +2 sub levels

              .public FLSHAP, FLSHAB, FLSHAC

FLSHAP:       b=0     s
              ?s0=1                 ; want current file ?
              gonc    FSA10         ; yes
FLSHAB:       c=regn  5
              ?c#0                  ; alpha empty ?
FSA10:        golong  CURFL         ; yes, default to current file
FLSHAC:       gosub   GTFLNA        ; get file name
              golong  RFLSCH        ; search for the file

RECLNG:       gosub   APERMG        ; say record too long
              .messl  "REC TOO LONG"
              golong  APEREX

              .public APPCHR, APCH10
              .name   "APPCHR"
APPCHR:       s7=     0
APCH05:       s8=     1
              gosub   SAPHSB
              ?s1=1                 ; file empty ?
              goc     INCR10        ; yes, generate a new record
APCH10:       c=b
              rcr     7             ; C.X= current record length
              a=c     x             ; save in A
              c=n
              rcr     6             ; C.X=current char position
              ?s7=1                 ; "INSCHR" ?
              goc     APCH20        ; yes
              acex    x             ; C.X = record length
              rcr     8             ; update character pointer
              n=c                   ;  to end of recod
              rcr     6             ; move N back into place
APCH20:       c=c+1   x
              bcex    x
              c=b
              rcr     10            ; C[3:0] = current record addr
              a=c     wpt
              gosub   ADVREB        ; point to starting char
              acex                  ; save start char addr in A[11:8]
              rcr     6
              a=c                   ; A[11:8]= starting char addr
              c=m
              a=c     x             ; A.X= alpha register length
              c=b
              rcr     7             ; C.X= current record length
              a=a+c   x             ; A.X = extended record length
              ldi     255
              ?a<c    x             ; record length > 254 ?
              gonc    RECLNG        ; yes
              rcr     3
              acex    wpt           ; A[3:0]= current record addr
              gosub   PTBYTA        ; update current record length
              c=n
              rcr     3             ; C.X= current record pointer
              a=c     x
              c=m
              bcex    x             ; B.X = alpha length
              gosub   UPRCAB        ; update current record & char pointer
              s7=     0
              c=m
              goto    INCR30

              .public INSCHR
              .name   "INSCHR"
INSCHR:       s7=     1
              goto    APCH05

INCR10:       golong  APPREC
              .name   "INSREC"
              .public INSREC, INCR20
INSREC:       s8=     0
              gosub   SAPHSB
              ?s1=1                 ; file empty ?
              goc     INCR10        ; yes
INCR20:       c=n
              rcr     3             ; update record & char pointer
              gosub   `INREC#`
              c=b
              rcr     2
              a=c                   ; A[11:8]= current record addr
              s7=     1
              c=m
              c=c+1   x             ; add 1 for record length
INCR30:       m=c
              rcr     4             ; C[7:4]= current EOF mark addr
              pt=     7
              a=c     wpt
              rcr     4
              pt=     3
              a=c     wpt           ; A[3:0]= current EOF mark addr
              acex                  ; save A in N
              n=c
              c=m
              bcex    x             ; B.X= alpha length
              gosub   ADVREB        ; point to new EOF mark
              c=n                   ; get addresses bak from N
              acex    wpt

;;; Make room for inserting the string.
;;; C[11:8]= current record addr
;;; C[3:0]= next store addr(EOF mark + # of bytes)
;;; C[7:4]= next pick addr(current EOF mark)

MKRM:         rcr     4
              a=c                   ; A[3:0]= next pick up addr
              gosub   GTBYTA        ; pick up next byte
              acex                  ; save the byte in A.X
              rcr     10
              acex                  ; A[3:0]= next store addr
              gosub   PTBYTA
              acex                  ; if the current pick up addr reached
              rcr     4             ;  original starting addr, we are done
              a=c                   ; A[3:0]= current pick up addr
              rcr     4             ; C[3:0]= original start addr
              ?a#c    wpt
              gonc    INCR40        ; all done
              s0=     0             ; decrease both addresses
MKRM30:       a=a+1   pt
              a=a+1   pt
              lc      14
              pt=     3
              ?a#c    pt            ; move over the edge of the reg ?
              goc     MKRM50        ; no
              gosub   LB_3B14
              a=0     pt
MKRM50:       acex                  ; addresses into C
              ?s0=1                 ; done with both addr ?
              goc     MKRM          ; yes
              rcr     10            ; put second addr in place
              a=c
              s0=     1
              goto    MKRM30

INCR40:       c=m
              rcr     4
              a=c     wpt           ; move M[7:4] to A[3:0]
              rcr     10
              c=c-1   x
              m=c
              ?s7=1                 ; for "INSREC"?
              gonc    PUTAPH        ; no
              goto    PUTA20

              .name   "APPREC"
              .public APPREC, APRC10
APPREC:       s6=     0
              s8=     0
              gosub   SAPHS5
;;; Now N = file header
;;;     M[2:0] = alpha length - 1
;;;     M[7:4] = alpha head addr
;;;     M[11:8] = current end of file mark addr
;;;     B[6:4] = last record # + 1
APRC10:       gosub   `NWREC#`      ; set current rec# = last rec #
              c=m                   ; move M[11:4] to A[7:0]
              rcr     4
              a=c
              rcr     10            ; C.X = record length
              goto    PUTA20

;;; **********************************************************************
;;; * PUTAPH = extend current record
;;; *   No special inputs.
;;; * PUTA20 - generate new record
;;; *   input  : C.X = new record length
;;; *  both -
;;; *   input : M[2:0] = # of bytes added - 1
;;; *           M[3:0] = starting source char addr
;;; *           A[7:4] = starting destination char addr
;;; *           S6 = 0 - will write end of text mark at end of record
;;; *                1 - will not         //
              .public PUTAPH
PUTAPH:       gosub   GTBYTA        ; get a byte from source
              gosub   INCADA        ; update source char addr
PUTA20:       acex                  ; move dest addr into place
              rcr     4
              acex
              gosub   PTBYTA
              gosub   NXCHR         ; point to next char addr in file
              c=m
              c=c-1   x             ; all done ?
              goc     PUTA30        ; yes
              m=c
              acex                  ; move source addr back into place
              rcr     10
              acex
              goto    PUTAPH
PUTA30:       ?s6=1                 ; write end of text mark ?
              rtn c                 ; no
              ldi     255
              golong  PTBYTA


              .name   "RESZFL"
              .public RESZFL
RESZFL:       goto    .+1
              enrom2
              golong  RESZFL2

;;; **********************************************************************
;;; *
;;; * KEY-FC - Read the key code to match the key code in key code table
;;; *          and jump to the corresponding point after the key code
;;; *          table.
;;; *
;;; * in:  key down C(1:0)= table length - 1, C.XS= 0
;;; * !!!! NOTE !!!! The last constant in the key code table must be 0 to
;;; *                mark the end of the table.
;;; * assume: hexmode
;;; * out: C.X= 0 (needed for digit keys)
;;; * used: A(X&M), C(X&M)
;;; *     (no ST, no PT, no DADD, no PFAD,  +0 sub levels, no timer chip access
;;; *
;;; *
;;; * Time= 7(key poisition in table) + 12   [including GSB & RTN]
              .public `KEY-FC2`
`KEY-FC2`:    c=0     m
              rcr     11            ; C(4:3)= table length
              a=c     m
              c=keys
              rcr     3
              a=c     x             ; A.X = key code
              c=stk                 ; get addr of key code table
KYFC10:       cxisa                 ; load a key code from table
              c=c+1   m
              ?c#0    x             ; reached end of table?
              gonc    KYFC30        ; yes, undefined key
              ?a#c    x             ; match the key code in table?
              goc     KYFC10        ; no
              c=0     x
KYFC30:       c=a+c   m
              gotoc

              .public LB_3B10
LB_3B10:      gosub   OFSHFT10      ; Patch for HP-41CX, turn off shift before
              golong  NAM44_        ; going to NAM44_

;;; Subroutine lifted from MKRM compared to original Extended Functions
              .public LB_3B14
LB_3B14:      ldi     0xef
              c=a     xs
              ?a#c    x             ; have we reached top of module ?
              goc     MKRM40        ; not yes
              ldi     1
              acex    xs            ; C.X= 201/301
              dadd=c
              c=data
              rcr     6             ; C.X= previous module addr
              a=c     x
              ?a#0    xs            ; previous module the base module ?
              gonc    MKRM40        ; yes, the preceeding reg is reg 0x41
              a=0     x
              acex    xs            ; A.X = 200/300
              a=a+1   x             ; A.X = 201/301
MKRM40:       a=a+1   x
              rtn

              .name   "GETKEYX"
              .public GETKEYX
GETKEYX:      goto    .+1
              enrom2
              golong  GETKEYX2

              .public NOREGCX
NOREGCX:      gosub   NOREG9
              gosub   PRT1
              golong  NFRPU

              .public CLOCK2
CLOCK2:       s3=     1
              cstex
              regn=c  4
              c=0
              c=c+1
              regn=c  5
              dadd=c
              s11=    1
              s13=    0
              gosub   RSTANN
              s1=     0
              s5=     1
              golong  DRSY30

              .fillto 0xc00
              .name   "XTOA"
              .public XTOA
XTOA:         c=regn  3
              b=c                   ; save X in B
              c=c-1   s
              ?c#0    s             ; does X have a string ?
              golong  XARCL         ; yes, just do a regular ARCL
              gosub   `X<256`       ; get int(X)
              pt=     0
              g=c
              golong  APPEND        ; shift the byte into the alpha register

              .name   "EMDIR"
              .public EMDIR, EMDR10, EMDR15
EMDIR:        b=0
              enrom1
              gosub   TMRSTS
              gosub   CLRALS
              gosub   `CUR#`        ; C.X = current file #
              a=c     x
              c=0     x
              rcr     11
              acex    x
              rcr     8
              data=c
EMDR10:       gosub   `CUR#`
              c=c+1   x             ; increment current file #
EMDR14:       rcr     5
              data=c
EMDR15:       s5=     1
              b=0     s
              c=0
              m=c                   ; guarantee won't find any file name
              gosub   CURFLD        ; get next file
              ?s5=1                 ; reached end of dir ?
              gonc    EMDR60        ; yes
              gosub   CLLCDE
              pt=     3             ; count characters in A.M
              c=0
              lc      6
              a=c     m             ; A.M = 6
EMDR20:       c=m                   ; send the file name to the display
              rcr     12
              m=c
              gosub   ASCLCD        ; send the ASCII to display
              a=a-1   m             ; done with 7 chars ?
              gonc    EMDR20        ; not yet
              ldi     32
              slsabc                ; send a blank
              c=n
              ldi     256           ; start at 256 so that dividing by 4
                                    ;  twice will get it to to 16 for ASCII P
EMDR30:       c=c+c   x             ; divide by 4 to get next
              c=c+c   x             ;  file type character
              csr     x             ; C.X = 4 (D) or 1 (A)
              c=c-1   s             ; file type reached zero yet ?
              gonc    EMDR30        ; no, divide and decrement again
DSFLTP:       slsabc                ; send file type character to display
              c=n                   ; send file size
              pt=     13
              lc      3
              a=c                   ; 3 digits for file size
              gosub   GENNUM
              gosub   ENCP00
              c=regn  8
              c=0     s
              regn=c  8
              gosub   PRT12
              enrom2
              golong  EMDIR2

EMDR60:       pt=     11
              ?b#0    pt
              gonc    EMDR51
              c=data
              rcr     9
              c=c-1   x
EMDR50:       gonc    EMDR14
EMDR51:       gosub   RSTKBT
              abex    x             ; A.X = # of reg still available
              ldi     2
              a=a-c   x             ; reserve 2 regs for file name & header
              gonc    EMDR70
              a=0     x
EMDR70:       gosub   `BIN-D`       ; convert to decimal
              c=0
              dadd=c
              ?s11=1                ; push flag set ?
              gsubc   R_SUB         ; push stack if yes
              bcex
              regn=c  3             ; put the available regs # to X
              gosub   LB_33F5
              a=a-1   x
              a=a-1   x
              goc     EMDR80
              gosub   PRT1
              golong  LB_563F       ; enable chip 0 and exit
EMDR80:       gosub   CLLCDE
              gosub   MESSL
              .messl  "DIR EMPTY"
              gosub   LEFTJ
              s8=     1
              gosub   MSG105
              golong  NFRPR

;;; **********************************************************************
;;; * EFLSCH - external memory file search
;;; *   input  : M = left justified target file name
;;; *            if S3=1, when the first available reg addr is "0BF",
;;; *                     it will write "000000000000BF" to reg.40
;;; *            if S3=0, won't do anything to reg.40
;;; *   output : if S0=1, file is found, then :
;;; *              A[10:8] = first reg addr of the file (file name reg)
;;; *              N = file header (second reg of the file)
;;; *              N[12:10] = addr of file header
;;; *            if S0=0, file is not found, then :
;;; *              A[10:8] = first available register addr
;;; *              B.X = # of register still available
;;; *              PT = 3
;;; * uses  A, B.S, B[6:0], C, N, S0, S1, S2, PT   +2 sub levels
              .public EFLSCH, FSCHT, FSCHP, RFLSCH
              .public CURFL, CURFLD, CURFLT, CURFLR, EFLS02
CURFLR:       pt=     13
              lc      2
              goto    CURFL0
CURFLT:       pt=     13
              lc      3
CURFL0:       bcex    s
CURFL:        s5=     0
CURFLD:       s4=     1
              s3=     0
              goto    EFLS05
FSCHP:        pt=     13
              lc      1
              goto    FSCH10
FSCHT:        pt=     13
              lc      3
FSCH10:       bcex    s             ; save the file type in B.S
RFLSCH:       s3=     0
EFLSCH:       s4=     0
EFLS02:       s5=     0             ; not for directory
EFLS05:       s0=     0
              s1=     0
              s2=     0
              a=0
              ldi     0x40
              dadd=c
              ldi     0xbf
              a=c     x
              c=data                ; load reg 40
              ?a#c    x             ; has reg 40 been initialized ?
              gonc    EFLS08        ; yes, at least 1 file exists
EFLS07:       s1=     1             ; say end of directory reached
              goto    EFLS10
EFLS08:       ?s4=1                 ; for current file ?
              gonc    EFLS10        ; no
              rcr     9             ; C.X = current file number
              c=c-1   x
              golc    FLNOFN        ; current file # = 0
              bcex
              rcr     4             ; save current file # -1 in B[6:4]
              bcex    x
              rcr     10
              bcex
EFLS10:       c=a                   ; save last file addr in A[10:8]
              rcr     8
              acex    x
              rcr     3
              c=c+1   x             ; increment file # an A[13:11]
              rcr     3
              a=c
              ?s1=1                 ; reached end of dir ?
              goc     EFLS70        ; yes
              dadd=c                ; enable file name reg
              c=data
              acex                  ; A= file name, C= addr
              cmex                  ; C= target name, M=addr
              ?a#c                  ; is this the file ?
              goc     EFLS20        ; no
              s0=     1             ; remember found it
EFLS20:       cmex                  ; C=addr, M=target name
              acex                  ; A=addr, C=file name
              c=c+1                 ; reached end of dir ?
              goc     EFLS75        ; yes, compute available regs
              ?s5=1                 ; for directory ?
              gonc    EFLS30        ; no
              c=c-1
              m=c                   ; save the file name in M
EFLS30:       gosub   ADVAD1        ; point to next register
              ?s2=1                 ; memory discontinuity ?
              goc     EFLS70        ; yes
              c=a     x
              dadd=c
              c=data                ; load file header reg
              rcr     10
              c=a     x             ; save header addr in N[12:10]
              rcr     4
              n=c                   ; save file header in N
              c=c+1   x             ; file length + 1 in registers
              bcex    x             ; to B.X
              gosub   ADVADR        ; point to next file name reg
              ?s2=1                 ; memory discontinuity ?
              goc     EFLS70        ; yes
              ?s4=1                 ; looking for current file ?
              goc     EFLS60        ; yes
              ?s0=1                 ; found the file yet ?
              goc     EFLS85        ; yes
              goto    EFLS10
EFLS60:       c=b
              rcr     4
              c=c-1   x
              goc     EFLS85        ; reached current file
              rcr     10
              bcex
              goto    EFLS10
EFLS70:       s0=     0             ; say file not found
              c=a                   ; find out available regs
              rcr     8
              a=c     x             ; A.X= first available reg addr
              dadd=c
              c=0
              c=c-1
              data=c
EFLS75:       ?s3=1                 ; for read ?
              goc     EFLS76        ; no, for write
              ?s5=1                 ; for directory ?
              gonc    FLNOFN        ; no file not found
              s5=     0
EFLS76:       gosub   ENRGAD        ; get last reg addr in this module
              a=a-c   x             ; A.X= available regs in this module
              a=a-1   x             ; reserve one reg for end of mem mark
              b=a     x             ; B <- registers left in present module
              acex    x
EFLS80:       gosub   NXTMDL        ; look for next module
              ?a#0    x             ; is there a next module ?
              gonc    EFLS90        ; no
              ldi     238           ; add 238 to B.X
              acex    x
              a=a+b   x
              b=a     x
              a=c     x
              pt=     6
              ?a#0    pt            ; are we coming from 201 or 301 ?
              goc     EFLS90        ; yes, don't look for another module
              goto    EFLS80
EFLS85:       s0=     1             ; file found, this is needed in the case we
                                    ;  are looking for current file, we found it
              ?s3=1                 ; for write ?
              goc     EFLS90        ; yes, don't care about file type
              c=n                   ; it is for read, check file type
              rcr     11            ; C.XS = file type
              a=c     xs            ; A.XS = file type in ex. mem
              c=b     s             ; C.S = file type looked for
              rcr     11            ; C.XS = file type looked for
              ?b#0    s             ; need to check file type ?
              gonc    EFLS90        ; no
              ?a#c    xs            ; same file type ?
              gonc    EFLS90        ; yes

              .public FLTPER, FLNOFN
FLTPER:       gosub   APERMG
              .messl  "FL TYPE"
              golong  DISERR
FLNOFN:       gosub   APERMG
              .messl  "FL NOT FOUND"
              golong  APEREX

EFLS90:       pt=     3
              ldi     0x40
              dadd=c
              ?s4=1                 ; looking for current file ?
              goc     EFLS92        ; yes
              c=a
              rcr     11            ; C.X = file #
              a=c     x
              c=data
              rcr     9
              acex    x             ; save current # reg.40[11:9]
              rcr     5
              data=c

;;; If the new file is starting at BF, it will write
;;; 000010000000BF to reg.40
EFLS92:       ?s1=1                 ; base reg initialized ?
              rtn nc                ; yes
              c=0                   ; write 000010000000BF to reg.40
              c=c+1
              rcr     5
              ldi     0xbf
              data=c
              rtn

              .public DELCHR, DELREC, DLRC30, DLRC50
              .name   "DELCHR"
DELCHR:       s7=     1
              goto    DLRC10
              .name   "DELREC"
DELREC:       s7=     0
DLRC10:       gosub   CURFLT        ; get current file
              s5=     1
              s8=     1             ; don't go to next rec when at end of rec
              gosub   `CUREC#`
              ?s0=1                 ; reached end of file ?
              golc    EOFL          ; yes, say "END OF FL"
              ?s7=1                 ; for "DELCHR" ?
              gonc    DLRC50        ; no, is for "DELREC"
              c=0
              dadd=c
              gosub   `X<999`       ; get integer of X
              c=m                   ; save int(X) in M.X
              acex    x
              m=c
              c=b
              rcr     7
              a=c     x             ; A.X = current record length
              c=n
              rcr     6             ; C.X= current char pointer
              a=a-c   x             ; A.X= # remaining chars in rec
              bcex    x             ; B.X= current char pointer
              c=m                   ; C.X= # of chars to delete
              acex    x             ; A.X= # to del  C.X= # remaining
              ?a<c    x             ; del to end of rec ?
              goc     DLRC30        ; no
              ?b#0    x             ; starting from char zero ?
              gonc    DLRC50        ; yes, delete entire record
              a=c     x             ; only delete remaining chars
DLRC30:       b=a     x             ; B.X= # of chars to delete
              acex    x             ; A.X= # to del;  C.X= # left
              c=a-c   x             ; C.X= chars to end of rec
              n=c                   ; save in N.X
              c=m                   ; save # to del in M.X
              c=b     x
              a=c     x             ; # to del back to A.X
              m=c
              c=b
              rcr     7             ; C.X= current record length
              acex    x
              a=a-c   x             ; A.X= # of char left in rec
              rcr     3             ; C[3:0]= current record addr
              acex    wpt
              gosub   PTBYTA        ; update record length
              c=m                   ; C.X= # of chars to delete
              bcex    x
              rcr     8
              a=c     wpt           ; A[3:0]= current pointer addr
              gosub   ADVREB        ; skip over deleted string
              c=m
              rcr     4             ; C[7:4]= current pointer addr
              goto    DLRC60
DLRC50:       c=n
              rcr     6             ; set current char pointer to zero
              c=0     x
              n=c                   ; set N.X = 0 for # chars to end of rec
              rcr     4
              dadd=c                ; address header register
              rcr     4
              data=c                ; update file pointer
              c=b
              rcr     10            ; C[3:0] = current record addr
              a=c     wpt
              gosub   ADVREC        ; point to next rec
              c=b
              rcr     6             ; C[7:4]= current pointer addr
DLRC60:       acex    wpt
              a=c

;;; now A[3:0] = byte addr of next pick up byte
;;;     A[7:4] = byte addr of next storing byte
;;;     N.X = # of chars to end of record
DELB10:       s0=     0             ; not end of file yet
              gosub   GTBYTA        ; get next record length
              cnex                  ; get # of chars left in rec
              c=c-1   x             ; done with record yet ?
              gonc    DELB15        ; no, continue
              c=n
              c=0     xs            ; C.X= # of chars in next rec
              pt=     1
              c=c+1   wpt           ; end of file ?
              gonc    DELB14        ; no
              s0=     1             ; remember end of file
DELB14:       c=c-1   wpt           ; restore record length
              pt=     3
DELB15:       cnex                  ; chrs left to N; next byte to C
              acex
              rcr     4
              acex                  ; A[3:0] = next storing addr
              gosub   PTBYTA        ; store the byte
              ?s0=1                 ; reached end of file mark ?
              rtn c                 ; yes, all done

;;; now try to advance both next pick up and next store addr
DELB30:       a=a-1   pt
              gonc    DELB60        ; still in the same reg
              a=a-1   x
              ldi     0x40
              ?a#0    xs            ; are we in the base module ?
              gonc    DELB40        ; yes
              ldi     1
              c=a     xs
DELB40:       ?a#c    x             ; about to turn over to next module ?
              goc     DELB50        ; not yet
              dadd=c
              c=data
              rcr     3             ; C.X = next module addr
              a=c     x
DELB50:       a=a-1   pt            ; finish changing byte number
              a=a-1   pt
DELB60:       a=a-1   pt
              ?s0=1                 ; done with both addr ?
              goc     DELB10        ; yes, move another byte
              acex                  ; get ready to adjust first address
              rcr     10
              acex
              s0=     1             ; flag for second adjustment
              goto    DELB30

              .public PURFL
              .name   "PURFL"
PURFL:        clrabc                ; guarantee will not say "NO ROOM" and
              regn=c  9             ;  don't check file type
              gosub   FLSHAC
;;; fall into "PUFLSB" routine from here

;;; **********************************************************************
;;; * PUFLSB - purge file subroutine
;;; *   Purging a file without an end of memory mark (FFFFFF...) in the
;;; *   memory will cause part of the last file to be filled with zeros.
;;; *   In order to prevent this, we always write the end of memory mark
;;; *   to the first unusd reg before pruging a file. This routine is
;;; *   also used by the function "SAVEP".  When it is called by "SAVEP"
;;; *   it will either purge the old file, or it will say "NO ROOM" if
;;; *   after purging the old file there still won't be enough room to
;;; *   put in the new file.  To make sure that the "PURFL" function will
;;; *   never say "NO ROOM", reg.9 is cleared at the beginning of "PURFL".
;;; * input : A[10:8] = file name addr of the file to be purged
;;; *         N       = file header
;;; *         Reg.9[2:0] = # of registers needed for the new file

              .public PUFLSB
PUFLSB:       b=a                   ; save start reg addr of the file in B
              c=n
              c=0     m             ; make sure that the name won't be found
              m=c                   ; save file header in M
              s3=     1
              gosub   EFLSCH        ; find out available registers
              c=m                   ; C.X= old file size
              abex                  ; A.X= # of regs unused
              a=a+c   x             ; A.X= total # of registers available
              c=c+1   x
              c=c+1   x             ; C.X= file size + 2
              c=0     pt
              bcex    wpt           ; B[3:0]= file size + 2
              c=0
              dadd=c
              c=regn  9             ; C.X= new prog size
              ?a<c    x             ; enough room to put in the new one ?
              golc    NO_ROOM       ; no, say "NO ROOM"
;;; Now A[10:8] = addr of file name of the file
;;;     B[10:8] = addr of the last reg of ex.mem
;;;     B[3:0]  = file size + 2
;;;     M       = file header
              gosub   `CUR#`        ; set current file # to zero
              c=0     x
              rcr     5
              data=c
              acex
              a=c
              rcr     8
              a=c     wpt           ; A[3:0]= addr of file name (first reg of file)
              gosub   ADVADR        ; pass over current file and point
                                    ;  to next file name
              acex    m             ; move A[10:8] to B.X
              rcr     8
              bcex    x
;;; Now B.X = next storing reg addr
;;;     A.X = next pull up reg addr
;;;     B[10:8] = address of end of memory mark

              .public PAKEXM
PAKEXM:       acex    x             ; C.X = next pull up addr
              dadd=c
              acex    x             ; A.X = next pull up addr
              c=data
              bcex                  ; save next pull up reg & get storing addr
              dadd=c
              bcex
              data=c                ; pull up one reg
              c=b     m
              rcr     8             ; C.X = end of memory mark address
              ?a#c    x             ; is this end of dir mark ?
              rtn nc                ; if so, all done
              s0=     0
PKRG20:       a=a-1   x
              ldi     0x40
              ?a#0    xs            ; are we in base module
              gonc    PKRG30        ; yes
              ldi     1
              c=a     xs
PKRG30:       ?a#c    x      ; reached last reg in the module ?
              goc     PKRG40        ; no
              gosub   NXTMDL        ; go over to next module
PKRG40:       abex    x
              ?s0=1                 ; update both addr yet ?
              goc     PAKEXM        ; yes
              s0=     1
              goto    PKRG20        ; update storing addr

              .public SAVERX, GETRX
              .name   "SAVERX"
SAVERX:       s7=     1
              goto    GETR10

              .name   "GETRX"
GETRX:        s7=     0
GETR10:       gosub   CURFLR        ; get current register file
              c=n
              m=c                   ; save file header in M temp.
              s5=     1
              gosub   GTINDX        ; get BBB.EEE from X
              c=n
              a=c     x             ; end address to A.X
              rcr     3             ; start address to C.X
              a=a-c   x             ; A.X <- # of regs -1
              gonc    GETR15        ; if end > start, then skip
              a=0     x             ;   setting # regs = 1
GETR15:       rcr     11            ; put block size in C
              acex    x
              a=c     x
              rcr     11            ; rotate C back
              cmex                  ; save in M
              n=c                   ; previous M -> N
;;; now M[5:3]= # of regs -1
;;;;    M[8:6]=     R.M. starting reg addr
;;;     N[2:0]= file size in regs
;;;     N[5:3]= current reg # in file
;;;     N[12:10]= file header addr
;;;     A.X= # of regs -1
              bcex    x             ; B.X= file size
              rcr     3             ; C.X= current reg #
              a=a+c   x             ; A.X= last reg #
              ?a<b    x             ; enough room ?
              gonc    EOFL          ; no, say "END OF FL"
              c=c+1   x             ; C.X= current reg # + 1
              bcex    x             ; B.X = current reg # + 1
              c=m
              acex    x
              m=c                   ; M.X= current last reg #
              c=n
              rcr     10
              acex    x             ; A.X= file header addr
              pt=     3
              b=0     pt
              gosub   ADVADR        ; point to start reg addr in e.m.
              c=m
              bcex
;;; now B[8:6]= starting reg addr in resident memory
;;;     B[5:3]= # of regs -1
;;;     B[2:0]= current last reg #
              goto    SAVR20

;;; **********************************************************************
;;; * SAVER - Save all resident registers to a given register file.
;;; * GETR - Load up the resident registers from a given register file.
;;; *        The file name is taken from the alpha register.
;;; *        If the file name is empty, it will default to current file.
;;; **********************************************************************
              .public SAVER, GETR
              .name   "GETR"
GETR:         s7=     0
              goto    SAVR05
              .name   "SAVER"
SAVER:        s7=     1
SAVR05:       pt=     13
              lc      2             ; type of data file = 2
              bcex    s
              gosub   FLSHAB        ; search current file or the given file
                                    ;  and check its type (data file)
              gosub   FNDEND        ; find first nonexistent reg addr
              c=0
              dadd=c
              c=regn  13
              rcr     3             ; C.X= reg 0 addr
              a=a-c   x             ; A.X= # of resident registers
              a=a-1   x
              rtn c                 ; size = 0, don't do anything
              bcex    x             ; save reg0 addr in B.X
              c=n                   ; C.X = file size
              ?a<c    x             ; will it fit ?
              goc     SAVR10        ; yes
              ?s7=1                 ; from "GETR"
              gonc    SAVR07        ; yes
              .public EOFL
EOFL:         gosub   APERMG
              .messl  "END OF FL"
              golong  APEREX
SAVR07:       c=c-1   x             ; just read to end of file
              acex    x             ; A.X= last reg #
SAVR10:       c=b     x             ; C.X= reg 0 addr
              b=a     x             ; B.X = last reg number
              rcr     11
              acex    x             ; C.X = # of regs - 1
              rcr     11
              bcex    m             ; B[8:6]=reg0  B[5:3]= # of regs -1
              c=n
              rcr     10
              a=c     x             ; A.X = file header addr
              gosub   NXREG         ; point to start reg addr
SAVR20:       abex    m
              c=n
              rcr     10
              dadd=c
              rcr     7             ; C.X= current reg #
              c=b     x             ; C.X= last reg #
              c=c+1   x             ; update current reg #
              rcr     11
              data=c
              acex
              n=c
              s5=     0
              s4=     0
              ?s7=1                 ; for save ?
              goc     SAVR50        ; yes
              acex    x             ; exchange the source and target addr
              rcr     6
              acex    x
              rcr     8
              acex    x
              n=c
              s1=     0
              s0=     1
              goto    RGMV
SAVR50:       s1=     1
              s0=     0
              goto    RGMV

              .public REGSWP, REGMOV
;;; **********************************************************************
;;; * REGMV - Move a block of registers to another data register space.
;;; *  The register index is taken from X in SSS.DDDNNN form, where SSS
;;; *  is the source reg #, DDD is the destination reg #, NNN is the
;;; *  number of regs to move,
;;; * REGSWP - Exchange two register blocks. This function takes the
;;; *  same argument from X register and performs a similar operation;
;;; *  it will exchange the two blocks rather than just copy from one to
;;; *   another.
;;; **********************************************************************
              .name   "REGSWAP"
REGSWP:       s4=     1             ; set exchange flag
              goto    REGM10

              .name   "REGMOVE"
REGMOV:       s4=     0             ; clear exchange flag
REGM10:       s5=     0             ; set reg index flag
              gosub   GTINDX
;;; Now N[2:0] = # of regs to move
;;;     N[5:3] = destination reg address
;;;     N[8:6] = source reg address
;;;     A.X    = reg 0 addr
;;;     B.X    = first nonexistent reg addr
              ?c#0    x             ; NNN = 0 ?
              gonc    REGM20        ; yes, default to 1
              c=c-1   x             ; C.X= # of regs -1
REGM20:       n=c                   ; N.X= # of regs -1
              a=c     x
              rcr     3             ; C.X= first destination reg addr
              c=a+c   x             ; C.X= last destination reg addr
              rcr     3             ; C.X= first source reg addr
              c=a+c   x             ; C.X= last destination reg addr
              legal
              gosub   CHKADR        ; see if last reg exist ?
              rcr     11            ; C.X= last destination reg addr
              gosub   CHKADR        ; see if that reg exist
              a=c     x             ; A.X= last destination reg addr
              rcr     3             ; C.X= last source reg addr
              ?a<c    x
              goc     REGM30        ; start from bottom and increment addr
              s5=     1
              rcr     8
              n=c                   ; start from top and decrement addr
REGM30:       c=n
              a=c                   ; switch N[5:3] with N[2:0]
              rcr     3
              acex    x
              rcr     11
              acex    x
              n=c
              s0=     0
              s1=     0             ; say source and destination all in main memory
;;; fall into "RGMV" routine from here

;;; **********************************************************************
;;; * RGMV - moves a block of registers to another location.
;;; *   input  : N[2:0] = starting reg addr of destination
;;; *            N[5:3] = # of regs to move - 1
;;; *            N[8:6] = starting reg addr of source
;;; *            if S0 = 0 - source is in main memory
;;; *                  = 1 - source is in external memory
;;; *            if S1 = 0 - destination is in main memory
;;; *                  = 1 - destination is in external memory
;;; *            if S4 = 0 - only move source to destination
;;; *                  = 1 - exchange source and destination
;;; *            if S5 = 0 - start from lowest reg addr and increment
;;; *                  = 1 - start from highest reg addr and decrement
;;; *                    (used only in REGMOVE and REGSWAP)
;;; *   output : if S2 = 1 - discontinuity in memory detected
;;; *   uses  A, B, C, M, PT, S2   +1 sub level
;;; *
              .public RGMV
RGMV:         s2=     0
              c=n
              rcr     6             ; C.X= next source reg addr
              dadd=c
              c=data                ; load next source reg
              bcex                  ; save in B
              c=n                   ; C.X= next destination reg addr
              dadd=c
              c=data                ; load next destination reg
              bcex
              data=c                ; put source to destination
              ?s4=1                 ; exchange ?
              gonc    RGMV10        ; no
              c=n
              rcr     6
              dadd=c                ; select source again
              c=b
              data=c
RGMV10:       c=n
              rcr     3             ; C.X= regs count
              c=c-1   x             ; decrement regs count
              rtn c                 ; all done
              rcr     3             ; C.X= current source addr
              s3=     0             ; flag for source address update
              ?s0=1                 ; source in main memory ?
              goc     RGMV20        ; no, in external memory
RGMV12:       ?s5=1                 ; start from top to bottom ?
              gonc    RGMV13        ; no, bottom to top
              c=c-1   x             ; decrement register address
              legal
              goto    RGMV15
RGMV13:       c=c+1   x             ; increment register address
RGMV15:       n=c
              ?s2=1                 ; memory discontinuity ?
              rtn c                 ; yes
              ?s3=1                 ; destination address updated yet ?
              goc     RGMV          ; yes
              rcr     8             ; C.X= current destination address
              s3=     1             ; flag for destination address update
              ?s1=1                 ; destination reg in external memory ?
              gonc    RGMV12        ; no
RGMV20:       n=c
              a=c
              gosub   ADVAD1        ; advance one reg in ext memory
              c=n
              acex    x
              goto    RGMV15

;;; **********************************************************************
;;; * BYTLFT - compute # of bytes left at the end unused
;;; *   input  : N= file header
;;; *            A[3:0]= addr of end of record mark
;;; *   output : A[3:0]= # of byte available
;;; *            A[11:8]= addr of current end of record mark
;;; *   used A[11:0], B[3:0], C  +2 sub level
              .public BYTLFT
BYTLFT:       acex
              rcr     6             ; save end addr in A[12:8]
              a=c
              c=n
              bcex    x             ; B.X= file size in regs
              b=0     pt
              rcr     10
              a=c     x             ; A.X= file header addr
              a=0     pt
              gosub   ADVADR        ; get last reg addr
              b=a     wpt
              acex
              a=c
              rcr     8
              a=c     wpt           ; A[3:0]= end of record mark addr
              golong  CNTBYE        ; compute # of bytes between

              .public SEKPTA, SEKPT
              .name   "SEEKPT"
SEKPT:        s0=     0
              goto    SKPT10
              .name   "SEEKPTA"
SEKPTA:       s0=     1
SKPT10:       gosub   FLSHAP
              c=0
              dadd=c
              gosub   `X<999`       ; get integer of X in binary
              rcr     10
              bcex    m             ; B[6:4]= given pointer
              a=0     s
              a=a+1   s
              a=a+1   s
              c=n
              rcr     10            ; C.X= file header addr
              dadd=c                ; enable file header reg
              rcr     7             ; save given rec ptr in N[5:3]
              c=a     x
              rcr     3
              c=0     x             ; set char pointer to zero
              rcr     8
              n=c
              enrom2
              golong  SEEKP2

              .public RCLPTA, RCLPT, RCLP30
              .name   "RCLPT"
RCLPT:        s0=     0
              goto    RCLP10
              .name   "RCLPTA"
RCLPTA:       s0=     1
RCLP10:       gosub   FLSHAP
RCLP30:       c=n
              rcr     3             ; C.X = current file pointer
              acex    x
              gosub   `BIN-D`       ; convert to decimal
              c=b
              cnex                  ; save record pointer in N
              rcr     6             ; C.X= char pointer
              a=c     x
              gosub   `BIN-D`       ; convert to decimal
              abex
              setdec
              ?a#0    m             ; char pointer = 0 ?
              gonc    RCLP40        ; yes
              ldi     3
              a=a-c   x             ; divide char ptr by 1000
RCLP40:       c=n
              gosub   AD2_10        ; add rec and char pointer together
              bcex
              golong  RCL

;;; **********************************************************************
;;; * APERMG - entry point to print error message
;;; * APEREX - error exit entry point
;;; * DISERR - display " ERR" and fall into APEREX
;;; *
              .public DISERR, APERMG, APEREX
DISERR:       gosub   MESSL
              .messl  " ERR"
APEREX:       gosub   LEFTJ
              s8=     1
              gosub   MSG105
              golong  ERR110
APERMG:       gosub   ERRSUB
              gosub   CLLCDE
              golong  MESSL


              .public CAT_END3
CAT_END3:     gosub   ENCP00
              s8=     0
              gosub   IAUALL        ; printer rom
              goto    LB_3F9C
              c=0
              pt=     6
              lc      6
              lc      15
              lc      15
              lc      12
              cxisa
              pt=     0
              c=c-1   pt
              c=c-1   pt
              gosub   UNL           ; send unlisten
              goto    LB_3FC8
LB_3F9C:      gosub   GETPCA
              gosub   INCAD
              b=a     wpt
              gosub   INCAD
              gosub   NXBYTA
              st=c
              pt=     1
              c=c+1   pt
              goc     LB_3FC8
              pt=     3
              acex    wpt
              m=c
              ?s5=1
              goc     LB_3FC8
              abex    wpt
              gosub   CPGMHD
              c=m
              bcex    wpt
              gosub   CNTBY7
              ldi     16
              dadd=c
              a=0     s
              gosub   GENNUM
              gosub   ENLCD
              abex    s
              b=a     s
              a=a-1   s
LB_3FC0:      rabcr
              a=a-1   s
              gonc    LB_3FC0
              abex    s
              acex    m
              rcr     13
              gosub   GENN55
LB_3FC8:      golong  END3

;;; **********************************************************************
;;; * GFLG31 = get flag 31                                    12-18-80 RSW
;;; *
;;; * IN: A.X must be non-zero
;;; * ASSUME: hexmode
;;; * OUT: C[6]= 0 if flag 31= 0   (MDY)
;;; *      C[6]= 1 if flag 31= 1   (DMY)
;;; *      chip 0 enabled, PT= 6
;;; * USES: C, active PT, DADD, PFAD
;;; *       (no ST, +0 sub levels, no timer chip access)
;;; *
;;; **********************************************************************

              .public GFLG31_2
GFLG31_2:     c=0     x
              pfad=c
              dadd=c
              c=regn  14
              pt=     6             ; flag15 in digit.6, bit.3
              c=c+c   pt
              c=c+c   pt
              c=c+c   pt
              ?a#0    x             ; get flag 31 only ?
              rtn c                 ; yes, done
              c=c+c   pt            ; flag 31 set ?
              gonc    SWPMD4        ; no MDY, so swap month&day
              acex                  ; yes, C= DMY date
              goto    SWPMD8
SWPMD4:       acex                  ; assume, for example, MDY:
              rcr     11            ; C= D DYYYY00000 0MM
              a=c     x
              rcr     12            ; C= Y YYY000000M MDD
              acex    x             ; C.X= 0MM, A.X= MDD
              rcr     2             ; C= M MYYYY00000 0M0
              acex    x
              rcr     3
SWPMD8:       c=0     s             ; C= 0 DDMMYYYY00 000
              rtn

              .fillto 0xff4
              nop                   ; pause loop
              nop                   ; running
              nop                   ; wake w/o key
              nop                   ; power off
              nop                   ; I/O
              nop                   ; deep wake up
              nop                   ; memory lost
              .con    4             ; D
              .con    0x32          ; 2
              .con    6             ; F
              .con    5             ; E
              .con    0             ; checksum
