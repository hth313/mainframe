;;; ***************************************************************************
;;; This is the HP41 operating system resurrected.
;;;
;;; Credits: HP for being so kind to release lots of internal information
;;;          many years ago.
;;;          Ángel Martin for sharing his deciphering work.
;;;
;;; Based on disassembler output, brought to order by Ángel's deciphering
;;; work and with the help of VASM printouts, Håkan Thörngren put it
;;; together in the summer of 2016 to allow the HP41 operating system
;;; to be built from source again. It is my guess that the previous time an
;;; HP41 operating system was built was about 30 years ago.
;;;
;;; I do not have access to all information and more work is needed to bring
;;; everything in control. Feel free to improve on the comments, structure and
;;; contents as well as improving on the code base.
;;;
;;; What is the point of all this then? Why do we want to be able to
;;; build the HP41 operating system from source again?
;;; Because the HP41 is a very useful system, and thanks to Monte Dalrymple,
;;; we now have the NEWT, which takes the HP41 to the next level.
;;; The missing piece to unlock the full potential, is that we need to make
;;; changes to the operating system and this work makes that possible.
;;; ***************************************************************************

#include "hp41cx.h"

;;; Switch to bank 1 and go to destination.
golBank1H:    .macro  dest
              gosub   ENB1GOH
              .con    .low8 (\dest), .high8 (\dest)
              .endm

golBank1:     .macro  dest
              gosub   ENB1GO
              .con    .low8 (\dest), .high8 (\dest)
              .endm

;;; Bank 2 in page 5
              .section PAGE5_2
              .public GETKEYX2
              nop
GETKEYX2:     c=regn  3
              gosub   CHK_NO_S
              s9=     0
              ?c#0    s
              goto    LB_5008
              s9=     1
LB_5008:      c=c+1   x
              a=c
              c=c-1   xs
              c=c-1   xs
              golc    ERRDE
              gosub   ENLCD
              readen
              cstex
              s0=     0
              s7=     0
              cstex
              ?s7=1
              gonc    LB_5018
              c=c+1   x
LB_5018:      wrten
              c=0     x
              pfad=c
              gosub   LB_3242
              b=a     x
              ?c#0    x
              gonc    LB_5028
              .newt_timing_start
LB_5020:      ldi     158
              a=a-1   x
              gonc    LB_5028
              clrabc
              m=c
              golong  LB_50BC
LB_5028:      chk kb
              goc     LB_502D
              c=c-1   x
              gonc    LB_5028
              goto    LB_5020
              .newt_timing_end
LB_502D:      gosub   ENLCD
              c=regn  5
              st=c
              c=keys
              rcr     3
              c=0     xs
              a=c     x
              pt=     0
              c=c+c   pt
              gonc    LB_503A
              c=0
              goto    LB_504E
LB_503A:      ldi     18
              ?a#c    x
              goc     LB_5045
              gosub   LB_3298
              abex    x
              b=a     x
              gosub   LB_5A69
              goto    LB_5020
LB_5045:      ldi     196
              ?a<c    x
              goc     LB_5051
              a=a-c   x
              c=0
              lc      3
              acex    x
              c=a-c   x
LB_504E:      c=c+1   x
              rcr     2
              goto    LB_5064
LB_5051:      asl     x
              a=a+1   xs
              pt=     2
              c=0
              lc      2
              c=c-1   wpt
LB_5057:      a=a-c   x
              gonc    LB_5057
              ldi     49
              ?a#c    pt
              goc     LB_5060
              ?a#c    wpt
              gonc    LB_5060
              a=a-1   x
LB_5060:      a=a+1   pt
              acex    wpt
              rcr     3
              c=c+1   x
LB_5064:      s8=     0
              ?s7=1
              gonc    LB_506B
              s8=     1
              setdec
              c=c-1   s
              sethex
LB_506B:      m=c
              gosub   LDSST0
              c=m
              rcr     11
              pt=     0
              ?c#0    pt
              gonc    LB_5097
              a=0     x
              a=c     pt
              a=a-1   pt
              asl     x
              csr     x
              a=c     pt
              a=a-1   pt
              ldi     3
              ?a#c    pt
              goc     LB_5082
              pt=     1
              ?a#0    pt
              gonc    LB_5082
              a=a+1   pt
LB_5082:      ldi     8
              ?s7=1
              goc     LB_5089
              ?s8=1
              gonc    LB_508B
              goto    LB_5097
LB_5089:      ?s8=1
              gonc    LB_508C
LB_508B:      a=a+c   x
LB_508C:      ldi     341
              c=0     s
              rcr     13
              c=a+c   x
              rcr     11
              cxisa
              ?c#0    x
              gonc    LB_5097
              ?c#0    xs
              gonc    LB_5099
LB_5097:      b=0
              goto    LB_50B8
LB_5099:      a=c     x
              ?s7=1
              goc     LB_50A0
              gosub   LB_5AB0
              goto    LB_50A0
              goto    LB_5097
LB_50A0:      acex    x
              a=0
              setdec
              c=0     m
              rcr     12
              c=a+c   m
              c=c+c   m
              c=c+c   m
              c=c+c   m
              c=c+c   m
              a=a+c   xs
              gonc    LB_50AF
              rcr     1
              c=c+1   m
              rcr     13
LB_50AF:      asl
              c=a+c   m
              c=0     x
              rcr     7
              c=c+1   x
              c=c+1   x
              a=c
              gosub   BIND25
LB_50B8:      sethex
              ?s9=1
              gosub   RSTKB
LB_50BC:      s7=     1
              gosub   TGLSHF2
              c=regn  1
              regn=c  0
              c=regn  2
              regn=c  1
              c=m
              regn=c  2
              golBank1H FILLXL
KEYCDE:       c=0     m
              rcr     11
              a=c     m
              c=stk
LB_50CD:      cxisa
              c=c+1   m
              ?c#0    x
              gonc    LB_50D4
              ?a#c    x
              goc     LB_50CD
              c=0     x
LB_50D4:      c=a+c   m
              gotoc


              .public GETP2
GETP2:        gosub   GTFLNA        ; get file name from alpha register
              gosub   FSCHP         ; search for the program in ex.mem
              ?s9=1                 ; GETSUB ?
              goc     RP150         ; no, it is GETP
              gosub   GTFEND        ; get final end address
              a=0     pt
              goto    RP245
RP150:        ?s13=1                ; running ?
              goc     RP200         ; yes, see if in last prgm
              c=0
              dadd=c
              c=regn  14
              st=c
              ?s4=1                 ; single stepping ?
              gonc    RP240         ; no, change PC
RP200:        ?s10=1                ; are we in ROM ?
              goc     RP220         ; yes, don't change PC
              gosub   FLINKP        ; find program end
              rcr     8
              a=c     wpt           ; A[3:0]= current program end
              gosub   INCADA
              gosub   NXBYTA        ; get third byte of "END"
              cstex
              ?s5=1                 ; is this final END ?
              goc     RP240         ; yes, change PC
RP220:        s9=     0             ; remember don't change PC
RP240:        gosub   GTFEND        ; get final END addr
              gosub   CPGM10        ; get current program head
RP245:        b=a     wpt           ; B[3:0]= starting addr
              gosub   MEMLFT        ; compute available regs
              a=c     x             ; A.X= # of ununsed mem regs
              c=0
              dadd=c
              c=b     wpt
              regn=c  9
              m=c                   ; M[3:0]= prog head addr
              c=regn  13
              acex    x
              a=a-c   x
              a=0     pt
              abex    wpt
              gosub   CNTBY7        ; compute total available bytes
              c=n
              c=0     s
              rcr     3             ; C.X= prog size in bytes
              ?a<c    x             ; enough room ?
              gonc    RP250
              golBank1 NORMEX       ; say "NO ROOM" or "PACK, TRY AGAIN"
RP250:        csr     m             ; C[9:6]= last byte addr in ex.mem
              n=c                   ; N[9:6]= last byte addr in ex.mem
              s3=     0             ; don't update base reg in NXCHR
;;; Now M[3:0] = last byte addr in main memory
;;;     M[6:4] = running checksum
;;;     N[9:6] = last byte addr in ex.mem
;;;     N.X    = byte count
RP300:        c=n
              rcr     6
              a=c                   ; A[3:0]= last byte addr in ex.mem
              gosub   NXCHR
              gosub   GTBYTA
              acex
              rcr     8
              c=c-1   x             ; is this the checksum byte ?
              goc     RP310         ; yes
              n=c
              c=m
              acex
              gosub   INCADA
              gosub   PTBYTA        ; leaves C[1:0] in B[1:0]
              acex
              rcr     4             ; update checksum
              abex    x
              c=a+c   x
              rcr     10
              m=c
              goto    RP300
RP310:        s8=     0             ; assume checksum will match
              c=m
              rcr     4             ; C.X = accumulated checksum
              a=c     xs
              ?a#c    x             ; checksum match ?
              gonc    CLEANM        ; yes
              s8=     1             ; set checksum error flag
              c=0
              dadd=c
              c=m
              a=c                   ; A[3:0]= last byte addr in main mem
              c=regn  13
              ?a<c    x
              gonc    RP320
              acex    x
              regn=c  13
RP320:        c=regn  9
              a=c                   ; A[3:0]= beginning of this program

              .public RP330
RP330:        gosub   INCADA        ; point to first byte of the "END"
              ldi     0xc0          ; put and "END" to the beginning of the
              gosub   PTBYTA        ; write C0 to the first byte
              gosub   INCAD2        ; point to third byte of the "END"
              c=0     x
              gosub   PTBYTA        ; put 00 the the third byte of the "END"

CLEANM:       c=0
              m=c
              dadd=c
              c=regn  9             ; get starting addr
              a=c
              ?s9=1                 ; running or single stepping ?
              gonc    RP405         ; yes, don't change PC
              s10=    0             ; clear ROM flag
              gosub   PUTPCX
RP405:        c=regn  13            ; get addr of reg.0
              rcr     3
              ?a#c    x             ; starting from reg.0 ?
              gonc    RP410         ; yes
              gosub   GTBYTA        ; change previous final end
              cstex                 ;  to local end
              s5=     0
              cstex
              gosub   PTBYTA
              gosub   DECADA        ; point to first of previous END
              gosub   DECADA
              c=a
              m=c                   ; save previous link addr in M
RP410:        c=0
              dadd=c
              c=regn  9             ; restore program head to A
              a=c
              c=regn  14
              rcr     7             ; get user mode flag
              st=c
              s7=     0
              sel q
              pt=     13
              sel p
              pt=     13
              lc      12
              lc      13
              a=c     pq
RP425:        pt=     3
;;; start set link here - look at next byte see in an alpha LBL
RP430:        b=a     wpt
              gosub   NXBYTA
              rcr     2
              pt=     12
              ?c#0    pq            ; NULL ?
              gonc    RP425         ; yes
              ?a#c    s             ; an END or alpha LBL ?
              goc     RP450         ; no
              ?a<c    pt            ; X<>N or LBL.NN ?
              goc     RP450         ; yes
              pt=     3
;;; see if it is an END
              b=a     wpt
              gosub   INCAD2
              gosub   GTBYTA
              rcr     12
              abex    wpt
              c=c+1   pt
              gonc    RP470         ; it is an END
;;; recompute the link for an alpha label
              c=m
              acex    wpt
              gosub   GENLNK
              a=c     wpt
              m=c
              ?s0=1                 ; are we in user mode ?
              goc     RP440         ; yes, don't clear the key code
              gosub   INCAD2
              gosub   INCADA        ; point to key code
              c=0     x
              gosub   PTBYTA        ; clear the key code
              c=m
              a=c     wpt
RP440:        gosub   DECADA        ; point to one byte before alpha LBL
              goto    RP460
RP450:        pt=     3
              abex    wpt
RP460:        gosub   NXLDEL        ; SKPLIN entry not check ROM flag
              goto    RP430

;;; Set link for final END and put it to proper place.
;;; (final END has to be right justified in a register)
RP470:        c=c-1   pt            ; restore end byte
              rcr     2             ; move it to C[1:0]
              st=c                  ; save byte in status
              s5=     1             ; set bit for final END
              b=a     pt            ; save byte pointer in B[3]
              goto    RP477
RP475:        gosub   INCADA
RP477:        c=0     x
              gosub   PTBYTA
              ?a#0    pt
              goc     RP475
              abex    pt            ; restore byte pointer
              lc      4
              pt=     3
              ?a<c    pt            ; can .END. fit in this register ?
              goc     RP480         ; no
              a=c     pt
              goto    RP490
RP480:        acex    x
              c=c-1   x             ; put .END. to next reg
              dadd=c
              a=c     wpt
              c=0
              data=c
;;; Generate link for final END.
RP490:        c=m
              acex    wpt
              gosub   GENLNK        ; leaves C in M
;;; Update chain head
              dadd=c
              c=data                ; give last byte to final END
              c=st                  ; get byte back from status
              pt=     0
              lc      13
;;; Clear memory between old final END and new final END
              data=c
              c=m                   ; get new .END.addr
              a=c     x
              c=0     x
              dadd=c
              c=regn  13            ; get old final END
              acex    x
              regn=c  13            ; update new final END addr
              b=0
CLM15:        ?a<c    x             ; we done ?
              gonc    RSTKCA        ; yes, goto rebuild key assignment
              c=c-1   x
              dadd=c
              bcex
              data=c
              bcex
              goto    CLM15

;;; **********************************************************************
;;; * RSTKCA - rebuild the key reassignment bit maps
;;; *  After reading in the status tracks, it destroyed the old bitmaps,
;;; *  so they have to be rebuilt. Int this case, the key reassignment
;;; *  just read in will take precedence. Reading in a program will destroy
;;; *  the key code used in the last program. If a program is read in in
;;; *  user mode, the key assigned to any alpha label in the program
;;; *  just read in should take precedence. Therefore, after reading
;;; *  in a program, the bit map has to be rebuilt too.
;;; *  The procedure is as following:
;;; *  1. Clear the bitmap
;;; *  2. Restore the key reassignments of mainframe functions & XROM functions
;;; *  3.  Restore key reassignments in alpha labels; if the key has already
;;; *      been assigned to another function:
;;; *    A. If it is after reading in a status track, clear the key code
;;; *       in the alpha label.
;;; *    B. If it is after reading in a program, find the key code somewhere
;;; *       else and clear it there.

              .public RSTKCA
RSTKCA:       gosub   ENCP00
              c=regn  15
              c=0     m             ; clear bit map
              c=0     s
              regn=c  15
              ldi     191
;;; Get the key code from key reassignment record and set its bit
;;; in bit map.
RTKC10:       c=c+1   x
              s7=     0
              regn=c  10
              a=c
              c=regn  13
              acex
              ?a#c    x             ; reach chain head ?
              gonc    RTKC30        ; yes, done with all those registers
RTKC15:       dadd=c
              c=data
              a=c                   ; save C in A temp
              c=0     x
              dadd=c
              acex                  ; restore C
              c=c+1   s             ; still a key reassigment reg ?
              gonc    RTKC30        ; no, done with all those registers
              pt=     1
              ?s7=1                 ; first key code ?
              gonc    .+2           ; yes
              rcr     6
              ?c#0    wpt           ; is there a key code ?
              gonc    RTKC20        ; no
              a=c
              gosub   TBITMA
              gosub   SRBMAP        ; set the bit in the map
RTKC20:       c=regn  10
              ?s7=1                 ; done with second key code ?
              goc     RTKC10        ; yes
              s7=     1
              goto    RTKC15
RTKC30:       c=regn  9             ; get starting load addr
              pt=     3
              a=c     wpt
              gosub   DECADA        ; point to previous END addr
              gosub   DECADA
              c=regn  10
              acex    wpt
              regn=c  10            ; save the addr in Reg.10
RTKC40:       gosub   GTFEND
RTKC45:       pt=     3
              gosub   GTLINK
              ?c#0    x             ; chain end ?
              goc     RTKC50        ; not yet
              ?s8=1                 ; checksum error ?
              goc     RTKC47        ; yes
NFRPU_B1:     golBank1H NFRPU        ; no
RTKC47:       gosub   APERMG        ; say "CHKSUM ERR"
              .messl  "CHKSUM"
              golong  DISERR
RTKC50:       gosub   UPLINK
              c=c+1   s             ; is it an END ?
RTKC55:       gonc    RTKC45        ; yes
              c=0     x
              dadd=c
              acex    wpt
              regn=c  9             ; save link & addr in Reg.9
              a=c     wpt
              gosub   INCAD2        ; point to key code of alpha LBL
              gosub   NXBYTA        ; get key code
              acex    wpt
              n=c
              c=0     x
              dadd=c
              c=regn  13
              m=c
              a=0     xs
              ?a#0    x             ; is there a key code ?
              gonc    RUSR40        ; no
              b=a     x
              gosub   TBITMA        ; test the bit map
              ?c#0                  ; is this bit set ?
              gonc    RUSR30        ; no, just set it
              abex    x             ; clear key code somewhere else
              c=regn  10
              rcr     10
              bcex
              s1=     1
              gosub   GCPKC0
              goto    RUSR40
RUSR30:       gosub   SRBMAP        ; set bit map
RUSR40:       c=regn  9
              a=c
              goto    RTKC55

              .public `X=NN? 2`
`X=NN? 2`:    gosub   LB_5274
              a#c?
              gonc    LB_5253
LB_524F:      golBank1H SKP
LB_5253:      golBank1H NOSKP
              .public `X≠NN? 2`
`X≠NN? 2`:    gosub   LB_5274
              a#c?
              goc     LB_5253
              goto    LB_524F
              .public `X<=NN? 2`
`X<=NN? 2`:   gosub   LB_5274
LB_525E:      gosub   LB_52A7
              ?c#0    s
              gonc    LB_524F
              goto    LB_5253
              .public `X<NN? 2`
`X<NN? 2`:    gosub   LB_5274
              a#c?
              gonc    LB_524F
              goto    LB_525E
              .public `X>=NN? 2`
`X>=NN? 2`:   gosub   LB_5274
              a#c?
              gonc    LB_5253
LB_526C:      gosub   LB_52A7
              ?c#0    s
              gonc    LB_5253
              goto    LB_524F
              .public `X>NN? 2`
`X>NN? 2`:    gosub   LB_5274
              goto    LB_526C
LB_5274:      c=0
              c=c+1   s
              ldi     76
              a=c
              c=regn  2
              ?a#c    s
              gonc    LB_5286
              gosub   LB_3260
              a=c     x
              c=regn  13
              rcr     3
              c=a+c   x
              gosub   CHKADR
              abex
              goto    LB_5291
LB_5286:      acex
              a#c?
              goc     LB_5297
              c=c+1   m
LB_528A:      c=c+1   m
LB_528B:      c=c+1   m
LB_528C:      c=c+1   m
LB_528D:      rcr     3
              dadd=c
              c=data
              a=c
LB_5291:      b=a
              s7=     0
              c=0
              dadd=c
              c=regn  3
              rtn
LB_5297:      ldi     84
              a#c?
              gonc    LB_528D
              ldi     90
              a#c?
              gonc    LB_528C
              c=c-1   x
              a#c?
              gonc    LB_528B
              c=c-1   x
              a#c?
              gonc    LB_528A
              golong  ERRDE
LB_52A7:      a=c
              setdec
              c=0
              c=c+1   s
              ?a#c    s
              gonc    LB_52C4
              abex    s
              ?a#c    s
              rtn nc
              abex    s
              c=b
              ?a#c    s
              goc     LB_52BD
              a#0?
              gonc    LB_52BD
              c#0?
              rtn nc
              ?a#c    x
              gonc    LB_52BF
              c=a-c   x
              c=c+c   xs
              rtn nc
LB_52BD:      c=-c-1  s
              rtn
LB_52BF:      c=a-c
              ?a#0    s
              goc     LB_52BD
              c=c-1
              rtn
LB_52C4:      c=b
              ?a#c    s
              gonc    LB_52C9
              c=0     s
              rtn
LB_52C9:      sel q
              pt=     13
              sel p
              pt=     10
              c=0     s
              c#0?
              goc     LB_52D2
              goto    LB_52D4
LB_52D1:      rcr     12
LB_52D2:      ?c#0    pq
              gonc    LB_52D1
LB_52D4:      acex
              c=0     s
              c#0?
              goc     LB_52DA
              gonc    LB_52DC
LB_52D9:      rcr     12
LB_52DA:      ?c#0    pq
              gonc    LB_52D9
LB_52DC:      a<c?
              gonc    LB_52BD
              rtn

              .public RESZFL2
RESZFL2:      gosub   LB_33E9
              rcr     5
              a=c
              c=0     x
              dadd=c
              acex
              regn=c  9
              gosub   EFLSCH
              c=0
              dadd=c
              c=regn  9
              b=a     m
              abex    x
              acex
              regn=c  9
              ldi     64
              dadd=c
              acex
              data=c
              b=0     s
              gosub   CURFL
              c=0
              dadd=c
              s7=     0
              c=n
              c=c-1   s
              c=c-1   s
              c=c-1   s
              goc     LB_5304
              c=c-1   s
              golong  FLTPER
              s7=     1
LB_5304:      gosub   `X<999`
              ?c#0    x
              golong  ERRDE
              b=a     x
              c=n
              ?a#c    x
              golnc   TOBNK1
              pt=     3
              ?a<c    x
              golc    LB_5369
              a=a-c   x
              c=regn  9
              acex    x
              ?a<c    x
              golc    NO_ROOM
              m=c
              c=n
              rcr     10
              a=c     x
              dadd=c
              rcr     4
              c=c+1   x
              bcex    x
              data=c
              a=0     pt
              b=0     pt
              gosub   ADVADR
              acex
              cmex
              bcex    x
              rcr     8
              n=c
              a=c     x
              a=0     pt
              gosub   ADVADR
              c=n
              bcex    x
              ?s2=1
              gonc    LB_5349
              b=a     x
              s2=     0
              ldi     64
              a=c     x
              gosub   NXTMDL
              ?s2=1
              gsubc   NXCH30
              c=b     x
              ?a#c    xs
              gonc    LB_5346
              pt=     1
              a=0     wpt
              a=a+1   wpt
              gosub   NXTMDL
              gosub   NXCH30
LB_5346:      abex    x
              c=n
              bcex    x
LB_5349:      c=b     x
              dadd=c
              c=data
              acex    x
              dadd=c
              acex    x
              data=c
              c=m
              abex    x
              ?a#c    x
              goc     LB_5361
              abex    x
LB_5355:      gosub   LB_3B14
              acex    x
              a=c     x
              dadd=c
              c=0
              data=c
              c=m
              ?a#c    x
              goc     LB_5355
              golong  TOBNK1
LB_5361:      s0=     0
LB_5362:      gosub   LB_3B14
              ?s0=1
              goc     LB_5349
              abex    x
              s0=     1
              goto    LB_5362
LB_5369:      c=c+1   x
              bcex    x
              n=c
              b=0     pt
              rcr     10
              a=c     x
              a=0     pt
              gosub   ADVADR
              acex    x
              m=c
              c=n
              c=c+1   x
              bcex    x
              rcr     10
              a=c     x
              gosub   ADVADR
              c=m
              rcr     11
              acex    x
              m=c
              ?s7=1
              gonc    LB_53B4
              bsr     m
              s6=     0
              gosub   TXTEND
              abex    m
              asl     m
              b=a     m
              c=m
              rcr     8
              a=c     x
              c=m
              ?a#c    xs
              goc     LB_539C
              acex    x
              ?a<c    x
              goc     LB_53A7
LB_5391:      gosub   APERMG
              .messl  "FL SIZE"
              golong  DISERR
LB_539C:      gosub   NXTMDL
              ?s2=1
              goc     LB_5391
              c=m
              ?a#c    xs
              gonc    LB_53A7
              gosub   NXTMDL
              ?s2=1
              goc     LB_5391
LB_53A7:      c=m
              bcex    x
              rcr     3
              acex    x
              c=n
              rcr     10
              dadd=c
              rcr     4
              data=c
              golBank1 PAKEXM
LB_53B4:      bcex    x
              c=n
              a=c     x
              a=a-1   x
              rcr     3
              acex    x
              ?a<c    x
              goc     LB_53A7
              rcr     11
              n=c
              c=0
              dadd=c
              c=regn  3
              c=c+c   s
              goc     LB_53A7
              abex    x
LB_53C4:      acex    x
              a=c     x
              dadd=c
              c=data
              c#0?
              goc     LB_5391
              gosub   ADVAD1
              c=m
              rcr     3
              ?a#c    x
              goc     LB_53C4
              goto    LB_53A7

              .fillto 0x400
              .public EMDIR2
EMDIR2:       pt=     11
              ?b#0    pt
              goc     LB_5421
              chk kb
              goc     LB_540E
              c=0     x
              .newt_timing_start
EMDR45:       c=c+1   x
              gonc    EMDR45
              .newt_timing_end
              chk kb
              goc     LB_540E
EMDR50:       golBank1 EMDR10
LB_540E:      gosub   CAT_STOP
              ?a#c    x
              gonc    LB_541B
              ldi     400
              .newt_timing_start
LB_5414:      c=c-1   x
              gonc    LB_5414
              .newt_timing_end
              rst kb
              chk kb
              gosub   RSTKB
              goto    EMDR50
LB_541B:      pt=     11
              c=0     pt
              c=c-1   pt
              bcex    pt
              gosub   LB_5A69
LB_5421:      c=0
              pt=     7
              lc      2
              .newt_timing_start
LB_5424:      chk     kb
              goc     LB_5430
              ?lld
              gonc    LB_542A
              c=c-1   m
              goc     LB_542C
LB_542A:      c=c-1   m
              gonc    LB_5424
              .newt_timing_end
LB_542C:      golBank1 CLDSP
LB_5430:      gosub   CAT_STOP
              ?a#c    x
              goc     LB_543C
              gosub   LB_5A69
              pt=     11
              b=0     pt
              s7=     1
              gosub   TGLSHF2
LB_543B:      goto    EMDR50
LB_543C:      gosub   LB_5A69
              gosub   ENLCD
              readen
              st=c
              ldi     18
              ?a#c    x
              goc     LB_5449
              gosub   LB_3298
LB_5448:      goto    LB_5421
LB_5449:      ldi     194
              ?a#c    x
              goc     LB_5461
              c=0     x
              pfad=c
              ?s7=1
              gonc    LB_543B
              gosub   TGLSHF2
              gosub   `CUR#`
              c=c-1   x             ; decrement file counter
              ?c#0    x             ; last one ?
              goc     LB_545B       ; no
              gosub   BLINK1        ; yes
              goto    LB_5448
LB_545B:      rcr     5
              data=c
              golBank1 EMDR15
LB_5461:      c=c+1   x
              ?a#c    x
              goc     LB_5448
              s7=     1
              gosub   LB_3299
              goto    LB_542C

              .public GTRC05
GTRC05:       gosub   CURFLT        ; get current text file
              s5=     1
              s8=     0
              gosub   `CUREC#`      ; point to current pointer
              ?s0=1                 ; reached EOF ?
              gonc    GTRC10        ; no
              golBank1 EOFL
GTRC10:       c=0                   ; enable chip 0
              dadd=c
              s8=     1             ; indicate not yet reached end of rec
              ?s7=1                 ; CLA ?
              gonc    GTRC20        ; not for "ARCLREC"
              gosub   CLA           ; yes
              a=0     x             ; say alen = 0
              goto    GTRC25
GTRC20:       gosub   ALEN          ; get current alpha length
GTRC25:       ldi     24
              acex    x
              a=a-c   x             ; A.X= no. of chars to fill alpha
              c=n
              rcr     6             ; C.X= current char pointer
              bcex                  ; B.X= current char pointer
              rcr     7             ; C.X= current record length
              acex    x             ; A.X= curr rec len; C.X= chars to fill
              a=a-b   x             ; A.X= # of chars left in record
              acex    x             ; A.X= char to fill; C.X= chars left
              ?a<c    x             ; more than 24 characters left ?
              goc     GTRC30        ; yes, will not reach EOR this time
              s8=     0             ; reached for
              acex    x             ; A.X= # of chars left in record
GTRC30:       abex    x             ; B.X= # of chars to read
              c=m
              rcr     2             ; C[9:6]= next char addr in file
              c=b     x             ; C.X= # of chars to read
              m=c
              c=n
              rcr     3             ; C.X = current record pointer
              a=c     x
              gosub   UPRCAB        ; update record pointer
              c=0
              dadd=c
              c=regn  14            ; set or clear user flag 17
              rcr     9
              cstex
              s2=     0
              ?s8=1
              gonc    GTRC40
              s2=     1
GTRC40:       cstex
              rcr     5
              regn=c  14
;;; Now M[2:0] = # of chars
;;;     M[9:6] = next char addr in file
GTRC50:       c=m
              c=c-1   x             ; done yet ?
              golc    TOBNK1        ; yes, return via switching to bank 1
              rcr     6
              a=c                   ; A[3:0]= next char addr in file
              gosub   GTBYTA
              bcex    x             ; save the byte in B.X temp
              gosub   NXCHR         ; does not change A[13:8]
              acex
              rcr     8
              m=c
              c=b     x
              pt=     0
              g=c
              c=0
              dadd=c
              gosub   APNDNW
              pt=     3
              goto    GTRC50

              .public GETAS2
GETAS2:       gosub   GTFLNA        ; get source file name
              gosub   FNDPIL        ; see if cassette drive there ?
              c=0     s
              c=c+1   s
              gosub   FLSCH
              gosub   SEEKRN        ; seek to beginning of the file and read it
              gosub   UNT           ; untalk it for now
              gosub   GTFLNA
              ?s6=1                 ; destination file name the same as source ?
              gonc    RDT120        ; yes
              gosub   ALNAM2        ; get destination file name
RDT120:       gosub   FSCHT         ; search for the text file
              c=n
              rcr     10
              dadd=c                ; enable file header register
              a=c     x
              a=0     pt
              c=data                ; zero record & char pointer in file
              c=0     m
              data=c
              gosub   BYTLFT        ; compute destination file size in bytes
              a=a-1   wpt
              acex
              rcr     8
              m=c                   ; M[9:6]=file size, M[3:0]=last char addr
              gosub   TALKER        ; make the drive a talker
              gosub   SNDATA        ; start to send data
              c=m
              a=c     wpt           ; A[3:0]= last destination byte addr
RDT130:       gosub   NXCHR         ; point to next byte
              c=m
              c=a     wpt
              m=c
              .newt_timing_start
RDT135:       gosub   RDDFRM        ; read a byte from loop
              hpil=c  2             ; echo the data frame
              ?c#0    x             ; end of text ?
              goc     RDT210        ; yes
              gosub   RDDFRM        ; read second byte of record length
              ?s9=1                 ; any error ?
              goc     RDT200        ; yes, let's quit
              hpil=c  2             ; echo the data frame
              .newt_timing_end
              ?c#0    x             ; record length = 0 ?
              gonc    RDT135        ; yes, ignore this record
              n=c                   ; save record length in N.X
              gosub   PTBYTA
              c=m
              rcr     6             ; C[3:0]= destination file size remaining
              a=c
              c=n
              s8=     0             ; assume record length even
              cstex
              ?s0=1
              gonc    RDT140        ; record length even
              s8=     1             ; remember record length odd
RDT140:       cstex
              c=c+1   x             ; add one byte for record length
              a=a-c   wpt
              goc     RDT200        ; not enough room for this record
              acex
              rcr     8
              m=c
              a=c     wpt
RDT150:       c=n
              c=c-1   x             ; done with one record ?
              goc     RDT160        ; yes
              n=c
              gosub   NXCHR         ; point to next byte in destination file
              gosub   RDDFRM        ; read a byte from loop
              hpil=c  2             ; echo the data frame
              gosub   PTBYTA
              goto    RDT150
RDT160:       ?s8=1                 ; record length odd ?
              gonc    RDT170
              gosub   RDDFRM        ; if yes, read another byte and drop it
              hpil=c  2             ; echo the data frame
RDT170:       goto    RDT130
RDT200:       s8=     1             ; say reached end of destination file
              goto    RDT220
RDT210:       s8=     0             ; say not reached end of destination file
RDT220:       c=m
              a=c     wpt
              ldi     255
              gosub   PTBYTA
              golong  WRT260

              .public SAVEAS2
SAVEAS2:      gosub   FNDPIL        ; see if cassette drive there ?
              gosub   GTFLNA        ; get source file name
              ?s6=1                 ; source name = destination name ?
              gsubnc  AOUTIN        ; if same name, point to alpha head
              c=0     s
              c=c-1   s
              c=c-1   s
              bcex    s
              gosub   FLSCHX        ; search for destination file
              c=m
              ?c#0                  ; found the file in mass.mem ?
              golnc   FLNOFN        ; no, say "FL NOT FOUND"
WRT110:       s8=     0             ; yes
              pt=     13
              lc      11
              a=c     s
              c=n                   ; C.S = file type
              c=c-1   s             ; type 1 is ASCII file
              c=c-1   s
              goc     WRT130        ; it is an ASCII file
              s8=     1
              ?a#c    s             ; type 13 is a register file
              golc    FLTYER
WRT130:       gosub   CHKPCT        ; check if file is secured ?
              ?s8=1                 ; have to change reg file to ASCII file ?
              gonc    WRT135        ; no
              b=0     s             ; yes
              gosub   0x7821        ; HPIL, no entry point in VASM listings
              c=n
              c=0     s
              c=c+1   s
              n=c
              gosub   REWENT        ; change reg file to ASCII file
WRT135:       gosub   SEKSUB        ; seek to the beginning of the file
              c=n                   ; compute file size in bytes
              csr                   ; N[7:4]= file size in records
              c=0     x
              csr
              c=c-1
              c=c-1
              regn=c  9             ; Reg.9[3:0]= file size in bytes
              gosub   GTFLNA        ; get file name
              gosub   FSCHT
              c=0
              dadd=c
              c=regn  9
              m=c                   ; M[3:0]= destination file size in bytes
              c=n
              rcr     10
              a=c     x             ; A.X= file header addr
              a=0     pt            ; A[3:0]= last byte addr in source file
WRT200:       gosub   NXCHR     ; point to next byte in storage
              gosub   GTBYTA
              b=a     wpt
              s8=     0             ; assume is even record length
              c=0     xs
              n=c
              pt=     4
              a=0     wpt
              a=c     x             ; save record length in A.X too
              c=c-1   xs
              c=c+1   x             ; is it the end of text mark ?
              goc     WRT255        ; yes, all done
              c=c-1   x
              cstex
              ?s0=1                 ; record length odd ?
              gonc    WRT210        ; no
              s8=     1             ; remember record length odd
              a=a+1   wpt           ; have to send one more byte
WRT210:       cstex                 ; restore status bits 0-7
              a=a+1   wpt           ; add two bytes for record length
              a=a+1   wpt
              c=m                   ; C[3:0]= remaining file size of destination
              acex    wpt
              a=a-c   wpt
              goc     WRT250        ; not enough room to store this record
              acex    wpt
              m=c
              pt=     3
              c=0     x
              gosub   SDATA0        ; send first half of record length
              c=n
              gosub   SDATA         ; send second half or record length
              abex    wpt
WRT220:       c=n                   ; C.X= remaining bytes to send
              c=c-1   x             ; done with one record ?
              goc     WRT230        ; yes
              n=c
              gosub   NXCHR
              gosub   GTBYTA
              gosub   SDATA
              goto    WRT220
WRT230:       ?s8=1                 ; record length odd ?
              gonc    WRT200        ; no
              c=0     x             ; yes, send an additional byte
              gosub   SDATA
              goto    WRT200
WRT250:       s8=     1             ; reached end of destination file
WRT255:       ldi     255
              gosub   SDATA0        ; send end of text mark
              hpl=ch  1
              ch=     0x41          ; send the last frame as end frame
              ldi     255
              gosub   SDATA
              gosub   WAITS         ; check error

              .public WRT260
WRT260:       gosub   UNTCHK        ; untalk and check error
              ?s8=1                 ; reached end of destination file ?
              golnc   NFRPU_B1      ; no
              golong  EOFL

              .public APOS10
              .public APOSNF
APOS10:       c=regn  8
              rcr     7             ; save alpha length in Reg.8[9:7]
              acex    x
              rcr     7             ; Reg8[13:10]= alpha head addr
              regn=c  8             ; Reg8[9:7]  = alpha length
              s5=     1
              s8=     0             ; for point to next rec when at end
              gosub   `CUREC#`      ; get current pointer addr
APOS15:       ?s0=1                 ; reached end of file ?
              gonc    APOS17        ; no
APOSNF:       c=0                   ; yes, return "-1" to X
              ldi     145
              rcr     2
              bcex
              golong  LB_567A
APOS17:       c=b                   ; C[9:7] = current record length
              rcr     7
              a=c     x             ; A.X= current record length
              c=n                   ; n= file header
              rcr     6             ; C.X= current char pointer
              a=a-c   x             ; A.X=# of chars remaining in this record
APOS16:       c=m                   ; M[11:8]= current char addr
              rcr     5             ; C[6:3]= current char addr
              a=c     m             ; A[6:3]=curr.char.addr;A.X=remaining chars
              rcr     7             ; C[13:10]=start addr for an iteration
              bcex                  ; B[13:10]=start addr of current iteration
;;; Now Reg.8[13:10] = alpha head addr
;;;     Reg.8[9:7]   = alpha register length
;;;     A[6:3]       = current char addr in current record
;;;     A[2:0]       = # chars remaining in this record
;;;     B[13:10]     = starting addr for this iteration
APOS20:       c=0
              dadd=c
              c=regn  8
              pt=     6
              acex    wpt
              m=c
              pt=     3
;;; M[13:10] = alpha head addr
;;; M[9:7]   = alpha length
;;; M[6:3]   = current char addr in current record
;;; M[2:0]   = # of chars remaining in this record
              a=c     x             ; A.X = # of remaining chars
              rcr     7             ; C.X = alpha length
              ?a<c    x             ; remaining chars < alpha length ?
              goc     APOS70        ; yes, skip to next record
              rcr     3             ; C[3:0]= current alpha char addr
APOS30:       a=c
              gosub   GTBYTA        ; get next alpha char
              gosub   INCADA        ; point to next alpha char
              bcex    x             ; save the alpha char in B.X
              acex
              rcr     7             ; C[3:0]= current char addr in record
              a=c
              gosub   GTBYTA        ; get next char in record
              acex
              m=c                   ; M has been rotated right 3 digits
              s0=     0             ; assume no match this time
              c=b     x
              pt=     1
              ?a#c    wpt
              goc     APOS40        ; no match
              s0=     1             ; this char match
APOS40:       pt=     3
              c=m                   ; M has been rotated right 3 digits
              rcr     4             ; C.X= remaining alpha length
              c=c-1   x
              ?c#0    x             ; is this last alpha char ?
              goc     APOS50        ; no
              ?s0=1                 ; last char match ?
              goc     APOSFD        ; yes, we found it
APOS50:       ?s0=1                 ; last char match ?
              gonc    APOS60        ; no
              rcr     10
              m=c                   ; M has been rotated right 3 digits
              a=c     wpt
              gosub   NXCHR         ; point to next char in record
              c=m
              acex    wpt
              rcr     7             ; M has been RCR 10
              goto    APOS30
APOS54:       golong  APOS15
APOS56:       goto    APOS16
APOS70:       c=n                   ; skip to next record & continue search
              rcr     3
              c=c+1   x             ; increment record pointer
              rcr     3
              c=0     x             ; reset char pointer to zero
              rcr     8
              n=c
              c=m
              bcex    x             ; B.X= remaining record length
              rcr     3
              a=c     wpt           ; current char addr
              gosub   ADVREB        ; point to next record
              b=0
              s0=     0
              gosub   TXTE10        ; get next record addr & length
              goto    APOS54
APOS60:       rcr     7             ; M back to normal
              c=c-1   x             ; decrement remaining record length
              m=c
              c=b
              rcr     10            ; C[3:0]= start addr for this iteration
              a=c     wpt
              gosub   NXCHR         ; move one char to start next iteration
              c=n
              rcr     6             ; C.X= current char pointer
              c=c+1   x
              rcr     8
              n=c
              c=m
              rcr     8
              acex    wpt           ; save next char addr in M[11:8]
              rcr     6
              m=c
              a=c     x             ; A.X= # of remaining chars in record
              goto    APOS56
APOSFD:       c=n                   ; save the current pointer to file
              rcr     10
              dadd=c
              rcr     4
              data=c
              golBank1 RCLP30

              .public SEEKP2
SEEKP2:       ?a#c    s             ; is this a register file ?
              goc     SKPT50        ; no
              ?a<c    x             ; pointer < file size ?
              gonc    SKPT64
              data=c
              goto    SKPT80
SKPT50:       a=a+1   s             ; A.S=3
              ?a#c    s             ; is this a text file ?
              golc    FLTPER        ; no, say "FL TYPE ERR"
SKPT60:       s5=     1
              s6=     1
              gosub   `TOREC#`      ; point to given record
              c=b
              m=c                   ; M[9:7]= record length
              c=0
              dadd=c
              c=regn  3
              a=c
              ?s0=1                 ; reached end of file yes ?
              gonc    SKPT65        ; no
              ?c#0                  ; seek to pointer 0.0 ?
              gonc    SKPT70        ; yes, always allow seek to 0.0
SKPT64:       golong  EOFL     ; no, say "END OF FL"
SKPT65:       gosub   GTFRA
              a=c     x             ; A.X = given char pointer
              c=m
              rcr     7             ; C.X = record length
              ?a<c    x             ; char pointer past end of record ?
              goc     SKPT70        ; no, set it
              gosub   APERMG
              .messl  "END OF REC"
              golong  APEREX
SKPT70:       abex    x             ; B.X = given char pointer
              c=n
              rcr     3             ; C.X = given record pointer
              a=c     x
              gosub   STRCAB
SKPT80:       golong  NFRPU_B1

              .public EMROOM2
EMROOM2:      gosub   LB_33E9       ; set the stage
              a=c     x             ; current file#
              rcr     11            ; previous pointer in X field
              acex    x             ; put CUR in PRV
              rcr     8             ; rotate to defaults
              data=c                ; write to ex.mem cnt'l reg
              gosub   EFLSCH
              gosub   LB_33F5
              abex    x
              ldi     2
              a=a-c   x
              gonc    LB_5678
              a=0     x
LB_5678:      gosub   `BIN-D`
LB_567A:      golBank1H RCL

              .fillto 0x800
              .public EMDIRX2
EMDIRX2:      gosub   LB_3260
              ?c#0    x
              golong  ERRDE
              a=c     x
              gosub   CLA
              gosub   LB_33EE
              acex    x
              rcr     11
              acex    x
              rcr     8
              data=c
              s4=     1
              gosub   EFLS02
              ?s0=1
              gonc    LB_581E
              c=n
              rcr     10
              c=c+1   x
              dadd=c
              c=data
              pt=     1
              c#0?
              goc     LB_5829
              dadd=c
              goto    LB_5830
LB_581E:      gosub   LB_33F5
              setdec
              c=0
              dadd=c
LB_5823:      bcex
LB_5824:      golBank1H FILLXL
LB_5828:      rcr     2
LB_5829:      ?c#0    wpt
              gonc    LB_5828
              a=c
              c=0
              dadd=c
              acex
              regn=c  5
LB_5830:      c=n
              a=c     s
              c=0
              c=c+1   s
              pt=     3
              a=a-1   s
              a=a-1   s
              gonc    LB_583D
              lc      5
              lc      0
              lc      5
              lc      2
              goto    LB_5823
LB_583D:      lc      4
              a=a-1   s
              gonc    LB_5844
              lc      4
              lc      4
              lc      1
              goto    LB_5823
LB_5844:      a=a-1   s
              gonc    LB_584A
              lc      1
              lc      5
              lc      3
              goto    LB_5823
LB_584A:      c=n
              c=0     x
              rcr     13
              a=c     x
              gosub   `BIN-D`
              goto    LB_5824

              .public CLKEYS2
CLKEYS2:      c=regn  15            ; clear bit map first
              c=0     s
              c=0     m
              regn=c  15            ; leaves line number alone
              regn=c  10            ; doesn't leave scratch clear
              c=regn  13            ; get final end
              bcex    x             ; and save in B.X
              ldi     192
              a=c     x             ; A.X= bottom memory addr
CLK10:        ?a<b    x             ; reached final end yet ?
              gonc    CLK20         ; yes, done
              c=a     x
              dadd=c
              c=data
              c=c+1   s             ; is this a key reg ?
              gonc    CLK20         ; no, cleared them all
              c=0
              c=c-1   s             ; clear the assignment in reg
              data=c
              a=a+1   x
              legal
              goto    CLK10
CLK20:        gosub   GTFEND        ; now clear all the user prog assignments
              rcr     2
CLK30:        gosub   UPLINK
              c=c+1   s             ; alpha label ?
              gonc    CLK40         ;no, it is an END
              n=c
              c=a
              m=c                   ; save the addr in M
              gosub   INCAD2        ; get third byte of the chain
              gosub   INCADA
              c=0     x
              gosub   PTBYTA        ; zero the key code
              c=m
              a=c
              c=n
CLK40:        ?c#0    x             ; reached chain end ?
              goc     CLK30         ; not yet
              dadd=c                ; enable chip 00
              golBank1 PKIOAS

              .public ANUM2
ANUM2:        b=a     wpt           ; save next char addr in B
ANUM10:       c=0
              c=c-1
              c=0     xs
              pt=     13
              lc      10
              regn=c  9
              gosub   STBT10
              rcr     11            ; set mantissa non-zero bit
              s3=     1
              c=st
              rcr     3
              regn=c  8
ANUM20:       s9=     0
              pt=     3
              a=b     wpt           ; get next char addr back from B
              gosub   GTBYTA        ; get next char
              c=0     xs
              a=c     x             ; A.X = char
              ldi     58            ; ASCII 0-9 = 48-57
              ?a<c    x
              gonc    ANUM60        ; might be "E"
              ldi     48
              ?a<c    x
              goc     ANUM40        ; not a digit, might be one of "+,-."
              ldi     32
              c=a-c   x             ; convert ASCII digit to fcn code
ANUM25:       pt=     0
              g=c                   ; put the function code to G
              gosub   DIGENT        ; call digit entry routine
ANUM30:       pt=     3
              abex    wpt           ; get the char addr back from B
              c=0
              ldi     5
              ?a#c    wpt           ; is this last char in alpha reg ?
              gonc    ANUM75        ; yes
              gosub   INCADA        ; point to next char
              abex    wpt
              ?s9=1                 ; last char recognized ?
              goc     ANUM10        ; no, re-initialize digit entry ?
              goto    ANUM20        ; continue on next char
ANUM70:       s9=     1             ; this char, not recognized
              c=regn  9             ; see if any entry detected at all
              c=c+1   m
              goc     ANUM30        ; no, look for next char
ANUM75:       c=regn  9             ; check again if anything was detected
              c=c+1   m             ;  for when the alpha reg is emptied
              golc    TOBNK1        ; no, don't change X or flag 22
              c=regn  14            ; set numeric input flag (F22)
              rcr     8
              cstex
              s1=     1
              cstex
              rcr     6
              regn=c  14
              ?s11=1                ; push flag set ?
              gsubc   R_SUB         ; push stack if set
              golBank1 NOREGCX
ANUM60:       ldi     69            ; ASCII "E"
              ?a#c    x
              goc     ANUM70        ; unrecognized entry
              c=regn  9             ; check if any digits yet
              c=c+1   m
              goc     ANUM70        ; no, don't recognize "E"
              ldi     27            ; function code for EEX
              goto    ANUM25
ANUM40:       ldi     43            ; ASCII "+"
              ?a#c    x
ANUM41:       gonc    ANUM30        ; always ignore "+"
              c=c+1   x             ; C.X = ASCII ","
              ?a#c    x
              goc     ANUM45
              ?s5=1                 ; decimal point flag set ?
              goc     ANUM48        ; yes, check digit grouping flag
ANUM42:       ldi     26            ; function code for decimal point
ANUM44:       goto    ANUM25
ANUM45:       c=c+1   x             ; C.X = ASCII "-"
              ?a#c    x
              goc     ANUM47
              ldi     28            ; function code for minus sign
              goto    ANUM44
ANUM47:       c=c+1   x             ; C.X = ASCII "."
              ?a#c    x
              goc     ANUM70        ; not ".", unrecognized entry
              ?s5=1                 ; decimal point flag set ?
              goc     ANUM42        ; load fcn code of D.P.
ANUM48:       ?s4=1                 ; digit grouping flag set ?
              gonc    ANUM70        ; no, don't recognize separator
              goto    ANUM41        ; otherwise, ignore separator

              .public CLRGX2
CLRGX2:       c=regn  3
              bcex
              c=b
              gosub   LB_325C
              n=c
              s2=     0
              gosub   GTFRAB
              a=c     x
              c=n
              rcr     11
              acex    x
              n=c
              s2=     1
              gosub   GTFRAB
              ?c#0    x
              goc     LB_5904
              c=c+1   x
LB_5904:      a=c     x
              c=n
              rcr     11
              acex    x
              n=c
              c=regn  13
              rcr     3
              a=c     x
              c=n
              rcr     3
              c=a+c   x
              rcr     3
              c=a+c   x
              gosub   CHKADR
              rcr     11
              gosub   CHKADR
              c=c+1   x
              n=c
              rcr     3
              a=c     x
              rcr     8
              bcex    x
LB_591C:      c=0
              acex    x
              dadd=c
              acex    x
              data=c
              c=n
              a=a+b   x
              ?a<c    x
              goc     LB_591C
              golong  TOBNK1

              .public PASN10
PASN10:       a=c
              c=c-1   x             ; X < 10 ?
              goc     PASNER2       ; yes, key code err
              c=c-1   x             ; X > 99 ?
PASNER2:      golnc   PASNER        ; yes, key code err
              rcr     11            ; C[1]= row #, C[0] = column #
              a=c     x
              pt=     0
              ?c#0    pt            ; column # = 0 ?
              gonc    PASNER2
              ldi     0x90
              pt=     1
              ?a<c    pt            ; row # <= 8 ?
              gonc    PASNER2       ; no, say "KEYCODE ERR"
              ldi     0x31          ; don't allow shift key
              ?a#c    wpt
              gonc    PASNER2       ; say "KEYCODE ERR"
              ldi     0x46
              ?a<c    pt            ; row 1-3 ?
              goc     PASN15        ; yes, max. column # is 5
              c=c-1   x
PASN15:       pt=     0
              ?a<c    pt            ; col # too big ?
              gonc    PASNER2       ; yes, say "KEYCODE ERR"
              lc      1
              pt=     1
              ?a#c    pt            ; row 4 ?
              goc     PASN20
              ?a#c    wpt           ; enter key ?
              gonc    PASN20        ; yes, the rest of the row 4 keys
              a=a+1   wpt           ;  is off by one
PASN20:       a=a-1   x
              c=a     x             ; put A[1]=column #, A[0] = ROW #
              csr     x
              asl     x
              acex    pt
              a=c     x
              ?a#0    s             ; X negative ?
              gonc    PASN30        ; no, shifted key
              ldi     8
              a=a+c   x
              legal
PASN30:       golBank1 XASN

              .public AROT2
AROT2:        gosub   ALEN          ; compute alpha length
              ?s2=1                 ; alpha empty ?
              goc     AROT05        ; yes, no need to rotate
              n=c                   ; save alpha length in N
              gosub   `X<256`
              ?c#0    x             ; X = 0 ?
AROT05:       golong  TOBNK1        ; yes, no need to rotate
              a=c     x             ; save rotation count in A.X
              c=regn  3
              bcex    s             ; save sign of X in B.S
              c=n                   ; get alpha length back from N
AROT10:       a=a-c   x             ; do X mod ALEN
              gonc    AROT10
              a=a+c   x             ; A.X = actual rotation count
              ?b#0    s             ; is it negative ?
              gonc    AROT20        ; no, X is positive
              acex    x             ; A.X=ALEN;  C.X=rotation count
              a=a-c   x             ; convert rotate right to left
AROT20:       acex    x             ; save rotation count in N.X
              n=c
              gosub   FAHED         ; get address of alpha head
              acex    wpt
              m=c                   ; save alpha head addr in M
AROT30:       c=n
              c=c-1   x             ; decrement rotation count
              goc     AROT05
              n=c                   ; put rotation back in N.X
              pt=     3
              c=m                   ; get alpha head addr back
              a=c     wpt
              gosub   GTBYTA        ; get leftmost char
              pt=     0
              g=c
              c=0     x
              pt=     3
              gosub   PTBYTA        ; kick out leftmost char
              gosub   APNDNW        ; shift the leftmost char in
              goto    AROT30

              .public GETKEY2
GETKEY2:      c=0
              pt=     3             ; set counter for 10 sec. time out
              lc      4
              .newt_timing_start
GTKE10:       chk     kb
              goc     GTKE20
              c=c-1
              gonc    GTKE10        ; not time out yet
              .newt_timing_end
              c=0                   ; time out, return zero to X
              goto    GTKE80
GTKE20:       c=keys                ; read the physical key code
              rcr     3
              c=0     xs
              a=c     x             ; A.X= physical key code
              pt=     0
              c=c+c   pt            ; check for "OFF" key
              gonc    GTKE30        ; not "OFF" key
              c=0                   ; "OFF" key code = 01
              goto    GTKE40
GTKE30:       ldi     0xc4          ; convert "USER", "PRGM", "ALPHA" to
                                    ;  01, 02, 03
              ?a<c    x             ; is it a top key ?
              goc     GTKE50        ; no
              a=a-c   x             ; now top row keys = 00, 02, 01, 00
              c=0
              lc      3
              acex    x
              c=a-c   x             ; now top row keys = 00, 01, 02, 03
GTKE40:       c=c+1   x             ; now top row keys = 01, 02, 03, 04
              legal
              rcr     2             ; C=0X000000000000
              goto    GTKE80
GTKE50:       asl     x             ; set up A and C for subtracting
              a=a+1   xs            ;  3's from the actual column
              pt=     2             ;  number to determine the
              c=0                   ;  logical column number
              lc      2
              c=c-1   wpt           ; put '2FF' in C ('300'-1)
GTKE60:       a=a-c   x             ; loop to subtract 3 from old col
              gonc    GTKE60        ; no. and inc. new col. no.
              ldi     0x31
              ?a#c    pt            ; row 3 ?
              goc     GTKE70        ; no, skip col. no. adjustment
              ?a#c    wpt           ; 'ENTER' key ?
              gonc    GTKE70        ; yes, skip adjustment
              a=a-1   x             ; correct row 3 col. numbers
GTKE70:       a=a+1   pt            ; row 0 - 7 => row 1 - 8
              acex    wpt           ; move keycode to C
              rcr     3             ;  in normailzed form
              c=c+1   x
GTKE80:       bcex
              gosub   RSTKB         ; reset key board
              golBank1 RCL

              .public STOFLAG2
STOFLAG2:     ldi     511
              a=c     x
              c=regn  3             ; get X
              rcr     11
              ?a#c    x             ; does X have the binary bits ?
              goc     STOF20        ; no, let's check Y
              a=c                   ; restore all flags 0-43
              c=regn  14            ; get status reg
              acex    x
              acex
              regn=c  14
STOF19:       golong  TOBNK1
STOF20:       c=regn  2             ; get Y register
              rcr     11
              ?a#c    x             ; does Y have the binary bits ?
              golc    ERRDE         ; no, say DATA ERROR
              s5=     0
              s2=     1             ; decode X as BB.EE
              gosub   GTIND2
              ldi     43
              a=c     x
              c=n                   ; C.X= ending flag number
              ?a<c    x             ; flag # <= 43 ?
              goc     STOF25        ; no, say "NONEXISTENT"
              rcr     3             ; C.X= starting flag number
              ?a<c    x             ; flag # <= 43 ?
              gonc    STOF30        ; yes, index O.K.
STOF25:       golong  ERRNE
STOF30:       a=c     x             ; A.X= starting flag number
              c=regn  2
              rcr     11            ; C[13:3] = flag 0-43
              goto    STOF40
STOF35:       c=c+c
STOF40:       a=a-1   x
              gonc    STOF35
STOF45:       a=c                   ; save binary bits in A
              c=n
              rcr     3             ; C.X= starting flag number
              bcex    x             ; save flag # in B.X
              ldi     168           ; function code of  "SFnn"
              acex
              c=c+c                 ; test the flag
              goc     STOF50        ; this flag set
              a=a+1   x; A.X= function code of "CFnn"
STOF50:       regn=c  9             ; save the rest of the bits in reg.9
              acex    x             ; C.X function code
              pt=     0
              g=c                   ; put the function code in G
              gosub   ALLOK         ; set or reset flag
              c=n
              a=c     x             ; A.X= ending flag number
              rcr     3             ; C.X= last flag number
              c=c+1   x             ; C.X= next flag number
              ?a<c    x             ; passed ending flag # ?
              goc     STOF19
              rcr     11
              n=c                   ; put flag numbers back in N
              c=regn  9             ; get remaining binary bits
              goto    STOF45

              .public POSA2, XPOANF2, XPOAFN2
POSA2:        c=regn  3
              c=c-1   s
              ?c#0    s             ; X has a string ?
              goc     XPOA20        ; no, X has a number
              pt=     12
              lc      0
              ?c#0                  ; a null string ?
              gonc    XPOANF2       ; yes, return -1
              pt=     1
XPOA10:       rcr     12            ; left justify the string
              ?c#0    wpt           ; still a null ?
              gonc    XPOA10        ; yes; skip it
              rcr     2             ; get first char back to left end
              goto    XPOA30
XPOA20:       gosub   `X<256`       ; get int(X)
              rcr     2             ; C[13:12] = single char substring
              pt=     11
              c=0     wpt           ; C = XX00000000000000
XPOA30:       n=c                   ; save the substring in N
              gosub   FAHED
              ?s2=1                 ; alpha empty ?
              goc     XPOANF2       ; yes, return -1
XPOA40:       b=a     wpt           ; save the starting addr of an
              c=n                   ;  iteration in B[3:0] and copy the
              m=c                   ;  unrotated substring from N to M
XPOA50:       gosub   GTBYTA        ; get next char from alpha reg
              acex                  ; A=char  C=addr
              cmex                  ; C=rotated substr  M=addr  A=char
              rcr     12
              pt=     1
              s0=     0
              ?a#c    wpt           ; match ?
              goc     XPOA55        ; no
              s0=     1             ; remember current char match
XPOA55:       cmex                  ; M=rotated substr  C=current addr
              acex                  ; A=current addr
              c=m
              rcr     12            ; C[1:0]= next char in substr
              ?c#0    wpt           ; next char is null ?
              goc     XPOA60        ; no
              ?s0=1                 ; current char match ?
              goc     XPOA80        ; yes, we found it
XPOA60:       c=0
              ldi     5
              pt=     3
              ?a#c    wpt           ; reached end of alpha ?
              gonc    XPOANF2       ; yes, substr not found
              ?s0=1                 ; current char match ?
              goc     XPOA65        ; yes
              abex    wpt           ; A[3:0]=start addr of this iteration
              gosub   INCADA        ; point to next char in alpha reg
              goto    XPOA40        ; start another iteration
XPOA65:       gosub   INCADA        ; ; continue on next char
              goto    XPOA50
XPOANF2:      c=0
              dadd=c                ; enable chip 0
              ldi     0x91          ; substring not found
              rcr     2             ; C= 9100000000000000
              bcex
              goto    XPOA90
XPOA80:       gosub   FAHED         ; get alpha head addr
              gosub   CNTBY7        ; count # of bytes from head
XPOAFN2:      gosub   `BIN-D`       ; convert to decimal
XPOA90:       golBank1H FILLXL       ; save X to L, result to X

              .public LB_5A4F
LB_5A4F:      gosub   LB_386F
              pt=     13
              lc      4
              c=a+c   s
              c=0     x
              rcr     13
              a=a-1   s
              goc     LB_5A65
              bcex    x
LB_5A59:      acex    x
              dadd=c
              a=c     x
              a=a+1   x
              c=data
              bcex
              dadd=c
              c=c-1   x
              bcex
              data=c
              a=a-1   s
              gonc    LB_5A59
LB_5A65:      golBank1 NFRPR

LB_5A69:      ldi     122
              .newt_timing_start
LB_5A6B:      c=c-1   x
              gonc    LB_5A6B
              .newt_timing_end
              golong  RSTKB

              .public PSIZ10_2
PSIZ10_2:     c=regn  9             ; update and restore return stack
              regn=c  11
              c=regn  12
              a=c
              c=regn  8
              cgex                  ; restore part of the addr from G
              pt=     3
              acex    wpt           ; PC already updated by "SIZSUB"
              regn=c  12
              sel q
              pt=     7
              sel p
PSIZ20:       pt=     3
              c=regn  12
              a=c                   ; rotate the return stack and
              c=regn  11            ;  update one at a time
              acex    wpt
              rcr     4
              regn=c  11
              acex
              rcr     4
              regn=c  12
              a=c
              sel q
              dec pt
              ?pt=    0             ; all done ?
              golc    TOBNK1        ; yes
              sel p
              ?c#0    wpt           ; return address zero ?
              gonc    PSIZ20        ; yes, continue with the next one
              ?c#0    pt            ; a ROM address ?
              goc     PSIZ20        ; yes, don't touch it
              c=m                   ; get the displacement
              a=a+c   x             ; add it
              acex
              regn=c  12            ; done with one return addr
              goto    PSIZ20

              .public ASROOM2
ASROOM2:      s6=     1
              s8=     1
              c=0
              gosub   LB_3837
              c=0
              ldi     11
              acex    wpt
LB_5A9E:      setdec
              c=c+c   m
              sethex
              c=c+c   x
              gonc    LB_5AA4
              c=c+1   m
LB_5AA4:      a=a-1   x
              gonc    LB_5A9E
              rcr     8
              ldi     3
              a=c
              gosub   LB_3194
              golBank1 RCL


LB_5AB0:      c=regn  14
              rcr     6
              cstex
              rcr     2
              ldi     48
              ?a<c    x
              gonc    LB_5AC9
              ldi     46
              ?a#c    x
              goc     LB_5AC1
              ?s3=1
              rtn c
              a=a-1   x
              a=a-1   x
              rtn

LB_5AC1:      ldi     13
              ?a#c    x
              goc     LB_5ACD
              ldi     45
              a=c     x
              rtn

LB_5AC9:      ldi     58
              ?a<c    x
              rtn c
LB_5ACD:      golong  LB_3698

              .public SAVEP2
SAVEP2:       gosub   GTPRAD        ; get program address
;;; Now A[3:0] = prog head addr
;;;     A[7:4] = prog end addr
              c=a
              rcr     8
              b=c                   ; save prog end & head addr in B[13:6]
              rcr     10
              bcex    wpt           ; B[3:0]= prog end addr
              gosub   CNTBY7        ; compute program length in bytes
              a=a+1   x
              a=a+1   x             ; A.X= program length
              b=a     x             ; save the program length in B.X
              a=a+1   x             ; one byte for checksum
              c=0
              ldi     7
              a=a-1   x             ; compute # of regs required
SVPR10:       c=c+1   m
              a=a-c   x
              gonc    SVPR10
              c=0     x
              dadd=c
              rcr     3             ; C.X= program size in regs
              bcex                  ; save prog size in B.X
              rcr     11            ; C[5:3]= prog length in bytes
              c=b     x
              regn=c  9

;;; Reg.9 [12:9] = prog head addr
;;; Reg.9 [5:3]  = prog length in bytes
;;; Reg.9 [2:0]  = prog size in registers

              s1=     0
              s3=     0
              ?s6=1                 ; is there a comma in alpha reg ?
              gsubnc  ADR608
              gosub   ALNAM2
              s3=     1
              gosub   EFLSCH        ; search for the file
              ?s0=1                 ; file found ?
              gonc    SVPR40        ; no
              c=n
              c=c-1   s
              ?c#0    s             ; is this file a prog file ?
              golc    DUPFER        ; no, say "DUP FL"
              gosub   PUFLSB        ; purge the file or say "NO ROOM"
              goto    SAVEP2

;;; Now B.X = # of registers still available
;;;     Reg.9[2:0] = required file size in registers
SVPR40:       c=0
              dadd=c
              c=regn  9
              a=c     x
              a=a+1   x             ; A.X = file size + 1
              ?a<b    x             ; enough room for a new file ?
              golnc   NO_ROOM       ; no, say "NO ROOM"
              bcex
              c=0
              pt=     5
              c=b     wpt
              pt=     3
              c=c+1   s
              n=c                   ; N= new file header
              acex                  ; C[10:8]= first available reg addr
              rcr     8
              a=c     x
              a=0     pt
              dadd=c                ; enable file name reg
              c=m
              data=c
              gosub   NXREG         ; point to next reg
              c=a     x
              dadd=c                ; enable file header register
              c=n                   ; C[5:3] = prog length in bytes
              data=c
              c=c-1   m             ; C[5:3] = # of bytes -1
              c=0     x             ; init checksum
              n=c                   ; N.M= byte count; N.X= running checksum
              c=b                   ; C[12:9]= prog head addr
              acex    wpt           ;C[3:0]= last store addr

;;; Now N.M     = byte count
;;;     N.X     = running checksum
;;;     C[12:9] = last source addr
;;;     C[3:0]  = last dest addr

SVPR45:       rcr     9
              a=c
              gosub   NXBYTA        ; get next byte from program
              bcex    x             ; save it in B.X
              acex
              rcr     5
              a=c                   ; A[3:0]= last store addr
              gosub   NXCHR         ; point to next char in ex.mem
              c=b     x
              gosub   PTBYTA        ; leaves C[1:0] in B[1:0]
              c=n
              acex    x             ; update checksum
              a=a+b   x
              acex    x
              c=c-1   m             ; all done ?
              goc     SVPR60        ; yes, go to write EOF mark
              n=c
              acex
              goto    SVPR45
SVPR60:       n=c
              gosub   NXCHR         ; write the checksum to file
              c=n
              gosub   PTBYTA
              gosub   NXREG         ; point to en of file mark
              acex    x
              dadd=c
              c=0
              c=c-1
              data=c
              golBank1 NFRPU

LB_5B49:      gosub   ENCP00
              c=regn  8
              rcr     10
              dadd=c
              a=c     x
              c=data
              rcr     10
              acex    x
              rcr     4
              n=c
              rtn

LB_5B55:      c=0     x
              dadd=c
              c=regn  8
              rcr     6
              acex    wpt
              a=c     wpt
              rcr     8
              regn=c  8
              rtn

LB_5B5E:      s2=     0
              s3=     0
              s5=     0
              gosub   `CUREC#`
              c=m
              rcr     8
              pt=     3
              a=c     wpt
              s2=     0
              gosub   BYTLFT
              c=0     wpt
              c=c+1   wpt
              c=c+1   wpt
              rtn

LB_5B6E:      ldi     96
              a=c     x
              c=m
LB_5B72:      c=0     x
              dadd=c
              s3=     0
              c=c+1   x
              pt=     3
              rcr     4
              c=0     wpt
              ldi     10
              rcr     10
              m=c
              c=regn  10
              acex    x
              regn=c  10
              rtn

LB_5B81:      gosub   ENLCD
              c=regn  5
              cstex
              rtn

LB_5B86:      gosub   GTBYTA
              a=c     x
              a=0     xs
              gosub   ENLCD
              ldi     58
              ?a#c    x
              gonc    LB_5B97
              ldi     44
              ?a#c    x
              gonc    LB_5B97
              ldi     46
              ?a#c    x
LB_5B97:      golnc   LB_3698
              rtn

              .public PCLPS2
PCLPS2:       gosub   GTPRAD        ; get the program addr
              b=a                   ; A[3:0]= pr.hd adr,  A[7:4]= pr.end adr
              s8=     0             ; clear checksum flag
              gosub   GETPC         ; get current prog counter addr
              s9=     0             ; assume current prog will stay
              c=b
              ?a<c    x             ; PC below prg head ?
              goc     LOSTPC        ; yes
              ?a#c    x             ; are they at same reg ?
              goc     KEEPPC        ; no, PC above prog head
              acex    pt
              ?a<c    pt
              goc     KEEPPC
LOSTPC:       s9=     1
KEEPPC:       c=0
              c=b     wpt           ; get prog head addr
              regn=c  9             ; save prog head addr in reg.9
              abex    wpt           ; put an "END" to the beginning of the ..
              golong  RP330         ; jump into "GETP" routine

              .fillto 0xc00
              .public ED2
ED2:          s0=     1
              pt=     13
              lc      3
              bcex    s
              gosub   FLSHAB
              c=0
              dadd=c
              pt=     9
              c=regn  8
              a=c     wpt
              c=n
              acex    wpt
              regn=c  8
              gosub   RUNST2
              goto    LB_5C12
              s7=     1
LB_5C12:      gosub   ENLCD
              readen
              c=0     x
              ?s7=1
              gonc    LB_5C19
              c=c+1   x
LB_5C19:      wrten
LB_5C1A:      gosub   LB_5B49
LB_5C1C:      s5=     1
              s8=     1
              s3=     0
              s2=     0
              gosub   `CUREC#`
              ?s1=1
              gonc    LB_5C4E
              s6=     0
              gosub   TXTEND
              c=b
              rcr     4
              a=c     x
              ?a#0    x
              gonc    LB_5C32
              a=a-1   x
              b=0     x
              gosub   STRCAB
              n=c
              goto    LB_5C1C
LB_5C32:      rcr     6
              a=c     wpt
              gosub   LB_5B55
              c=n
              rcr     3
              c=0     x
              rcr     11
              n=c
              golong  LB_5F31
LB_5C3D:      gosub   LB_5B49
              s2=     0
              c=0     x
              dadd=c
              c=regn  8
              rcr     6
              pt=     3
              a=c     wpt
              gosub   GTBYTA
              c=0     xs
              rcr     3
              acex    wpt
              rcr     4
              bcex
              goto    LB_5C54
LB_5C4E:      c=b
              rcr     10
              pt=     3
              a=c     wpt
              gosub   LB_5B55
LB_5C54:      c=b     m
              rcr     7
              a=c     x
              c=n
              rcr     6
              ?a<c    x
              gonc    LB_5C61
              b=a     x
              rcr     11
              a=c     x
              gosub   STRCAB
              n=c
LB_5C61:      c=b     m
              rcr     6
              ?c#0    x
              golong  LB_5E24
              bsr
              c=0     x
              dadd=c
              c=b
              regn=c  9
              gosub   CLLCDE
              disoff
              c=n
              rcr     6
              a=c     x
              ldi     11
              ?a<c    x
              goc     LB_5C86
              ldi     13
              a=a+c   x
              c=b     m
              rcr     6
              ?a<c    x
              gonc    LB_5C81
LB_5C7C:      ldi     23
              a=a-c   x
              b=0     s
              goto    LB_5C92
LB_5C81:      a=c     x
              ldi     24
              ?a<c    x
              gonc    LB_5C7C
LB_5C86:      c=n
              rcr     3
              a=c     x
              a=0     s
              gosub   GENNUM
              c=regn  15
              abex    s
              a=a+1   s
              b=a     s
              a=0     x
              a=a+1   x
LB_5C92:      c=0     x
              pfad=c
              c=m
              acex    x
              m=c
              pt=     3
              c=n
              rcr     6
              c=c+1   x
              bcex    x
              c=b
              rcr     9
              a=c     wpt
              s2=     0
              gosub   ADVREB
              c=m
              bcex    x
              rcr     4
              acex    wpt
              rcr     10
              m=c
              c=b
              rcr     9
              a=c     wpt
              gosub   ADVREB
              c=m
              acex    wpt
              m=c
              c=b
              rcr     9
              a=c     wpt
              gosub   ADVREC
              pt=     13
              lc      12
              a=c     s
              a=a-b   s
              b=a     s
              pt=     3
              c=m
              acex    wpt
              m=c
              s3=     0
              s1=     1
              goto    LB_5CD2
LB_5CC1:      gosub   GTBYTA
              b=a     wpt
              a=c     x
              gosub   ENLCD
              gosub   ASCLCA
              pt=     3
              chk kb
              goc     LB_5D07
              c=0     x
              pfad=c
              abex    wpt
              gosub   NXCHR
              c=m
LB_5CD2:      rcr     4
              ?a#c    wpt
              goc     LB_5CC1
              c=m
              c=b     s
              m=c
              ?a#c    wpt
              goc     LB_5CE9
              s9=     0
              gosub   ENLCD
              c=m
              c=c-1   s
              goc     LB_5CE4
              m=c
              a=c     s
              golong  LB_5D2A
LB_5CE4:      ldi     32
              regn=c  15
              golong  LB_5D41
LB_5CE9:      b=a     wpt
              s9=     1
              gosub   LB_5B86
              s9=     0
              gosub   ASCLCA
              c=m
              c=b     s
              a=c     s
              rcr     13
              pt=     13
              lc      6
              ?a<c    s
              goc     LB_5CFA
              c=0     s
              goto    LB_5CFC
LB_5CFA:      acex    s
              c=a-c   s
LB_5CFC:      rcr     1
              m=c
              goto    LB_5D0E
LB_5CFF:      gosub   GTBYTA
              b=a     wpt
              a=c     x
              gosub   ENLCD
              chk kb
              gonc    LB_5D0C
LB_5D07:      gosub   CLRLCD
              s8=     1
              golong  LB_5D4D
LB_5D0C:      gosub   ASCLCA
LB_5D0E:      pt=     3
              abex    wpt
              c=0     x
              pfad=c
              gosub   NXCHR
              c=m
              ?a#c    wpt
              gonc    LB_5D22
              ?b#0    s
              goc     LB_5CFF
              rcr     13
              ?c#0    s
              gonc    LB_5D2E
              ?s1=1
              gonc    LB_5D2E
              bcex    s
              c=b     s
              s1=     0
              goto    LB_5CFF
LB_5D22:      gosub   ENLCD
              ?s1=1
              gonc    LB_5D41
              abex    s
              b=a     s
              a=a-1   s
              goc     LB_5D41
LB_5D2A:      flsabc
              a=a-1   s
              gonc    LB_5D2A
              goto    LB_5D41
LB_5D2E:      gosub   ENLCD
              c=regn  14
              c=regn  15
              c=0     xs
              b=a     wpt
              a=c     x
              ldi     64
              a=a-c   x
              gonc    LB_5D41
              c=0     x
              pfad=c
              abex    wpt
              gosub   LB_5B86
              goto    LB_5D41
              gosub   ASCLCA
LB_5D41:      c=m
              ?s1=1
              goc     LB_5D49
              rcr     13
              a=c     s
              a=a-b   s
              rcr     1
              c=a+c   s
LB_5D49:      rcr     8
              pt=     5
              bcex    pt
              s8=     0
LB_5D4D:      distog
              ldi     240
              bcex    x
              sel q
              pt=     7
              sel p
LB_5D54:      s4=     0
LB_5D55:      ldi     800
              .newt_timing_start
LB_5D57:      chk kb
              golc    LB_5D9A
              c=c-1   x
              gonc    LB_5D57
              .newt_timing_end
              c=b     x
              c=c-1   x
              golc    LB_5D9E
              bcex    x
              gosub   CHKLB2
              gosub   ENLCD
              pt=     5
              abex    pt
              b=a     pt
LB_5D68:      frsabc
              a=a-1   pt
              gonc    LB_5D68
              ?s4=1
              gonc    LB_5D6F
              c=m
              goto    LB_5D8C
LB_5D6F:      a=c     x
              sel q
              ?pt=    7
              gonc    LB_5D78
              pt=     0
              c=m
              acex    x
              a=c     x
              m=c
LB_5D78:      sel p
              cstex
              s7=     0
              s6=     0
              cstex
              ?s9=1
              goc     LB_5D8C
              a=a-c   x
              acex    x
              pt=     0
              g=c
              ldi     31
              ?a#c    x
              goc     LB_5D88
              c=c+1   x
LB_5D88:      a=c     x
              c=g
              c=a+c   x
              pt=     5
LB_5D8C:      regn=c  15
              lc      11
              pt=     5
              a=c     pt
              a=a-b   pt
LB_5D91:      c=regn  14
              a=a-1   pt
              gonc    LB_5D91
              ?s4=1
              golc    LB_5D54
              s4=     1
              golong  LB_5D55
LB_5D9A:      c=keys
              rcr     1
              c=c+c   xs
              gonc    LB_5DA6
LB_5D9E:      gosub   LB_5A69
              gosub   ANNOUT
              golBank1 CLDSP
LB_5DA6:      c=regn  5
              st=c
              a=0     m
              a=a+1   m
              a=a+1   m
              c=0
              c=keys
              rcr     1
              a=a+c   m
              pt=     3
              gosub   PCTOC
              c=a+c   m
              gotoc

;;; ???
              nop
              lc      0
              goto    LB_5DC1
              lc      1
              goto    LB_5DC1
LB_5DB9:      lc      2
              goto    LB_5DC1
              goto    LB_5DB9
              lc      3
              goto    LB_5DC1
              nop
              nop
              lc      4
LB_5DC1:      rcr     2
              c=0     xs
              a=c     x
              ldi     68
              ?a#c    x
              goc     LB_5DD8
              c=regn  5
              ?s0=1
              gonc    LB_5DCD
              s0=     0
              goto    LB_5DCE
LB_5DCD:      s0=     1
LB_5DCE:      s7=     0
LB_5DCF:      cstex
              data=c
              gosub   LB_5A69
              ?s8=1
              golc    LB_5C1A
              golong  LB_5D54
LB_5DD8:      c=c+1   x
              ?a#c    x
              goc     LB_5DED
              c=n
              rcr     6
              a=c     x
              a=a+1   x
              ?s7=1
              gonc    LB_5DE4
              ldi     11
              a=a+c   x
LB_5DE4:      b=a     x
              rcr     11
              a=c     x
              c=0     x
              pfad=c
              gosub   STRCAB
              golong  LB_5EF2
LB_5DED:      c=c+1   x
              ?a#c    x
              goc     LB_5DFD
              c=n
              rcr     6
              a=c     x
              c=0     x
              c=c+1   x
              ?s7=1
              gonc    LB_5DF9
              ldi     12
LB_5DF9:      a=a-c   x
              gonc    LB_5DE4
              a=0     x
              goto    LB_5DE4
LB_5DFD:      gosub   ENCP00
              c=regn  9
              rcr     13
              pt=     6
              bcex    wpt
              bcex
              pt=     0
              ldi     8
              a=a+c   pt
              gosub   LB_5FE8
              ?c#0    xs
              golc    LB_5E77
              ldi     8
              ?s0=1
              goc     LB_5E13
              a=a+c   pt
              nop
LB_5E13:      gosub   LB_5FE5
LB_5E15:      a=c     x
              ?s0=1
              goc     LB_5E1F
              gosub   LB_5AB0
              goto    LB_5E1D
              golong  LB_5EF0
LB_5E1D:      rcr     12
              st=c
LB_5E1F:      c=m
              acex    x
              m=c
              ?s5=1
              gonc    LB_5E5A
LB_5E24:      gosub   LB_5B5E
              ?a#0    wpt
              goc     LB_5E51
LB_5E28:      gosub   CLLCDE
              gosub   MESSL
              .messl  "NO ROOM"
              gosub   LEFTJ
              readen
              cstex
              s7=     0
              cstex
              data=c
              gosub   ENCP00
              gosub   TONE7X
              gosub   RSTKB
              ldi     1023
              .newt_timing_start
LB_5E42:      c=c-1   x
              goc     LB_5E4F
              c=0     m
              chk kb
              gonc    LB_5E42
              .newt_timing_end
              c=keys
              rcr     3
              a=c     x
              ldi     195
              ?a#c    x
              golong  LB_5EF7
LB_5E4F:      golong  LB_5C1A
LB_5E51:      s7=     1
              s6=     1
              c=m
              a=c     x
              gosub   LB_5B72
              gosub   APCH10
              goto    LB_5E75
LB_5E5A:      c=b
              rcr     7
              a=c     x
              c=n
              rcr     6
              ?a#c    x
              gonc    LB_5E24
              c=c+1   x
              bcex    x
              c=b
              rcr     10
              pt=     3
              a=c     wpt
              s2=     0
              gosub   ADVREB
              c=m
              gosub   PTBYTA
              a=0     x
              a=a+1   x
              b=a     x
              c=n
              rcr     3
              a=c     x
              gosub   UPRCAB
LB_5E75:      golong  LB_5EF2
LB_5E77:      ldi     8
              gosub   LB_5FE5
              ?c#0    x
              goc     LB_5EB9
              c=b     m
              rcr     7
              a=c     x
              pt=     3
              ldi     1
              ?a#c    x
              goc     LB_5E93
              bcex    x
              c=b
              rcr     10
              a=c     wpt
              gosub   ADVREB
              ldi     96
              gosub   PTBYTA
              c=n
              rcr     3
              golong  LB_5F67
LB_5E93:      c=n
              rcr     6
              ?a#c    x
              goc     LB_5EA4
              c=c-1   x
              a=a-c   x
              bcex    x
              acex    x
              m=c
              rcr     11
              a=c     x
              gosub   STRCAB
              rcr     6
              c=c+1   x
              bcex    x
              goto    LB_5EA9
LB_5EA4:      a=a-c   x
              c=c+1   x
              bcex    x
              acex    x
              m=c
LB_5EA9:      c=b
              rcr     10
              a=c     wpt
              s2=     0
              gosub   ADVREB
              c=m
              rcr     8
              acex    wpt
              rcr     6
              m=c
              a=0     x
              a=a+1   x
              gosub   DLRC30
LB_5EB8:      goto    LB_5EF2
LB_5EB9:      ?c#0    xs
              goc     LB_5EBE
              ?s0=1
              golc    LB_5E15
LB_5EBE:      pt=     3
              a=c     x
              ldi     8
              gosub   KEYCDE
              .con    0x10e         ; "SHIFT"
              .con    0x17e         ; "VIEW"
              .con    0x19b         ; "GTO"
              .con    0x19A         ; "LBL"
              .con    0x105         ; "R/S"
              .con    0x207         ; "BST"
              .con    0x108         ; "SST"
              .con    0x187         ; "CLX"
              nop
              goto    LB_5EE7
              goto    LB_5EFB
              goto    LB_5ED6
              goto    LB_5F0C
              goto    LB_5F10
              goto    LB_5F0F
              goto    LB_5F0D
              goto    LB_5ED8
              goto    LB_5EF0
LB_5ED6:      golong  LB_5F6C
LB_5ED8:      gosub   DLRC50
              c=0     x
              dadd=c
              c=regn  8
              rcr     6
              a=c     wpt
              gosub   GTBYTA
              c=0     xs
              c=c-1   xs
              c=c+1   x
              gonc    LB_5EB8
              golong  LB_5F58
LB_5EE7:      gosub   LB_5B81
              ?s7=1
              gonc    LB_5EED
              s7=     0
              goto    LB_5EEE
LB_5EED:      s7=     1
LB_5EEE:      golong  LB_5DCF
LB_5EF0:      gosub   BLINK1
LB_5EF2:      gosub   LB_5B81
              s7=     0
              c=st
              data=c
LB_5EF7:      gosub   LB_5A69
              golong  LB_5C3D
LB_5EFB:      gosub   LB_5B5E
LB_5EFD:      ?a<c    wpt
              golc    LB_5E28
LB_5F00:      gosub   LB_5B6E
              c=n
              regn=c  9
              s6=     1
              gosub   INCR20
              c=0     x
              dadd=c
              c=regn  9
              n=c
              goto    LB_5F3B
LB_5F0C:      goto    LB_5F43
LB_5F0D:      s0=     0
              goto    LB_5F15
LB_5F0F:      goto    LB_5F4E
LB_5F10:      gosub   LB_5B5E
              ?a<c    wpt
              goc     LB_5EFD
              s0=     1
LB_5F15:      c=b
              rcr     10
              a=c     wpt
              gosub   ADVREC
              c=n
              rcr     3
              c=c+1   x
              rcr     11
              n=c
              gosub   GTBYTA
              c=0     xs
              c=c-1   xs
              ?s0=1
              gonc    LB_5F61
              bcex    x
              gosub   LB_5B55
              c=b     x
              c=c+1   x
              goc     LB_5F31
              acex    wpt
              rcr     4
              pt=     9
              c=b     wpt
              bcex
              goto    LB_5F00
LB_5F31:      gosub   LB_5B6E
              c=n
              rcr     13
              pt=     6
              bcex    wpt
              clr st
              pt=     3
              gosub   APRC10
LB_5F3B:      gosub   LB_5B81
              s5=     0
              c=st
              data=c
              c=0     x
              pfad=c
              goto    LB_5F65
LB_5F43:      gosub   LB_5B81
              ?s5=1
              gonc    LB_5F49
              s5=     0
              goto    LB_5F4A
LB_5F49:      s5=     1
LB_5F4A:      c=st
              data=c
LB_5F4C:      golong  LB_5EF2
LB_5F4E:      c=n
              rcr     3
              ?c#0    x
LB_5F51:      golong  LB_5EF0
              c=c-1   x
LB_5F54:      a=c     x
              b=0     x
              gosub   STRCAB
LB_5F58:      gosub   LB_5B81
              s7=     0
              c=st
              data=c
              gosub   LB_5A69
              golong  LB_5C1A
LB_5F61:      c=c+1   x
              goc     LB_5F51
              gosub   LB_5B55
LB_5F65:      c=n
              rcr     3
LB_5F67:      a=c     x
              b=0     x
              gosub   STRCAB
              goto    LB_5F4C
LB_5F6C:      c=0     x
              c=c-1   x
              bcex    x
              s7=     1
              gosub   TGLSHF2
              s1=     0
LB_5F73:      gosub   CLLCDE
              gosub   MESSL
              .messl  "GTO "
              a=0     s
              a=a+1   s
              a=a+1   s
              c=b     x
              rcr     3
LB_5F80:      ldi     3
              c=c+1   s
              gonc    LB_5F86
              ldi     1
LB_5F86:      c=c-1   s
              rcr     13
              regn=c  15
              a=a-1   s
              gonc    LB_5F80
              gosub   LEFTJ
              ?s1=1
              gonc    LB_5F95
              c=0     x
              pfad=c
              c=b     x
              gosub   GOTINT
              goto    LB_5F54
LB_5F95:      gosub   LB_5A69
              c=0
              pt=     4
              lc      4
              lc      6
              a=c     m
              .newt_timing_start
LB_5F9C:      chk kb
              goc     LB_5FA6
              c=c+1   x
              gonc    LB_5F9C
              gosub   CHKLB2
              a=a-1   m
              gonc    LB_5F9C
              .newt_timing_end
              golong  LB_5D9E
LB_5FA6:      ldi     11
              gosub   `KEY-FC2`
              .con    0xc3          ; back arrow
              .con    0x84          ; 9
              .con    0x74          ; 8
              .con    0x34          ; 7
              .con    0x85          ; 6
              .con    0x75          ; 5
              .con    0x35          ; 4
              .con    0x86          ; 3
              .con    0x76          ; 2
              .con    0x36          ; 1
              .con    0x37          ; 0
              nop
              goto    LB_5FDA
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              goto    LB_5FCB
              gosub   BLINK1
              goto    LB_5F95
              nop
              nop
              nop
              enrom1
              rtn
              enrom2
              rtn
LB_5FCB:      a=c     x
              c=b     x
              pt=     2
              c=c+1   pt
              goc     LB_5FD7
              pt=     1
              asr     x
              c=c+1   pt
              goc     LB_5FD7
              pt=     0
              asr     x
              s1=     1
LB_5FD7:      b=a     pt
              golong  LB_5F73
LB_5FDA:      c=b     x
              pt=     1
              c=c+1   pt
              gonc    LB_5FE2
              pt=     2
              c=c+1   pt
              golc    LB_5EF7
LB_5FE2:      a=0     pt
              a=a-1   pt
              goc     LB_5FD7
LB_5FE5:      ?s7=1
              goc     LB_5FE8
              a=a+c   pt
LB_5FE8:      ldi     341
              c=0     s
              rcr     13
              c=a+c   x
              rcr     11
              cxisa
              rtn
              nop
              nop
LB_5FF2:      golong  RMCK10_B1
              goto    LB_5FF2
              goto    LB_5FF2
              goto    LB_5FF2
              goto    LB_5FF2
              goto    LB_5FF2
              goto    LB_5FF2
              goto    LB_5FF2
              .con    3             ; C
              .con    0x18          ; X
              .con    0x20d         ; M  bank-switched
              .con    0x14          ; T
              .con    0             ; checksum
