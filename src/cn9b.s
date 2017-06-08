;;; This is HP41 mainframe resurrected from list file output. QUAD 9
;;;
;;; REV.  6/81A
;;; Original file CN9B
;;;

#include "mainframe.h"

; * HP41C mainframe microcode addresses @22000-23777
; *
              .section QUAD9

              .public ASRCH
              .public DOSRCH
              .public GTSRCH
              .public ROW0
              .public ROW11
              .public ROW12
              .public RTN30
              .public SARO21
              .public SARO22
              .public SAROM
              .public SEARCH
              .public SERR
              .public SGTO19
              .public SNR10
              .public SNR12
              .public SNROM
              .public XEQC01
              .public XGI
              .public XGNN10
              .public XGNN12
              .public XGTO
              .public XRTN
              .public XXEQ

SNROM:        abex    X             ; A[1:0]_LBL
              rcr     11            ; set addr to next word
SNRO9:        pt=     1             ; -
SNRO10:       c=c+1   m             ; -
SNRO12:       cxisa                 ; get ROM word
              c=c-1   xs            ; 1st byte?
              ?c#0    xs            ; 1st byte?
              goc     SNRO10        ; nope
              ?c#0    pt            ; ROW0?
              goc     SNRO20        ; nope
              ?c#0    wpt           ; null?
              gonc    SNRO10        ; yes
              c=c-1   x             ; LBL_LBL-1
              ?a#c    wpt           ; correct short LBL?
              goc     SNRO10        ; nope
              goto    SNRO40        ; return

SNRO20:       c=c+1   pt            ; ROW12?
              c=c+1   pt            ; -
              c=c+1   pt            ; -
              c=c+1   pt            ; -
              gonc    SNRO10        ; nope
              pt=     0             ; long LBL?
              c=c+1   pt            ; -
              goc     SNRO30        ; yes
              c=c+1   pt            ; chain?
              goc     SNRO9         ; nope
              c=c+1   m             ; get 3rd byte
              c=c+1   m             ; -
              cxisa                 ; -
              pt=     1             ; ALBL?
              c=c+1   pt            ; -
              goc     SNRO10        ; yes
              c=0                   ; -
              ?s9=1                 ; 2nd END?
              goc     SNRO50
              s9=     1             ; 1st END found
              b=a                   ; save LBL
              gsblng  ROMHED        ; get begin addr

              abex                  ; put back LBL
              rcr     11            ; -
              goto    SNRO9         ; continue search

SNRO30:       c=c+1   m             ; correct long LBL?
              cxisa                 ; -
              ?a#c    x             ; -
              goc     SNRO9         ; nope
              c=c-1   m             ; position address
SNRO40:       c=c-1   m             ; -
              rcr     3             ; C[3:0]_ROM address
SNRO50:       pt=     3
              rtn


; *  SEARCH - search for numeric label
; *- Search the current program for the designated
; *- long or short numeric label. (Searches in ROM
; *- or RAM)
; *- IN:  A.X=numeric label (if pc is in RAM, A[2] may be non-zero)
; *-      PT= 3
; *- OUT: C=0 implies the label was not found
; *         otherwise
; *-      C[3:0]= label address (address of byte before label)
; *-      PT= 3
; *-      chip 0 selected
; *- USES: status bits 9,6,0, G, A[13:0], C[13:0], B[3:0]
; *        S6=1 implies program counter is at the first byte
; *            of a three-byte instruction on input.  This
; *            only occurs when executing long GTONN and XEQNN
; *            out of program memory.
; *        S6=0 implies program counter is at a standard position
; *            (i.e. at the byte before the first byte of a line).
; *- USES: 2 subroutine levels

              .public SEARC1
SEARCH:       s6=     0
SEARC1:       s9=     0             ; 1st END not found
              b=a     x             ; save A
              gsblng  GETPC         ; get addr
              ?s10=1                ; ROM?
              goc     SNROM         ; yes
              c=b     x             ; G_LBL
              rcr     11            ; -
              g=c                   ; -
              ?s6=1                 ; -
              gonc    SNR12
SNR10:        gsblng  INCAD2
SNR12:        gsblng  NXBYTA        ; get a byte
              rcr     12            ; set ptr
              c=-c    pt            ; 1-byte FC?
              c=c+c   pt            ; -
              goc     SNR12         ; yes
              c=c+c   pt            ; 2-byte FC?
              goc     SNR70         ; yes
              c=c+c   pt            ; 3-byte FC?
              goc     SNR10         ; YES
              c=c+c   pt            ; ROW 0?
              gonc    SNR50         ; yes
              gsblng  NXLTX         ; it's a text FC
              goto    SNR12         ; -

SNR50:        ?c#0    xs            ; null?
              gonc    SNR12         ; yes
              s0=     0             ; -
              c=c-1   xs            ; LBL_LBL-1
              rcr     2             ; -
SNR55:        acex                  ; C[6:3]_RAM address
              rcr     11            ; -
              pt=     0             ; C[1:0]_LBL
              c=g                   ; -
              a=c     xs            ; -
              pt=     3             ; -
              ?a#c    x             ; correct label?
              goc     SNR60         ; nope
              rcr     3             ; yes, point at prev step
              a=c                   ; -
              gsblng  DECADA        ; dec RAM addr
              ?s0=1                 ; long label?
              gsubc   DECADA        ; yes, dec RAM addr again
              c=0                   ; re-enable chip 0
              dadd=c
              acex    wpt           ; C[3:0]_LBL ADDR
              rtn                   ; return from search

SNR60:        rcr     3             ; A[3:0]_RAM addr
              a=c                   ; -
              goto    SNR12         ; -

SNR65:        gsblng  INCADA        ; inc RAM addr
              goto    SNR12         ; -

SNR70:        ?c#0    pt            ; ROW 12?
              goc     SNR65         ; nope
              c=c+1   xs            ; long label?
              goc     SNR80         ; yes
              c=c+1   xs            ; X<>?
              goc     SNR65         ; yes
              gsblng  GTLINK        ; C[13]_3rd byte of chain
              c=c+1   s             ; ALBL?
              goc     SNR65         ; yes
              ?s9=1                 ; 2nd END?
              goc     SNR72         ; yes
              gosub   CPGMHD        ; goto PGM head
              s9=     1             ; 1st END found
              goto    SNR12
SNR72:
; * Search gives up here
              ?s6=1                 ; PGM CTR in odd place?
              gonc    SNR73         ; no
              gosub   GETPC         ; yes
              gosub   INCAD2        ; set it to end of 3-byte FC
              gosub   PUTPC
SNR73:        c=0                   ; not found
              dadd=c                ; re-enable chip 0
              rtn                   ; -

SNR80:        gsblng  NXBYTA        ; get 2nd byte of long label
              s0=     1             ; long label
              goto    SNR55         ; correct long label?


              .public XGA00
                                    ; *
; * XGA - XEQ/GTO alpha
; *- Place the program counter at the specified alpha
; *- string label address.  In the case of an XEQ, the
; *- return stack is pushed through a transfer to "XEQC"
; *- IN:  S7= 1/0 implies XEQ/GTO function
; *-      S9= 1 implies an alpha search has been
; *-             previously performed
; *-      M[3:0]=address or M=alpha string
                                    ; *
XGA00:        gosub   SAVRC         ; save return address
              c=m                   ; C=ALBL or address
              ?s13=1                ; running?
              goc     XGI52         ; yes
              ?s4=1                 ; SST?
              goc     XGI52         ; yes
; * Must be from keyboard
              ?s9=1                 ; already found?
              gonc    XGI52         ; no. (AGTO from keyboard)
              goto    XGI54         ; must be AXEQ of user label

; *
; * XGI - XEQ/GTO indirect
; *- Place the program counter at the numeric or
; *- alpha label found in the specified register.
; *- In the case of an XEQ, the subroutine return
; *- stack is pushed through a transfer to "XEQC".
; *- IN:  status= 2nd byte of function code
; *-      status bit 7 = 0/1 implies GTO/XEQ function
; *- OUT: GTO- chip 0 selected
; *-      XEQ- PT=3
; *-           C[3:0]= label address
; *-           chip 0 selected
; *- USES: A,B,C,M,N,G,status bits, status bits 8 & 9
; *-       REG 9, REG 10 digits 0,1
; *- USES: 4 subroutine levels

XGI30:        pt=     12            ; test for null LBL
              c=0     pt            ; -
              ?c#0                  ; -
              gonc    SERRXF        ; yes
              a=c                   ; format
              c=0                   ; -
              dadd=c
              pt=     1             ; -
XGI40:        ?a#0    wpt           ; - (end of string?)
              gonc    XGI50         ; - (yes)
              acex    wpt           ; -
              rcr     12            ; -
              asr                   ; -
              asr                   ; -
              goto    XGI40         ; -
XGI50:        rcr     2             ; -
              m=c                   ; -
XGI52:        regn=c  9
              gsblng  ASRCH         ; search for alpha label
              ?c#0                  ; found?
              gonc    SERRXF        ; no
              ?s2=1                 ; ROM?
              goc     XGI55         ; yes
XGI54:        s10=    0             ; no. must be RAM
              goto    XGI60
XGI55:        ?s9=1                 ; microcode?
              gonc    XGI57         ; no. must be user lang
              ?s5=1                 ; mainframe?
              goc     SERR          ; yes. error
              m=c                   ; save  address in M
              c=regn  10            ; retrieve rtn address
              ?c#0    x             ; XEQ?
              gonc    SERR          ; no. AGTO illegal for
                                    ; microcode
              c=regn  14            ; restore SS0
              st=c
              c=m                   ; C[3:0]=XADR
              rcr     11            ; C[6:3]=XADR
              cxisa                 ; get word at XADR
              ?c#0    x             ; programmable FCN?
SERRXF:       gonc    SERR          ; no. error
              gotoc

              .public XGI57
; * XROM enters at XGI57
; * On entry, address of first byte of destination label is in C[3:0]
; * and return address is in R10[3:0] already packed for push onto
; * subroutine stack
XGI57:        s10=    1             ; ROM user language
XGI60:        pt=     3             ; -
              a=c     wpt           ; -
              gsblng  DECAD         ; -
              goto    XGI07         ; -

XGI:          gosub   SAVRC         ; save return address
              s7=     0             ; clear S7 for ADRFCH
              gsblng  ADRFCH        ; C[13:0]_reg contents
              c=c-1   s
              ?c#0    s             ; valid # label?
              gonc    XGI30         ; nope
              gsblng  BCDBIN        ; convert BCD to binary
              a=c     x             ; valid label?
              ldi     100           ; -
              ?a<c    x             ; -
              gonc    SERR          ; nope, # too big
              gsblng  DOSRC1        ; search for label

XGI05:        pt=     3             ; -
              a=c     wpt           ; A[3:0]_LBL addr
; *
; *  XGI07  -  entry point to do XEQ [RAM address]
; *            Added for Wand 2/13/80 JAVB.
; *    ON INPUT
; *       chip 0 enabled
; *       REG10 has packed return address (see SAVRTN)
; *       A[3:0] has RAM address
; *       PT = 3
; *    Never returns to calling program
; *
              .public XGI07
XGI07:        c=regn  10            ; retrieve rtn addr
              ?c#0    x             ; XEQ?
              gonc    XGNN10        ; no. GTO
              b=a     wpt           ; LBL addr to B[3:0]
              goto    XEQC01

GTSRCH:       abex    wpt           ; A[1:0]_corresponding short LBL
              asr     x             ; -
              asr     x             ; -
              a=a-1   x             ; -
              .public DOSRC1
DOSRC1:       s6=     0             ; PGM CTR is in a std place
DOSRCH:       gsblng  SEARC1        ; search for numeric label
              ?c#0                  ; found?
              rtn c                 ; yes
SERR:         golong  ERRNE         ; report error
                                    ; "NONEXISTENT"


; *  XEQC01 - XEQ common logic
; *- If in keyboard mode, the subroutine return stack
; *- is cleared, & the program is set to running,
; *- otherwise the subroutine stack is pushed and the
; *- program counter is set to the designated label
; *- address
; *- IN:  B[3:0]= label address
; *-      PT= 3
; *       REG 10 [3:0] = return address already packed
; *- OUT: chip 0 selected
; *- USES: B[3:0], C[13:0], A[13:0]
; *- USES: 1 subroutine level
; *
; * XEQ20 - same as XEQC01 except doesn't check for keyboard mode
; *

XEQC01:       c=0     x             ; select chip 0
              dadd=c                ; -
              ?s13=1                ; running?
              goc     XEQ20         ; yes
              c=regn  14            ; SSTFLAG?
              st=c                  ; -
              ?s4=1                 ; -
              gonc    XEQ50         ; nope
XEQ20:        c=regn  10            ; get return address
              a=c     wpt           ; put rtn addr to A[3:0]
              c=regn  12
              acex    wpt
              rcr     10            ; push stack
              a=c                   ; -
              c=regn  11            ; -
              rcr     10            ; -
              acex    wpt           ; -
              regn=c  11            ; -
              acex                  ; -
              gsblng  CLRSB3        ; finish push
              goto    XGNN12

XEQ49:        bcex    wpt           ; keyboard path
XEQ50:        gsblng  CLRSB2        ; clear rtn stack
              golong  RUN

; * XGNN - XEQ/GTO numeric (long form GTO)
; *- Place the program counter at the specified numeric
; *- label address, compiling a displacement to be
; *- stored with the function upon the first encounter
; *- of that function. (Following a decompile)  In the
; *- case of an XEQ, the return stack is pushed through
; *- a transfer to "XEQC".
; *- IN: S1= 0/1 implies GTO/XEQ function
; *-     S9=1 implies a numeric search has been
; *-        previously performed
; *-     C[1:0]= numeric label
; *- OUT: GTO- chip 0 selected
; *-      XEQ- C[3:0]= label address
; *-           PT= 3
; *-           chip 0 selected
; *- USES: status bits 0,1,6,8,9, A[13:0], B[13:0], C[13:0]
; *-       M[13:0], G
; *- USES: 4 subroutine levels

XGTO:         s1=     0             ; GTO NN
XGNN:         ?s13=1                ; running?
              goc     XGNN02        ; yes
              ?s4=1                 ; SSTFLAG?
              goc     XGNN02        ; YES
              a=c     x             ; A[1:0]_# LBL
              c=m
              ?s9=1
              gsubnc  DOSRC1
              ?s1=1                 ; XEQ?
              goc     XEQ49
              a=c     wpt
XGNN10:       gsblng  PUTPCX        ; -
XGNN12:       golong  NFRPU         ; -
XGNN02:       ?s10=1                ; ROM?
              gonc    XGNN20        ; nope
              a=c     wpt           ; -
              a=0     pt            ; -
              c=regn  12            ; no, A[2:0]_full rel addr.
              rcr     11            ; -
              c=c+1   m             ; -
              cxisa                 ; -
              acex    x             ; -
              acex    xs            ; -
              c=c+1   m             ; determine sign
              cxisa                 ; -
              rcr     13            ; -
              c=c+c   x             ; -
              goc     XGNN15        ; add
              c=regn  12            ; PGMCTR_PGMCTR-rel addr.
              acex    wpt           ; -
              a=a-c   wpt           ; -
XGNN05:       ?s1=1                 ; XEQ?
XGNN06:       gonc    XGNN10        ; nope
              b=a     wpt           ; B[3:0]_lbl address
              goto    XEQ20

XGNN15:       c=regn  12            ; PGMCTR_PGMCTR+rel addr.
              a=a+c   wpt           ; -
              legal
              goto    XGNN05        ; -

XXEQ:         s1=     1             ; XEQ
              bcex                  ; save FC & 2nd byte in B
              gosub   GETPC         ; calc return address
              gosub   INCAD         ; increment over 2nd and
              gosub   INCAD         ;  3rd bytes of XEQ NN
              c=a     wpt           ; copy addr to C[3:0]

              gosub   SAVR10        ; req addr in both A and C
                                    ; saves rtn addr in R10
              bcex                  ; restore C
              goto    XGNN

XGNN20:       ?s8=1                 ; full rel addr?
              gonc    XGNN25        ; yes
              bcex    wpt           ; no, C[2:0]_full rel addr
              gsblng  GETPCA        ; -
              gsblng  NXBYTA        ; -
              c=b     xs            ; -
XGNN25:       ?c#0    x             ; compile?
              gonc    XGNN65        ; yes
              c=0     pt            ; unpack rel addr &
              c=c+c   wpt           ; -   inc byte by 2
              c=c+c   wpt           ; -
              c=c+c   wpt           ; -
              c=c+1   pt            ; -
              c=c+c   pt            ; -
              c=c+c   x             ; -
              goc     XGNN50        ; -
              csr     x             ; -
XGNN30:       bcex    wpt           ; B[3:0]_rel addr (MM)
              gsblng  GT3DBT        ; get 3rd byte
              cmex                  ; M_org status, C_PGMCTR
              abex    wpt           ; A[3:0]_rel addr
              ?s7=1                 ; subtract?
              gonc    XGNN60        ; yes
              a=a+c   x             ; -
              a=a+c   pt            ; A[3:0]_lbl addr
              gonc    XGNN55        ; -
              a=a+1   x             ; -
XGNN35:       c=m                   ; restore org status
              st=c                  ; -
              .public XGNN40
XGNN40:       c=0     x             ; re-enable chip 0
              dadd=c
              goto    XGNN05

XGNN50:       csr     x             ; -
              c=c+1   xs            ; -
              legal
              goto    XGNN30        ; -

XGNN55:       a=a-1   pt            ; byte_byte-2
              a=a-1   pt            ; -
              legal
              goto    XGNN35        ; -

XGNN60:       acex    wpt           ; A[3:0]_PGMCTR-rel addr
              c=c-1   pt            ; -
              c=c-1   pt            ; -
              legal
              gsblng  CALDSP        ; calculate displacement
              goto    XGNN35        ; -


XGNN65:       s8=     1             ; -
              gsblng  GT3DBT        ; get 3rd byte
              s7=     0             ; decompile doesn't clear
                                    ; bit 7 of the third byte
              cstex                 ; -
              a=c     x             ; -
              s6=     1             ; PGM PTR is at 1st byte
                                    ; of 3-byte FC
              gsblng  DOSRCH        ; search RAM for LBL
              a=c     wpt           ; calculate displacement
              cmex                  ; -  (M_LBL address)
              ?a#c    x             ; -
              goc     XGNN70        ; -
              ?a<c    pt            ; -
              gonc    XGNN80        ; -
              goto    XGNN75        ; -
XGNN70:       ?a<c    x             ; -
              gonc    .+3           ; -
XGNN75:       s8=     0             ; -
              acex    wpt           ; -
XGNN80:       c=a-c   x             ; - (#regs)
              c=a-c   pt            ; - (#bytes)
              gonc    1$            ; - (no carry)
              c=c-1   x             ; - (reg_reg-1)
              c=c-1   pt            ; - (byte_byte-2)
              c=c-1   pt            ; -
1$:           c=c+c   x             ; pack displacement
              c=c+c   x             ; -
              c=c+c   x             ; -
              c=c+c   x             ; -
              gonc    2$            ; -
              c=c+1   pt            ; -
2$:           csr     wpt           ; -
              bcex    x             ; rel addr_displacement
              gsblng  GETPC         ; -
              gsblng  GTBYTA        ; -
              rcr     12            ; -
              c=b     x             ; -
              rcr     2             ; -
              bcex    m             ; -
              bcex    s             ; -
              gsblng  PTBYTA        ; -
              gsblng  INCADA        ; -
              c=b                   ; -
              rcr     12            ; -
              gsblng  PTBYTA        ; -
              gsblng  NXBYTA        ; set bit 8 of label byte
              cstex                 ; -
              s7=     0             ; -
              ?s8=1                 ; -
              gonc    3$            ; -
              s7=     1             ; -
3$:           cstex                 ; -
              gsblng  PTBYTA        ; -
              c=m                   ; A[3:0]_lbl address
              a=c     wpt           ; -
              golong  XGNN40        ; -

; * GT3DBT moved to CN0


ROW11:        gsblng  INCGT2        ; get 2nd byte
              ?a#0    xs            ; short GTO?
              rtn nc                ; nope
              b=a     wpt           ; -
              a=0     xs            ; -
              ?s10=1                ; ROM?
              gonc    SGTO25        ; nope
              ?a#0    x             ; need search?
              gonc    SGTO15        ; yes
              a=0     pt            ; -
              acex    x             ; status_byte2
              st=c                  ; -
              ?s7=1                 ; subtract?
              gonc    SGTO10        ; yes
              s7=     0             ; PGMCTR_PGMCTR+rel addr
              c=st                  ; -
              a=c     x             ; -
              c=regn  12            ; -
              a=a+c   wpt           ; -
              legal
              goto    SGTO20        ; -

SGTO10:       a=c     x             ; PGMCTR_PGMCTR-rel addr
              c=regn  12            ; -
              acex    wpt           ; -
              a=a-c   wpt           ; -
              legal
              goto    SGTO20        ; -

SGTO15:       gsblng  GTSRCH        ; search for numeric short LBL
SGTO19:       a=c     wpt           ; PGMCTR_LBL address
SGTO20:       golong  XGNN10        ; -


SGTO25:       ?a#0    x             ; need compile?
              gonc    SGTO40        ; yes
              asl     wpt           ; unpack rel addr(except for +- bit)
              asl     wpt           ; -
              asr     x             ; -
              asr     x             ; -
              c=regn  12            ; A[3:0]_PGMCTR
              c=c+c   pt            ; -
              acex    wpt           ; C[3:0]_rel addr
              c=c+c   pt            ; add?
              goc     SGTO30        ; yes
              gsblng  CALDSP        ; calculate displacement
              goto    SGTO20        ; -

SGTO30:       a=a+c   x             ; -
              c=c+1   pt            ; PGMCTR_PGMCTR+rel addr
              c=c+1   pt            ; -
              a=a+c   pt            ; -
              gonc    SGTO35        ; -
              a=a+1   x             ; -
              legal
              goto    SGTO20        ; -

SGTO35:       a=a-1   pt            ; -
              a=a-1   pt            ; -
              legal
              goto    SGTO20        ; -

SGTO40:       s8=     0             ; -
              gsblng  GTSRCH        ; search
              m=c                   ; -
              gsblng  GETPC         ; A[3:0]_PGMCTR
              n=c                   ; -
              c=m                   ; C[3:0]_LBL addr
              ?a#c    x             ; -
              goc     SGTO45        ; -
              ?a<c    pt            ; -
              gonc    SGTO55        ; -
              goto    SGTO50        ; -
SGTO45:       ?a<c    x             ; calculate displacement
              gonc    .+3           ; -
SGTO50:       s8=     1             ; -
              acex    wpt
SGTO55:       gsblng  CALDSP        ; calculate displacement
              ?a#0    xs            ; >=max?
              goc     SGTO60        ; yes
              asl     x             ; pack rel addr
              ?a#0    xs            ; >=max?
              goc     SGTO60        ; yes
              asl     x             ; -
              asr     wpt           ; -
              c=n                   ; -
              acex    wpt           ; -
              ?s8=1                 ; -
              gonc    1$            ; -
              c=c+1   pt            ; -
1$:           c=c+c   wpt           ; -
              c=c+c   wpt           ; -
              c=c+c   wpt           ; -
              c=c+c   x             ; -
              rcr     2             ; -
              gsblng  PTBYTA        ; -
SGTO60:       c=m                   ; PGMCTR_LBL addr
              golong  SGTO19        ; -

; * CALDSP moved to CN0

SAROM:        pt=     2             ; PT_1 & A[13]_6
              lc      6             ; -
              rcr     3             ; -
              a=c     s             ; -
              c=m                   ; -
SARO02:       bcex                  ; convert ASCII char to LCD
              abex    wpt           ; -
              gsblng  MASK          ; -
              nop
              pt=     1             ; -
              ?c#0    xs            ; special character?
              gonc    1$            ; nope
              lc      4             ; adjust special character
              pt=     1             ; -
1$:           bcex                  ; place LCD char in string
              bcex    wpt           ; -
              rcr     2             ; -
              ?c#0    wpt           ; done?
              gonc    SARO04        ; yes
              a=a-1   s             ; 7 chars?
              goc     SARO06        ; yes
              goto    SARO02        ; next char
SARO04:       rcr     2             ; right-justify
              ?c#0    wpt           ; -
              gonc    SARO04        ; -
SARO06:       m=c                   ; M_LCD char string
              s5=     0             ; mainframe tbl 3rd
              pt=     6             ; B[M]_C[M]_56K
              c=0                   ; -
              dadd=c                ; -  (sel chip 0)
              lc      5             ; -
SARO11:       bcex    m             ; -
SARO10:       c=b     m             ; table there?
              pt=     0             ; - (G_ROM ID)
              cxisa                 ; !!!!!!!should be CXISA!!!!!!!
              g=c                   ; -
              c=c+1   m             ; -
              cxisa                 ; !!!!!!!should be CXISA!!!!!!!
              ?c#0    x             ; -
              goc     SARO20        ; yes
SARO15:       pt=     6             ; adjust addr
              c=b     m             ; -
              c=c+1   pt            ; -
              gonc    SARO11        ; -
#if defined(HP41CX)
              golong  LB_3879
              .public LB_263C
LB_263C:      enrom1
#else
              lc      1             ; load main addr - 1 (11777 OCT)
              lc      3
              lc      15
#endif
              lc      15
              s5=     1             ; search mainframe table now
SARO20:       pt=     1             ; C[6:3]_LBL addr
SARO21:       c=c+1   m             ; -
SARO22:       cxisa                 ; -
              ?s5=1                 ; mainframe search?
              goc     SARO42        ; yes
              bcex    x             ; -
              c=c+1   m             ; -
              cxisa                 ; -
              ?b#0    x             ; - (end of table?)
              goc     SARO25        ; -
              ?c#0    x             ; -
              gonc    SARO15        ; - (yes)
SARO25:       bcex    x             ; -
              a=c                   ; -
              rcr     5             ; -
              a=a+c   pt            ; -
              rcr     9
              acex    x
              rcr     12
              c=b     wpt           ; -
              n=c                   ; save LBL addr in N
              rcr     11            ; -
              acex    x             ; -
              c=c+c   xs            ; -
              c=c+c   xs            ; -
              c=c+c   xs            ; -
              gonc    SARO45        ; -
              c=c+1   m             ; C[13]_# LBL chars
              c=c+1   m             ; -
              a=c                   ; -
              cxisa                 ; -
              rcr     1             ; -
              a=c     s             ; -
              c=regn  9             ; - (A[13:0]_alpha chars)
              acex                  ; -
              c=c-1   s             ; -
              c=c+1   m             ; -
SARO30:       c=c+1   m             ; C[1:0]_1 LBL char
              cxisa                 ; equal?
              ?a#c    wpt           ; -
              goc     SARO40        ; no
              c=c-1   s             ; dec LBL count
              asr                   ; shift a to next char
              asr                   ; -
              ?c#0    s             ; end of LBL?
              goc     SARO35        ; nope
              ?a#0    wpt           ; end of chrs?
              goc     SARO40        ; nope
              s9=     0             ; user_true
              goto    SARO55        ; -
SARO35:       ?a#0    wpt           ; end of chrs?
              goc     SARO30        ; nope, tst nxt char
SARO40:       rcr     5             ; get nxt tbl entry
              goto    SARO21        ; -

SARO42:       pt=     3             ; set ptr
              a=c     x             ; A[2:0]_LBL addr
              ?a#0    x             ; end of mainframe tbl?
              goc     1$            ; nope
              c=0                   ; return w/error
              rtn                   ; -
1$:           ldi     0x3df         ; hole?
              ?a<c    x             ; -
              goc     SARO43        ; nope
              a=a-c   x             ; subtract offset
              rcr     3             ; tbl addr_tbl addr+displacement
              a=0     pt            ; -
              c=a+c   wpt           ; -
              rcr     11            ; -
              golong  SARO22        ; check next tbl entry
SARO43:       acex    x             ; -
              rcr     13            ; N_LBL addr
              csr     wpt           ; -
              c=c+1   pt            ; -
              pt=     1             ; -
              n=c                   ; -
              rcr     11            ; test for ALBL match
SARO45:       a=c                   ; A_ALPHA string
              c=m                   ; -
              acex                  ; -
SARO47:       c=c-1   m             ; get nxt char
              cxisa                 ; -
              ?c#0    wpt           ; is there a prompt string?
              gonc    SARO48        ; no
              s8=     0             ; S8_END bit
              cstex                 ; -
              ?s7=1                 ; -
              gonc    1$            ; -
              s7=     0             ; -
              s8=     1             ; -
1$:           cstex                 ; -
              ?a#c    wpt           ; equal?
              goc     SARO48        ; nope
              asr                   ; -
              asr                   ; -
              ?s8=1                 ; end of LBL?
              goc     SARO50        ; yes
              ?a#0    wpt           ; end of chars?
              goc     SARO47        ; nope
SARO48:       rcr     4             ; get nxt entry
              ?s5=1                 ; realign old addr
              goc     1$            ; -
              rcr     1             ; -
1$:           golong  SARO21        ; -
SARO50:       ?a#0    wpt           ; end of chars?
              goc     SARO48        ; nope
              s9=     1             ; ucode_true
; * Entry point added for HP-41CX
              .public SARO55
SARO55:       c=n                   ; C[3:0]_ADDR & F.C.
; * Next two instructions (PT=7,LC 0) may not be necessary.
              pt=     7             ; -
              lc      0             ; -
              ?s5=1                 ; XROM?
              goc     SARO60        ; nope
              a=c                   ; C[7:4]_XROM F.C.
              rcr     2             ; construct table index part
              c=c-1   m             ; -
              c=c-1   m             ; -
              c=c+c   m             ; -
              c=c+c   m             ; -
              c=c+c   m             ; -
              csr     m             ; -
              c=c+c   m             ; construct ROM ID part
              c=c+c   m             ; -
              pt=     5             ; -
              c=g                   ; -
              c=c+c   m             ; -
              c=c+c   m             ; -
              pt=     7             ; construct XROM FC part
              lc      10            ; -
              pt=     3             ; -
              acex    wpt           ; C[3:0]_ROM ADDR & C[5:4]_F.C.
SARO60:       s2=     1             ; -
              rtn                   ; return


; *  ASRCH - alpha search
; *- Locate the address of an alpha string.  The alpha
; *- string may apply to an alpha label in RAM or a
; *- function in the mainframe or plug-in ROMs. If the
; *- function is located in a plug-in ROM, return the
; *- XROM function code.  If the function is located in
; *- the mainframe, return its function code.  If the
; *- function is located in RAM, return the alpha label
; *- address.
; *-
; *- IN:  M[13:0] and REG 9[13:0] = alpha label (2 COPIES)
; *-
; *- OUT: C[3:0]= address (if user lang, this is address of first
; *                        byte of label)
; *-      C[7:4]= function code
; *-      S2=1/0 implies ROM/RAM address
; *-      C=0 implies not found
; *-      S9=1/0 implies microcode/user code
; *-      S5=1 implies a mainframe function
; *       chip 0 enabled
; *-
; *- USES: M,A,B,C,G,N,STATUS,ptr P,REG 9
; *-       status bits 2,3,5,8,9
; *- USES: 2 subroutine levels

ASRCH:        c=regn  13            ; A[3:0]_END addr (RAM 1st)
              pt=     3             ; -
              lc      4             ; C[2:0]_END link
              pt=     3             ; -
              a=c     wpt           ; -
              dadd=c                ; -
              c=data                ; -
              rcr     2             ; -
SARA10:       ?c#0    x             ; END?
              golnc   SAROM         ; yes
              gsblng  UPLINK        ; get nxt link addr
              c=c+1   s             ; ALBL?
              gonc    SARA10        ; nope
SARA20:       rcr     9             ; G_# alpha LBL chars
              c=c-1   pt            ; -
              g=c                   ; -
              b=a     wpt           ; A[7:0]_LBL addr & char addr
              c=b     wpt           ; -
              rcr     10            ; -
              c=b     wpt           ; -
              a=c                   ; get 1st char
              gsblng  INCAD2        ; -
              gsblng  INCADA        ; -
              c=m                   ; B[13:0]_alpha string
              bcex                  ; -
              abex                  ; -
SARA30:       abex                  ; get nxt byte
              pt=     3             ; -
              gsblng  NXBYTA        ; -
              abex                  ; -
              pt=     1             ; -
              ?a#c    wpt           ; equal?
              goc     SARA40        ; nope
              asr                   ; shift to NXTCHAR
              asr                   ; -
              c=g                   ; dec count LBL chars
              c=c-1   pt            ; -
              g=c                   ; -
              ?c#0    pt            ; end LBL chars?
              gonc    SARA50        ; yes
              ?a#0    wpt           ; end str chars?
              goc     SARA30        ; nope
SARA40:       pt=     3             ; get nxt link
              c=b                   ; -
              rcr     4             ; -
              a=c     wpt           ; -
              rcr     5             ; -
              goto    SARA10        ; -
SARA50:       ?a#0    wpt           ; end str chars?
              goc     SARA40        ; nope
              c=0     x             ; enable chip 0
              dadd=c                ; -
              c=b                   ; C[3:0]_addr
              rcr     4             ; -
              s2=     0             ; RAM
              s9=     0             ; usercode_true
              rtn                   ; return
; *
; *  RTN - return
; *- Pops the subroutine return stack if running,
; *- otherwise, it places the program counter at the
; *- beginning of the current program
; *- IN:  chip 0 selected
; *- OUT:
; *- USES: status bits 13 & 12, C[13:0], A[13:0]
; *-       B[3:0], M[13:0]
; *- USES: 2 subroutine levels

XRTN:         s9=     0             ; remember this is RTN
              pt=     3             ; -
RTN00:        ?s13=1                ; running?
              goc     RTN10         ; yes
              ?s4=1                 ; SSTFLAG?
              gonc    RTN30         ; nope
RTN10:        c=regn  11            ; pop rtn stk
              a=c                   ; -
              c=regn  12            ; -
              acex    wpt           ; -
              rcr     4             ; -
              ?c#0    wpt           ; -  (pop zero?)
              gonc    RTN21         ; -  (yes)
              s10=    1             ; assume new PC is in ROM
              ?c#0    pt            ; -  (need unpack?)
              goc     RTN15         ; -  (nope)
              s10=    0             ; new PC is in RAM
              c=c+c   wpt           ; -  (unpack)
              c=c+c   wpt           ; -
              c=c+c   wpt           ; -
              c=c+c   x             ; -
              goc     RTN25         ; -
              csr     x             ; -
RTN15:        regn=c  12            ; -
              acex                  ; -
              c=0     wpt           ; -
              rcr     4             ; -
              regn=c  11            ; -
              c=regn  15            ; line_FFF
              c=0     x             ; -
              c=c-1   x             ; -
              regn=c  15            ; -
              golong  CHKRPC

RTN25:        csr     x             ; -
              c=c+1   xs            ; -

              goto    RTN15         ; -
; *
; *  XEND - execute END
; *  When executing from the keyboard, or when running and
; *- if the subroutine stack is empty, then the
; *- program counter is placed at the current
; *- program head, otherwise, a return function
; *- is performed
; *- IN:
; *- OUT:
; *- USES: C[13:0], A[3:0], B[4:0]
; *- USES: 2 subroutine levels
              .public XEND
XEND:
                                    ; row logic may leave
                                    ; some chip other than
                                    ; 0 enabled.
              c=0                   ; select chip 0
              dadd=c                ; -
              s9=     1             ; remember this is END
              goto    RTN00

RTN21:        s13=    0             ; clear running flag
              ?s9=1                 ; is this END?
              rtn nc                ; no. must be RTN
RTN30:        c=regn  15            ; line #_0
              c=0     x             ; -
              regn=c  15            ; -
              ?s10=1                ; ROM?
              goc     RTN35         ; yes
              gsblng  FLINKP        ; get end address
              rcr     8             ; -
              a=c     wpt           ; -
              gsblng  CPGMHD        ; C[3:0]_head address
RTN33:        s9=     0             ; tell DCRT10 to RTN
              golong  DCRT10        ; go clear subroutine stack

RTN35:        gsblng  ROMHED        ; A[3:0]_CPGMHD
              goto    RTN33         ; -


; *-  ROW12 - row twelve logic
; *- Distinguishes long numeric labels, X<> function,
; *- END function, and alpha labels
; *-
; *- IN:  C[3:2]= function code
; *-      chip 0 selected
; *- USES: M[13:0], C[13:0], AND A[13:0]
; *- USES: 1 subroutine level

; * Note PARSE generates CD for the FC of "ALBL". Logic at ROW12A
; * is for keyboard execution only.

ROW12A:       c=c+1   xs            ; ALBL F.C.?
              goc     ALBL          ; yes, alpha label
XENDA:        goto    XEND          ; no, must be END

ROW12:        m=c                   ; save F.C.
              c=c+1   xs            ; long LBL?
              goc     LBL_          ; yes
              c=c+1   xs            ; -
              golc    XNNROW        ; -
              ?s13=1                ; running?
              goc     RW10          ; yes
              ?s4=1                 ; SSTFLAG?
              gonc    ROW12A        ; nope
RW10:         gsblng  GETPCA        ; ALBL?
              gsblng  INCAD         ; -
              gsblng  NXTBYT        ; -
              rcr     2             ; -
              c=c+1   s             ; -
              gonc    XENDA         ; goto END

; * ALBL - alpha label
; *- Increment the program counter past the alpha label,
; *  and drop into SLBL
; *- IN:  M[3:2]= alpha label function code
; *- OUT: chip 0 selected
; *- USES: C[13:0], A[13:0], status bits 1 & 2, B[13:0]
; *-       M[13:0]
; *- USES: 2 subroutine levels

ALBL:         c=m                   ; recover F.C.
              a=c                   ; -
              c=0     x             ; -
              dadd=c                ; -
              gsblng  GTAINC        ; advance PGMCTR
              goto    SLBL
; *
; *  LBL/SLBL - (numeric) label/short label
; *- Increments the program counter past a numeric
; *- label, and rotates the goose right one position
; *-
; *- USES: 1 subroutine level

LBL_:         gsblng  INCGT2        ; inc PGMCTR
SLBL:         ?s5=1                 ; display got something?
                                    ; (MSGFLG?)
              rtn c                 ; yes
              gosub   ENLCD
              rabcr                 ; rotate goose
              golong  ENCP00


; *  ROW0 - row zero logic
; *- Distinguishes nulls from short labels
; *- Skips all nulls
; *- IN:  C[3:]= function code
; *-      PT= 3
; *- OUT: PT= 3
; *- USES: C[2]

ROW0:         c=c-1   xs            ; -
              gonc    SLBL          ; short LBL
NULL:         golong  RUNING        ; skip all nulls


              .public ASN20
              .public XASN

; *  ASN - assign function to keycode
; *- This code performs an assignment function and also
; *- clears assignments.  ROM functions are assigned
; *- by placing the function code & keycode in an
; *- assignment table.  RAM functions are assigned by
; *- placing the keycode in the corresponding alpha
; *- label.  The assignment bit map is maintained and
; *- ASN table registers are created by this code also.
; *- IN:  A[1:0]= keycode to be assigned/cleared
; *-      REG 9 = alpha string/zero
; *- OUT:
; *- USES: A,B,C,M,N,G,REG 9,REG 10,status bits 3,8,9,2,5
; *- USES: 3 subroutine levels

XASN:         c=regn  9             ; remove assignment?
              m=c                   ; -
              ?c#0                  ; -
              golnc   ASN20         ; yes
              c=regn  10            ; save keycode in reg 10
              acex    wpt           ; -
              regn=c  10            ; -
              gsblng  ASRCH         ; C[3:0]_ALBL addr
              ?c#0                  ; error?
              golnc   SERR          ; yes
              regn=c  9             ; REG 9_ALBL addr & F.C.
              c=regn  10            ; A[2:1]_K.C.
              a=c     x             ; -
              gsblng  TBITMA        ; test bit map
              ?c#0                  ; bit set?
              gonc    XASN02        ; no
              c=regn  10            ; clear keycode entry
              a=c                   ; -
              s1=     1             ; -
              gsblng  GCPKC         ; -
              goto    .+3
XASN02:       gsblng  SRBMAP        ; set bit
              c=regn  10            ; A[3:2]_K.C.  A[1:0]_0
              a=c     x             ; -
              asl                   ; -
              asl                   ; -
              c=regn  9             ; B[3:0]_F.C.
              rcr     4             ; -
              bcex                  ; -
              ?s2=1                 ; place in RAM?
              goc     XASN05        ; NOPE
              c=regn  9             ; C[3:0]_ALBL address
              acex                  ; yes
              rcr     2             ; -
              bcex                  ; save K.C.
              pt=     3             ; -
              gsblng  INCAD2        ; -
              gsblng  INCADA        ; -
              gsblng  GTBYT         ; get keycode byte
              abex                  ; test for assign same key
              pt=     1             ; -
              ?a#c    wpt           ; -
              rtn nc                ; keys equal
              abex                  ; place key code
              pt=     3             ; -
              m=c                   ; -
              bcex                  ; -
              gsblng  PTBYTA        ; -
              pt=     1             ; test to update bit map
              c=m                   ; -
              ?c#0    wpt           ; -
              rtn nc                ; not needed
              acex                  ; -
              c=0     x             ; -
              dadd=c                ; -
              golong  TSTMAP        ; update bit map
XASN05:       gsblng  GCPKC         ; place K.C. & F.C.
              ?s3=1                 ; done?
              rtn c                 ; yes
              c=0                   ; construct register to insert
              c=b     wpt           ; -
              rcr     10            ; -
              acex    wpt           ; -
              rcr     2             ; -
              c=c-1   s             ; -
              bcex                  ; B_REG to insert
              gsblng  AVAILA        ; any room?
              ?c#0                  ; -
              goc     ASN15         ; yes
              dadd=c                ; enable chip 0
              abex
              gosub   TSTMAP        ; clear bit in bit map
              golong  PACKE

              .public ASN15         ; entry point made for Card Reader

ASN15:        dadd=c                ; select register
              m=c                   ; save addr
              c=data                ; switch reg contents
              bcex                  ; -
              data=c                ; -
              c=m                   ; increment addr
              c=c+1   x             ; -
              ?a<c    x             ; END?
              gonc    ASN15         ; -
              rtn                   ; return
ASN20:        b=a                   ; save F.C. & K.C.
              gsblng  TSTMAP        ; update bit map
              abex                  ; A[1:0]_K.C.
              s1=     1             ; -
              golong  GCPKC         ; CLEAR K.C.

; *
; * SAVRTN - save return address in REG 10 [3:0]
; * SAVRC - save return conditioned on S7
; * SAVR10 - save the address in the A and C registers [3:0]
; *     SAVR10 requires PT=3 on entry
; *
              .public SAVRTN
              .public SAVRC
              .public SAVR10
SAVRTN:       gosub   GETPC         ; rtns PC in both A and C
SAVR10:       ?s10=1                ; ROMFLAG?
              goc     SAVR20        ; yes
              c=0     x             ; pack RAM address into 3 digits
              csr     wpt
              a=a+c   x
              a=0     pt
SAVR20:       c=regn  10
              acex    wpt
              regn=c  10
              rtn

SAVRC:        ?s7=1                 ; XEQ?
              goc     SAVRTN        ; yes
              a=0     x             ; save X000 to
              pt=     3             ;  remember this is
              goto    SAVR20        ;   GTO

              .public IORUN
IORUN:        ldi     11            ; main running loop
                                    ; fall into ROMCHK here
; *
; * ROMCHK - plug-in ROM check subroutine
; * Looks at locations at the end of ROM chips 5-F
; * If the location is non-zero, then does a gotoc to that location
; * Locations to be checked are specified in C.X on entry:
; *      Pause loop (-FF4) ... C.X=12 NOTE - must return in a multiple
; *          of 80 states and adjust pausetimer accordingly
; *      Main running loop (-FF5) ... C.X=11
; *      Wake up from deep sleep with no key down (-FF6) ... C.X=10
; *      OFF location (-FF7) ... C.X=9
; *      I/O service (-FF8) ... C.X=8
; *      Wakeup from deep sleep (-FF9) ... C.X=7
; *      Cold start (-FFA) ... C.X=6
; *
; * FOR ENTRY:  hex mode, P selected, SS0 up, chip 0 selected
; * Plug-in ROMs must preserve C[10:3] and return to RMCK10 with
; *     hex mode, P selected, status set 0 up, and chip 0 selected.
; *     Plug-in ROMs may return to RMCK15 (saving one word-time) if
; *     all of the above conditions are satisfied and in addition
; *     ptr P=6.
; * All subroutine levels are available except in I/O service entry.
; * If PKSEQ is set then I/O service routines must either preserve
; * three subroutine returns on the subroutine stack or else terminate
; * the partial key sequence.

              .public ROMCHK
ROMCHK:       a=c     x             ; save addr in A.X
              s2=     0             ; clear IOFLG
              c=regn  14
              c=st
              regn=c  14            ; store SS0
              acex    x             ; restore addr
              .public RMCK05        ; pause loop enters here
RMCK05:
              rcr     1
              c=stk
              rcr     13
              pt=     3
              lc      4
              c=-c    x
              rcr     11
; * C now has ROMCHK's return address in digits 10:7 and the target
; * address in the plug-in ROMs in digits 6:3 (Note chip # is 4 at
; * present, but will be incremented to 5, the lowest possible
; * plug-in address).
              .public RMCK10
RMCK10:       pt=     6
              .public RMCK15
RMCK15:       c=c+1   pt
              gonc    RMCK20
#if defined(HP41CX)
              golong  RMCK03        ; inspect page 3 poll vector
#else
              rcr     4
              gotoc                 ; return to calling PGM
#endif

RMCK20:       cxisa
              ?c#0    x
              gonc    RMCK15
              gotoc
