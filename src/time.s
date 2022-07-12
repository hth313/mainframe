;;; CX time functions

#include "hp41cx.h"

              .section CXTIME

              .con    26            ; ROM ID
              .con    (FatEnd - FatStart) / 2 ; number of entry points

FatStart:     .fat    HEADER
              .fat    ADATE         ; date to alpha reg
              .fat    ALMCAT        ; alarm catalog
              .fat    ALMNOW        ; run oldest past due label alarm
              .fat    ATIME         ; time to alpha reg
              .fat    ATIME24       ; 24 hour format time to alpha reg
              .fat    CLK12         ; set 12 hr format
              .fat    CLK24         ; set 24 hr format
              .fat    CLKT          ; set time only format
              .fat    CLKTD         ; set time and date format
              .fat    CLOCK         ; start clock mode
              .fat    CORRECT       ; correct time and accurancy factor
              .fat    DATE
              .fat    `DATE+`
              .fat    DDAYS
              .fat    DMY           ; date format= day.month.year
              .fat    DOW
              .fat    MDY           ; date format= month.day.year
              .fat    RCLAF         ; recall accurancy factor
              .fat    RCLSW         ; recall stopwatch contents
              .fat    RUNSW         ; run the stopwatch
              .fat    SETAF         ; set the accurancy factor
              .fat    SDATE         ; set date
              .fat    SETIME        ; set time
              .fat    SETSW         ; set stopwatch
              .fat    STOPSW        ; stop stopwatch
              .fat    SW            ; stopwatch
              .fat    `T+X`
              .fat    TIME
              .fat    XYZALM        ; programmable set alarm function
              .fat    CXHEADER      ; second header
              .fat    CLALMA
              .fat    CLALMX
              .fat    CLRALMS
              .fat    RCLALM
              .fat    SWPT
FatEnd:       .con    0, 0

              .name   "-CX TIME"
CXHEADER:

              .name   "-TIME  2C"
HEADER:

              .name   "SWPT"
SWPT:         golong  SWPT2

              .name   "CLALMA"
CLALMA:       golong  CLALMA2

              .name   "RCLALM"
RCLALM:       golong  RCLALM2

              .name   "CLRALMS"
CLRALMS:      golong  CLRALMS2

              .fillto 0x86
              .name   "DOW"
DOW:          s1=     0             ; don't add X to "DATA ERROR"
              gosub   `X-YMDD`
              gosub   WKDAYS        ; convert days into day of week
              gosub   RUNSST        ; running or SST?
              goto    DOW30         ; (P + 1) yes, don't display
              gosub   CLLCDE        ; (P + 2) enable & clear display
              c=m
              a=0     s
              a=a+1   s             ; A.S = 1
              legal
              gosub   DSWEEK
              gosub   LEFTJ
              gosub   TMSG          ; print message in norm & trace
                                    ;  and set message flag
DOW30:        c=m                   ; C = 0D000000000000
              golong  NFRX

;;; **********************************************************************
;;; * CHECK - checks data input for legailty                  1-30-81 RSW
;;; *   Checks the C.X specified register for legal data, and returns only
;;; *   for numeric data.  Both the register and the output of "CHECK"
;;; *   will be a floating point number (C.S and C.XS- 0 or 9) with all
;;; *   BCD digits.
;;; *
;;; * IN: C.X = register address  !!! The register must exist     !!!!!!
;;; *              !!! Will get memory lost if it does not exist  !!!!!!
;;; *              !!! and S9= 0                                  !!!!!!
;;; * ASSUME: Peripherals disabled
;;; * OUT:    C= legal normalized floating point number
;;; *         DEC mode, the C.X register is enabled
;;; * USES:   A, B, C,  active PT, DADD, arith mode,  +1 sub level
;;; *         (not ST, no timer chip access)

              .public CHKXM, CHECKX, CHECK
CHKXM:        m=c
CHECKX:       ldi     3             ; address of "X" register
CHECK:        dadd=c
              gosub   P6RTN         ; B= massaged register contents
              c=b
              golong  CHK_NO_S      ; error if alpha data


;;; **********************************************************************
;;; * YMDDAY - year, month, day to day number                 1-23-81 RSW
;;; *   Takes a date in "C" and computes the day number.
;;; *   Then calculates a date from the day number and compares it against
;;; *   a date in "X" or "Y" as specified by S0.
;;; *
;;; *  IN:   C= normalized floating point date
;;; *           !! must be a valid floating point number !!
;;; *  ASSUME:  S0= 1 (0) -- check the date against "Y" ("X")
;;; *           S1= 1 (0) -- if error, the "DATA ERROR" message should
;;; *                        specify "Y" ("X") register error
;;; *  OUT:  no error --
;;; *           C= DDDDDD00000000= day number since Oct 15, 1582
;;; *           chip 0 enabled, hexmode
;;; *           A= floating point date (same as DATE in X or Y as specified
;;; *              by S0)
;;; *        error --    does not return
;;; *  USES: A, B, C, N, R8[13:6], active PT, +2 sub levels, arith mode,
;;; *        DADD, PFAD (no timer chip access)
;;; *
;;; * X-YMDD - takes a date from "X" and computes the day number
;;; *  IN: X= normalized floating point date
;;; *         peripherals disabled
;;; *  ASSUME: nothing
;;; *  OUT:  same as YMDDAY but also: S0=0
;;; *  USES: same as YMDDAY but also: S0=0, S9

              .public `X-YMDD`, YMDDAY
`X-YMDD`:     gosub   CHECKX        ; error if alpha data
              s0=     0             ; date from X reg
YMDDAY:       gosub   `C-YMDD`

;;; *
;;; * DATECK - date check                                     1-13-81 RSW
;;; *   Compares the date in X or Y against a date in "A".
;;; *
;;; * IN and ASSUME:
;;; *    A= floating point normalized date
;;; *    chip 0 enabled
;;; *    S1= 1 (0)    do (not) add "X" or "Y" to DATA ERROR if an error occurs
;;; *    S0= 1 (0)    take comparision date from "Y" ("X")
;;; *    R8[13:8]= DDDDDD= day numnber since Oct 15, 1582
;;; * OUT: no error --
;;; *         C= DDDDDD00000000= day number since Oct 15, 1582
;;; *      error case --
;;; *         does not return
;;; * USES: C, active PT  only  (for no error case)

              .public DATECK
DATECK:       c=regn  3             ; C = X reg
              ?s0=1                 ; use Y reg?
              gonc    DATCK2        ; no, use X
              c=regn  2
DATCK2:       a#c?
              gonc    DATCK4        ; date is OK

;;; * TERROR - timer error
;;; *
;;; * IN:  S1= 1 (0)   do (not) add "X" or "Y" to "DATA ERROR"
;;; *        if S1=1, then:  S0= 1 (0)  ADD "Y" ("X") to "DATA ERROR"
;;; * ASSUME: nothing
;;; *     !!!!!! does not return !!!!!!
;;; *
;;; *
;;; *  TERRXY --- same as TERROR except ignores S1 and always adds "X" or "Y"
;;; *             to "DATA ERROR"
;;; *
              .public TERROR
TERROR:       ldi     32            ; blank
              ?s1=1                 ; add X or Y to "DATA ERROR"?
              gonc    TERR20        ; no
              ldi     24            ; X
              ?s0=1                 ; Y register error?
              gonc    TERR20        ; no, X reg error
              c=c+1   x             ; Y= 25

;;; *                                                         1-23-81 RSW
;;; * IN:  C.X= LCD format character to add to "DATA ERROR"
;;; * ASSUME: nothing
;;; *  !! does not return !!
              .public TERR20
TERR20:       bcex    x             ; B.X= character to add
              gosub   ERRSUB        ; return only if error ignore flag = 0
              s8=     0             ; don't print yet
              gosub   MSGA          ; send "DATA ERROR"
              xdef    MSGDE
              gosub   ENLCD
              frsabc
              c=b     x
              slsabc                ; add blank, X, Y or Z to display

              .public TERR50
TERR50:       gosub   TMSG          ; print and set message flag
              golong  ERR110

DATCK4:       c=regn  8             ; C= DDDDDD........
              pt=     7
              c=0     wpt           ; C= DDDDDD00000000
              rtn

;;; **********************************************************************
;;; * IDVD - two register integer divide                      1-15-81 RSW
;;; *   IDVD returns a quotient and a remainder separated by a zero, with
;;; *   the pointer pointing to that zero.
;;; *   C contains 10's complement of divisor with at least one leading 9.
;;; *   Adding a 10's complement (negative) number to a positive number
;;; *   produces a carry every time that the result is still positive, so
;;; *   "IDVD" builds the quotient in "A" by adding "C" to "A" and
;;; *   accumulating the carries as a quotient.
;;; *      [ if N-M >= 0  then  N+(10-M) = (N-M)+10 >= 10  ]
;;; *   C.S is used as a loop counter ( number of digits in answer ), and
;;; *   must be less than 9 (for C.S= 9, only 1 division loop is done).
;;; *
;;; * IN:   1. A.M= dividend, positioned anywhere in A[10:3] with zeros
;;; *                         in unused digit positions
;;; *          (Must have A[12:11]=0 to allow for carries, or the quotient
;;; *           may be wrong.)
;;; *       2. C.M= divisor, (BCD number) with its most significant digit (MSD)
;;; *               in the same position as the MSD of the dividend.
;;; *            !!!! Divisor must not be zero, and in general the size of
;;; *                 the divisor must be known as well as the size of the
;;; *                 resulting quotient !!!!
;;; *       3. C.X= 000
;;; *       4. Pointer= (MSD of dividend) + 1
;;; *       5. C.S= (number of quotient digits in answer) - 2
;;; *            !!!! Warning: If divisor digits get shifted off the right
;;; *                          end of the C register, some accurancy will
;;; *                          be lost !!!!
;;; *            !!!! Must be a BCD digit < 9 !!!!
;;; *
;;; * ASSUME: DEC mode
;;; *
;;; * OUT:  1. "A" contains the quotient with all unused digits = 0.
;;; *          The leftmost digit (it may be a zero) of the quotient
;;; *          will be 2 digits to the left of the MSD of the input
;;; *          dividend.
;;; *       2. "C" contains the remainder, with all unused digits= 0.
;;; *          The leftmost digit (it may be zero) of the remainder
;;; *          is 2 digits to the right of the rightmost quotient digit.
;;; *          (There is 1 empty digit between the quotient and remainder)
;;; *       3. Pointer pointing to the leftmost digit (it may be zero) of
;;; *          the remainder.
;;; *          (The PT is decremented once for each digit of the quotient)
;;; * USES:  A, C, active PT
;;; *        (no ST,  +0 sub levels, no DADD, no PFAD, no timer chip access)
;;; *
;;; * IDVD4 -- same as IDVD except C.S= (number of quotient digits) - 4

              .public IDVD, IDVD4
IDVD4:        c=c+1   s
              c=c+1   s
IDVD:         c=c+1   s             ; increment loop counter
              c=-c    wpt
IDVDL:        a=0     s
              a=a+c                 ; perform subtraction
              ?a#c    pt            ; overflow? (too many subtracts?)
              goc     IDVDL         ; no, A[PT] # 9
              a=a-c                 ; yes, recover extra subtraction
              csr     wpt           ; divide by 10
              dec pt
              c=c-1   s             ; carries when done
              gonc    IDVDL
              a=0     s
              c=0
              acex    wpt           ; C= remainder
              rtn

;;; **********************************************************************
;;; * ENTMR - enable timer                                    1-6-81 RSW
;;; * Disables RAM and enables timer chip.
;;; *
;;; * IN and ASSUME: nothing
;;; * USES: C.X, DADD, FADD, TIMER PT
;;; *       (no 41C PT, no ST, +0 sub levels, no arith mode)
;;; * Out:  Timer chip enabled, RAM disabled, timer PT=A
;;; *
;;; *
;;; * ENTMRS - same as ENTMR except restores S0-S7 from C[1:0] before
;;; *          destroying C[1:0], so ENTMRS uses S0-S7
;;; **********************************************************************

              .public ENTMRS, ENTMR
ENTMRS:       st=c
ENTMR:        ldi     16            ; non-existent RAM addr
              dadd=c
              ldi     0xfb          ; timer chip addr= FB
              pfad=c                ; enable timer
              pt=a
              rtn


;;; **********************************************************************
;;; * TIME - Time function
;;; *        Put the current time in HMS form to X. If not running,
;;; *        display the time as a message.
;;; **********************************************************************

              .public TIME
              .name   "TIME"
TIME:         gosub   IGDHMS        ; initialize, get day-hour-min-sec
              b=a                   ; A= B= C= DDDDDDHHMMSSCC
              rcr     9             ; C= .HHMMSSCC ......
              c=0     s
              gosub   NORMC         ; A= C= normalized F.P. time
              gosub   RUNSST        ; running or single-stepping?
              goto    DATX37        ; (P+1) yes, don't display the time
              abex                  ; (P+2) no, display time
              gosub   DSPTIM
              goto    DATX30


;;; **********************************************************************
;;; * DATE - Date function
;;; *        Put the date in MM.DDYYYY form to X. If not running, display
;;; *        the date as a message.
;;; **********************************************************************

              .public DATE
              .name   "DATE"
DATE:         gosub   IGDHMS        ; A= DDDDDDHHMMSSCC
              gosub   DAYMDF        ; A= C= positive normalized F.P. date
              gosub   RUNSST        ; running or single-stepping?
              goto    DATX37        ; (P+1) yes, no display
              gosub   CLLCDE        ; (P+2) no, display date
              s2=     1             ; display the year
              gosub   DSPDTA
DATX30:       gosub   TMSG          ; print display in norm & trace
DATX37:       c=m
DATX40:       bcex                  ; B= new value of "X"
              golong  RCL


;;; **********************************************************************
;;; * RCLSW - Load the time in stopwatch to X-register        2-3-81 RSW
;;; *
;;; * The time will be in H.M.S form and less than 99.595999
;;; * The time can either be positive or negative
;;; **********************************************************************

              .public RCLSW
              .name   "RCLSW"
RCLSW:        gosub   INITMR        ; initialize timer if necessary
              s8=     0             ; ignore keyboard
              gosub   GETMR
              goto    DATX40


;;; **********************************************************************
;;; * RCLAF - Recall accuracy factor                          1-9-81 RSW
;;; **********************************************************************

              .public RCLAF
              .name   "RCLAF"
RCLAF:        gosub   GETAF
              goto    DATX40        ; (timer chip disables on "dadd=c")

;;; **********************************************************************
;;; * GETAF - Get accuracy factor                             1-9-81 RSW
;;; * Reads the accuracy factor from the timer chip and formats it
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: C= normalized floating point accuracy factor
;;; *      hexmode, timer PT=B, timer chip enabled, RAM disabled
;;; * USES: A, C, S0-S7, active PT, arith mode, +2 sub levels, DADD, PFAD
;;; *       timer PT
;;; *       (no timer ST)
;;; **********************************************************************

              .public GETAF
GETAF:        gosub   INITMR        ; initialize timer if necessary, PT=B
              rdsts                 ; C= AF= 000000000SDDD0
              rcr     5             ; C= SDDD0000000000
              gosub   NORM          ; C= normalized AF
              ?c#0    s             ; negative?
              rtn nc                ; no
              pt=     13            ; yes
              lc      9             ; fix sign digit
              rtn


;;; **********************************************************************
;;; * RUNSW - Run stopwatch                                   1-8-81 RSW
;;; **********************************************************************

              .public RUNSW
              .name   "RUNSW"
RUNSW:        gosub   INITMR        ; initialize timer if necessary, PT=B
              startc                ; start the stopwatch
              rtn                   ; note: the timer chip automatically
                                    ; disables when "dadd=c" is executed


;;; **********************************************************************
;;; * GETMR - get the time of timer                           2-2-81 RSW
;;; * If the time >= 100 hours, the output will be (time)mod(100) but the
;;; * timer time will not be cleared.
;;; *
;;; * IN: nothing
;;; * ASSUME:  S8= 1 (0) to check (ignore) keyboard
;;; *              if S8=1, then; S9= 1 (0) return on key up (down)
;;; * OUTPUT: !!! see GTMR30 comments about garbage out or jump to TMRKEY !!!
;;; *         B= unnormalized time= #HHMMSSCC..... (#= 0 for positive,
;;; *                                                  9 for negative)
;;; *         A= C= signed normalized floating point time
;;; *         hexmode, P selected, Q= 13
;;; *         timer chip enabled, timer PT=B
;;; * USES: A, B[13:3], C, P, Q, +1 sub level, arith mode, DADD, PFAD
;;; *       timer PT
;;; *       (no ST)
;;; *
;;; * GETMRC-- IN: C= time in seconds, so doesn't enable or access
;;; *              timer chip
;;; **********************************************************************

              .public GETMR, GETMRC
GETMR:        gosub   ENTMR
              pt=b                  ; select stopwatch clock
              rdtime                ; read stopwatch time
GETMRC:       setdec                ;  389 >= max exec time >= 220
              ?c#0    s             ; complemented?
              gonc    GTMR15        ; no
              pt=     12            ; yes, keep C.S= 9
              c=-c    wpt
GTMR15:       a=c
              b=a     s             ; save the sign
              a=0     s
              gosub   `36000`       ; C= 00000036000000
              a=a+c                 ; yes, restore it

;;; **********************************************************************
;;; *                                                         2-3-81 RSW
;;; * GETMR30 -- convert stopwatch time to H.MS normalized floating
;;; *            point form
;;; *
;;; * IN: A= #00SSSSSSSSSCC= stopwatch time (S= seconds, C= centiseconds)
;;; * ASSUME: S8= 1 (0)     to check (ignore) keyboard
;;; *             if S8= 1, then;    S9= 1 (0) return on key up (down)
;;; *         B.S= sign of the time (0= positive, 9= negative)
;;; * OUT: if S8=1 & S9=1 and the key goes up, output= garbage
;;; *      if S8=1 & S9=0 and the key goes down, jump to "TMRKEY"
;;; *      otherwise:
;;; *        A= C= signed normalized floating point time
;;; *        hexmode, P selected
;;; * USES: A, B.M, C, P, Q, +1 sub level, arith mode
;;; *       (no ST, no DADD, no PFAD, no timer chip access)
;;; **********************************************************************

              .public GTMR30
GTMR30:       c=0     x
              gosub   KEYCHK        ; check keyboard if S8= 1
              pt=     6             ; A= 00SSSSSSSSSSCC
              gosub   SDHMSK        ; A= 00000HHMMSSCC
              gosub   X20Q8         ; A= (days) x 20
              csr                   ; C= (days) x 4
              c=a+c                 ; C= (days) x 24
              pt=     12
              rcr     9             ; C= 0HHMMSSCC.....
              bcex    wpt           ; B= #HHMMSSCC......
              c=b
              gosub   KEYCHK

;;; Falls into NORMC !!!!!!!

;;; **********************************************************************
;;; * NORM - normalize                                        1-6-81 RSW
;;; *
;;; * INPUT: C= Floating point !unnormalized! number with the exponent
;;; *           decremented 1 below its correct value (so that times & dates
;;; *           can be input with C.X= 0).
;;; *              The exponent must be >= -91 or "NORM" may decrement
;;; *              past -99 !!!!!!!!!
;;; * ASSUMES: nothing
;;; * OUT: HEXMODE
;;; *      A= C= normalize floating point number
;;; *      The sign of the number is preserved except for negative zero
;;; *      which is set positive.
;;; * USES: A, C, active PT, arith mode
;;; *       (no ST, +0 sub levels, no DADD, no PFAD, no timer chip access)
;;; *
;;; * NORMC - same as NORM except sets C[4:0]= 0000
;;; *
;;; **********************************************************************

              .public NORM, NORMC
NORMC:        pt=     4
              c=0     wpt
NORM:         ?c#0    m             ; value = 0?
              goc     NORM00        ; no
              c=0                   ; yes normalize it to 0
              goto    NORM20
NORM00:       setdec
              a=c
              a=a+1   x
              pt=     12
              goto    NORM10
NORM05:       asl     m             ; shift out leading zeros
              a=a-1   x
NORM10:       ?a#0    pt
              gonc    NORM05
              acex                  ; C= normalized number
NORM20:       a=c
              sethex
              rtn


;;; **********************************************************************
;;; *                                                         1-8-81 RSW
;;; * MDY - set the date format to month.day.year (clear flag.31)
;;; * DMY - set the date format to day.month.year (set flag.31)
;;; *
;;; * When mainframe flag.31 is set, all I/O
;;; * of date is assumed DD.MMYYYY format. When flag.31 is cleared, all
;;; * the I/O of date is assumed MM.DDYYYY format.
;;; *
;;; * IN & ASSUME: chip 0 enabled, peripherals disabled
;;; **********************************************************************

              .public MDY
              .name   "MDY"
MDY:          c=regn  14
              rcr     5
              cstex
              s4=     0             ; clear flag 31
MDY10:        cstex
              rcr     9
              regn=c  14
              rtn

              .public DMY
              .name   "DMY"
DMY:          c=regn  14
              rcr     5
              cstex
              s4=     1
              goto    MDY10


;;; **********************************************************************
;;; *                                                         1-15-81 RSW
;;; * WKDAYS - Convert days since Oct 15, 1582 into day of week.
;;; *
;;; * INPUT: C = DDDDDD00000000 = days since Oct 15, 1582
;;; *           where Oct 15, 1582 = 00000
;;; *                 Sep 10, 4320 = 99999
;;; * ASSUME: nothing
;;; * OUTPUT: C = 0D000000000000, hexmode
;;; *         where D is the number present the day of week
;;; *         0 = Sunday
;;; *         :             (Oct 15, 1582 = FRI = 5)
;;; *         :
;;; *         6 = Saturday
;;; * USES: A, C, active PT, +1 sub level, arith mode
;;; *       (no ST, no DADD, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public WKDAYS
WKDAYS:       a=c
              asr
              asr                   ; A = 00DDDDDD000000
              setdec
              c=0
              pt=     6
              lc      5             ; adjust day# so day of week
                                    ;   comes out right
              a=a+c                 ; possible that A= 0 1DDDDDD000 000
; The quotient may be wrong, but only the reminder is used.
              c=0
              pt=     11
              c=c+1   s
              c=c+1   s             ; 6 iterations in division
              lc      7             ; C= 2 0700000000 000
              pt=     12
              gosub   IDVD4         ; remainder = day-of=week
              sethex                ; remainder= C[6], C= 0 000000D000 000
              rcr     8             ; C = 0D000000000000
              rtn


;;; **********************************************************************
;;; * DSAMSG - display alarm message                          1-27-81 RSW
;;; *
;;; * This routine gets the message from the alarm catalog and displays it.
;;; * If the alarm doesn't have a message, the display will be cleared.
;;; * If the message is shorter than 12 characters, the message will be
;;; * displayed left justified.
;;; * If the message is longer than 12 characters, S8 can be used as follows:
;;; * S8 = 0 - only display the first 12 characters
;;; * S8 = 1 - Display the first 12 characters and then wait for key up to
;;; *          display the rest of the message.
;;; *
;;; * IN: M.X = address of current alarm  (!! must be a valid alarm address
;;; *                                      -- not trailer register address!!)
;;; *     S8= 0 to display only the first 12 characters
;;; *     S8= 1 to display the first 12 characters and then wait for key
;;; *           up to display the rest of the message
;;; * ASSUME: no alarm message registers may contain all nulls (register= 0)
;;; *         (it won't lock up, but the display will be funny)
;;; *         hexmode
;;; * OUT: P selected, Q= 13  (in all cases)
;;; *      if return to (P+1):  (no message)
;;; *          alarm time&date register enabled, peripherals disabled
;;; *      if return to (P+2)       (message displayed)
;;; *          chip 0 enabled, peripherals disabled
;;; *          S8= 0 if S8= 0 on input
;;; *          B.S= 0
;;; *          B[12]  = (number of bytes left in last message register) - 1
;;; *          B[11]  = (number of message registers not yet fully displayed) - 1
;;; *          B[5:3] = address of current message register
;;; *          N      = current message register with next character in N[13:12]
;;; * USES: A, B, C, N, P, Q, S3, +1 sub level, arith mode, DADD, PFAD,
;;; *       if the message >= 12 characters and S8=1 on input, then sets S8=0
;;; *              (no timer chip access)
;;; *********
;;; *
;;; *
;;; * DSA2ND - entry point to display the 2nd part of the alarm message
;;; *    !! must not be used to display the first half since it doesn't skip
;;; *       leading nulls !!
;;; * IN: B.S    = 0
;;; *     B[12]  = (number of bytes left in current message reg) - 1
;;; *     B[11]  = (number of message registers not yet fully displayed) - 1
;;; *     B[5:3] = address of current message register
;;; *     N      = current message register with next character in N[13:12]
;;; * ASSUME: P selected, Q= 13, hexmode
;;; * OUT: if return to (P+1): no more characters
;;; *           display unchanged, chip enable unchanged
;;; *           (uses only the active PT)
;;; *      if return to (P+2):  more characters in message
;;; *           chip 0 enabled, peripherals disabled, S3= S8= 0
;;; * USES: same as DSAMSG except always uses S8
;;; **********************************************************************

              .public DSAMS0, DSAMSG
DSAMS0:       s8=     0
DSAMSG:       s3=     1             ; set "first register" flag
              sel q
              pt=     13
              sel p
              c=0     x
              pfad=c                ; disabled any peripheral
              c=m                   ; C.X = addr of current alarm
              a=c     x
              dadd=c
              c=data                ; load current alarm
              ?c#0    xs            ; alarm has reset interval?
              gonc    AMG10         ; no
              a=a+1   x
AMG10:        a=a+1   x             ; A.X = 1st message reg
              rcr     1             ; C.S = message length
              c=c-1   s             ; C.S = # of msg reg - 1
              rtn     c             ; no message
              rcr     5             ; C= X XXXXRXXXXX XXX (R= msg reg ctr)
              acex    x
              rcr     11            ; C= X XRXXXXXAAA XXX (A= msg reg addr)
;;; Use A.M rather than A.X for message reg address since PIL
;;; printer "PRTLCD" routine uses B.X (where A.X would be stored).
              pt=     13
              lc      12            ; C.S= # unused char positions in LCD
              a=c                   ; A[13]= # unused char positions in LCD
                                    ; A[11]= msg length (in registers)
                                    ; A[5:3]= message register address
              gosub   CLLCDE
DSAM20:       acex                  ; C= counters
              pt=     12
              lc      6
              a=c                   ; A[12]= byte ctr within reg= 6
                                    ;    ( 7 bytes/register )
              c=0     x             ; C= X 6RXXXXXXAAA 000
              pfad=c                ; disable display
              rcr     3             ; C.X= message register address
              dadd=c
              c=data                ; load one message register
              ?s3=1                 ; first register of message?
              gonc    DSAM30        ; no, don't skip embedded nulls
              pt=     12            ; yes, skip embedded nulls
              s3=     0             ; clear first register flag
DSAM25:       ?c#0    pq            ; any leading null?
              goc     DSAM30        ; no
              rcr     12            ; skip leading nulls
              a=a-1   pt            ; decrement byte counter
              gonc    DSAM25
;;; !! Assume  that the register will not be all nulls !!!!!
;;;    There must be at least 1 non-null character!
DSAM30:       n=c                   ; save message register in N
              gosub   ENLCD
DSAM35:       b=a                   ; save all counters in B
                                    ; B.S= unused LCD character count
                                    ; B[12]= register byte counter
                                    ; B[11]= message register counter
                                    ; B[5:3]= message register address
              c=n
              rcr     12            ; C[1:0]= next ASCII character
              n=c
              gosub   ASCLCD        ; send the C[1:0] character to display
;;; Note: A "NOP" following "gosub ASCLCD" will cause any char except
;;;       punctuation not to be sent to the display/

DSAM37:       a=b                   ; get counters back to A
              ?a#0    s             ; display full?
              gonc    DSAM50        ; yes
              pt=     12
              a=a-1   pt            ; end of one register?
              gonc    DSAM35        ; no
DSAM45:       pt=     11
              a=a-1   pt            ; all message registers finished?
              goc     DSAM60        ; yes, all characters out
              a=a+1   m             ; point to next message register
              goto    DSAM20
DSAM50:       ?s8=1                 ; continue to display rest of the msg?
              gonc    DSAM80        ; no, (display full: don't left justify)
              gosub   RSTKB         ; wait for key up (does up debounce)
              pt=     11
              ?b#0    pq            ; any more characters?
              gonc    DSAM80        ; no

              .public DSA2ND
DSA2ND:       pt=     11
              ?b#0    pq            ; any more message characters?
              rtn nc                ; no, done
              gosub   CLLCDE
              pt=     13
              lc      12
              bcex    s             ; B.S= 12= whole display empty
              s8=     0             ; remember 2nd half of message
              s3=     0             ; clear "first register" flag
              goto    DSAM37        ; display rest of message
;;; Now left justify the display, allowing it all to be blanks
DSAM60:       ldi     523
              rcr     1
              a=c; A.X= @40= blank, A.S= 11
              pt=     1
DSAM65:       rabcl                 ; fetch leftmost display character
              ?a#c    wpt           ; blank?
              goc     DSAM70        ; no, done
              a=a-1   s             ; display= all blanks?
              gonc    DSAM65        ; maybe not, keep looking
DSAM70:       rabcr                 ; restore the display
DSAM80:       gosub   ENCP00
              b=0     s
DSAM90:       golong  `RTNP+2`


;;; **********************************************************************
;;; * PUGALM - purge an alarm                                 12-15-80 RSW
;;; * INPUT: M.X = address of alarm to be purged
;;; *   !!!! This must be a valid alarm reg address, not the address of
;;; *   !!!! the trailer reg (or reset interval or message reg)
;;; * ASSUME: hexmode
;;; * OUT:  P selected, Q= 13, peripherals disabled
;;; *      If there are still 1 or more alarms left, return to P+2
;;; *         if the purged alarm was the highest addressed alarm in the
;;; *         alarm stack, then M.X will point to the new highest addressed
;;; *         alarm in the stack, and A.S = 0
;;; *
;;; *         otherwise, M.X will be unchanged (so it will point to what was
;;; *         the next highest addressed alarm in the stack) and A.S= F
;;; *
;;; *      If the alarm purged was the only alarm,     return to P+1
;;; *         the whole buffer will be purged.
;;; *
;;; * USES: A, B(X&S), C, N, may update M.X, P, Q, S3, S8, +2 sub levels
;;; *       DADD, PFAD  (no timer chip access)
;;; *
;;; **********************************************************************

              .public PUGALM
              .public PUGA10
PUGALM:       gosub   SRHBUF        ; A.X= beginning of buffer
                                    ;  (also sets Q= 13)
                                    ; (P+1)
                                    ; (P+2) assume no error possible
PUGA10:       gosub   `GETM.X`      ; C= alarm reg
              n=c                   ; set N= alarm reg
              s3=     1             ; purging the alarm
              gosub   CHKBUF        ; find end of I/O buffer area
              bcex    x             ; B.X= last reg of last I/O buffer
              a=c     x             ; A= addr of timer buffer header reg
              dadd=c
              c=data
              pt=     1
              rcr     10
              c=c-1   wpt           ; check for empty buffer (2 reg)
              c=c-1   wpt
              a=0     s
              c=c-1   wpt
              gonc    PUGA30        ; don;t purge the buffer
              a=a+1   s             ; purge the header and
              a=a+1   s             ;  trailer registers also
              c=m
              acex    x
              m=c                   ; M.X= address of header register
PUGA30:       c=n      ; C= alarm to be purged
              gosub   SHFTDN
;;; * Note: The maximum time to shift the I/O buffers to purge an alarm is
;;; *       about 3.6 seconds, assuming a 6 register alarm shifted 319
;;; * registers.
              golong  PUGA35
PUGA40:       gosub   `GETM.X`      ; C= next alarm
              a=a-1   s             ; output A.S= F is this was not the last
                                    ;   alarm in the stack
              c=c+1   s             ; is it the trailer register?
              gsubc   ALMBST        ; yes, backstep to previous alarm
PUGA50:       goto    DSAM90



              nop
              nop
RUNSST:       golong  RUNST2


;;; **********************************************************************
;;; * RSTALM - reset an alarm by its auto reset interval.     1-14-81 RSW
;;; *  Tries to reset the alarm by its auto next future occurance, but
;;; *  due to the time taken to shift the alarm to its new location in
;;; *  the alarm stack and the time to do other overhead after alling
;;; *  "RSTALM", the alarm may be set to the past!!!!!
;;; *
;;; * INPUT: M.X= address of current alarm  (must be a valid address!!!)
;;; *        hexmode
;;; *        reset interval exponent field = 000 with interval stored in
;;; *          this format:       0 0SSSSSSSST 000
;;; *          where "T"= tenth's of seconds
;;; * ASSUME: peripherals disabled
;;; * OUT:  (P+1): alarm has reset interval
;;; *           C.X- new address of current alarm (rest of C is copy of M)
;;; *           P selected, Q= 13, hexmode, timer PT=A
;;; *       (P+2): no reset interval  (uses only: C, DADD, arith mode)
;;; *           hexmode
;;; * USES: A, B, C, N, P, Q, S3, +2 sub levels, DADD, PFAD, arith mode,
;;; *       timer PT
;;; *
;;; **********************************************************************

              .fillto 0x222
              .public RSTALM
RSTALM:       gosub   `GETM.X`      ; C= alarm time & info
              ?c#0    xs            ; alarm has reset interval?
              gonc    PUGA50        ; no, return to P+2
              sel q
              pt=     13
              sel p
              pt=     3
              bcex                  ; B= alarm time & info
              c=m
              c=c+1   x             ; C.X= address of reset interval
              dadd=c
              c=data                ; C= 0 0SSSSSSSST 000= reset interval
                                    ;   ("T"= tenth's of seconds)
              a=c
              setdec
RSTA05:       asl     pq            ; left justify reset interval
              a=a-1   x
              ?a#0    s
              gonc    RSTA05
              a=a-1   x
              abex    pq            ; A[13:3]= alarm time
                                    ; B[13:3]= left justified reset interval
              gosub   ENTMR         ; enable timer chip, disable RAM, PT=A
RSTA10:       rdtime                ; C= current time= 00SSSSSSSSSSCC
                                    ; timer PT=A
;;; * This code was changed from Time module 1C where it used 3 seconds
;;; * in the future. Here it is 0.2 seconds.
              rcr     12            ; C= SSSSSSSSSSCC00
              c=c+1   pq
              c=c+1   pq            ; make time 0.2 seconds in future
              nop
              nop
RSTA15:       a=a+b   pq            ; add reset interval to alarm time
              goc     RSTA17        ; overflow
              ?a<c    pq            ; alarm still in the past?
              goc     RSTA15        ; yes
RSTA17:       a=a+1   x             ; done?
              goc     RSTA20        ; yes
              a=a-b   pq            ; remove extra add
              bsr     pq            ; shift reset interval
              goto    RSTA10
RSTA20:       b=a     pq            ; B= new alarm time & info
              sethex
              c=m                   ; C.X= alarm address
              gosub   NEWLSK        ; A.X= addr of first alarm > new alarm
                                    ;  or A.X= addr of trailer reg
              a=a-1   x
              s3=     0             ; not purging the alarm
              c=m                   ; C.X= addr of current alarm
              dadd=c
              c=b                   ; C= new alarm time & info
              pt=     1
              c=0     pt            ; unmark the alarm
              data=c                ; update alarm time
              b=a     x             ; B.X= addr of highest reg to be shifted
              a=0     s
              gosub   SHFTDN        ; shift alarm to new location
;;; * Note: The maximum time to shift a reset alarm to its new location is
;;; *       about 2.9 seconds, assuming a 6 register alarm shifted 253
;;; *       registers.
              abex    s             ; A.S= (# alarm reg) - 1
              c=m
              c=b     x             ; C.X= last reg of shifted alarm
RSTA50:       a=a-1   s
              rtn c
              c=c-1   x             ; set C.X= 1st reg of shifted alarm
              goto    RSTA50


;;; **********************************************************************
;;; *                                                         12-15-80 RSW
;;; * SHFTDN - shift a block of regs down, rotate bottom alarm to top
;;; * INPUT: B.X= addr of highest addressed reg to be shifted down
;;; *       [to purge an alarm, this must be the last register of the last
;;; *        (highest addressed) I/O buffer]
;;; *        C.X= exponent field of alarm time&date register (alarm info)
;;; *        M.X= addr of current alm (lowest addressed reg to be shifted)
;;; *        A.S= 0 unless purging the whole buffer, when A.S= 2
;;; *        S3=1: called from PUGALM (purges current alm)
;;; *        S3=0: called from RSTALM (rotates current alm to top of
;;; *                                  the shifted area)
;;; * ASSUMES: peripherals disabled, hexmode
;;; * OUT: B.X preserved, S3 preserved
;;; *      B.S= (number of reg in the current alm) - 1
;;; * USES: A(X&S), B.S, C, N, DADD
;;; *       (no PT, no timer chip access, +0 sub levels, no PFAD)
;;; **********************************************************************

              .public SHFTDN
SHFTDN:       ?c#0    xs            ; reset interval?
              gonc    SHFTD2        ; no
              c=c+1   x
SHFTD2:       rcr     1             ; C.S= # regs (msg + auto inc)
              a=a+c   s
              b=a     s
SHFTD4:       c=m
              dadd=c
              c=data
              ?s3=1                 ; purging alarm?
              gonc    SHFTD6        ; no
              c=0                   ; yes, purge current alm
SHFTD6:       n=c                   ; N= register to be rotated
              c=m
              goto    SHFTD8
SHFTD7:       c=c+1   x
              dadd=c
              c=data
              acex    x             ; A.X= data, C.X= address
              dadd=c
              acex    x             ; A.X= addr, C.X= data
              data=c
              a=a+1   x
              acex    x
SHFTD8:       a=c     x
              ?a<b    x             ; more registers to shift?
              goc     SHFTD7        ; yes
              c=b     x
              dadd=c
              c=n
              data=c
              a=a-1   s
              gonc    SHFTD4
              rtn


;;; **********************************************************************
;;; * FNDMSG - find message                                   1-9-81 RSW
;;; *  Finds the first non-null register in the alpha register.
;;; *
;;; * IN & ASSUME: peripherals disabled, hexmode
;;; * OUT:   If the alpha register is not empty--
;;; *           C= first non-null register (that register is enabled)
;;; *           A.X= address of the first non-null register
;;; *           A.S= (message length in registers) - 1
;;; *
;;; *        If the alpha register is empty--
;;; *           C= 0
;;; *           A.X= 4
;;; *           A.S= F
;;; * USES: A(S&X), C, active PT, DADD
;;; *       (no ST, +0 sub levels, no PFAD, no timer chip access)
;;; **********************************************************************

              .public FNDMSG
FNDMSG:       ldi     8
              dadd=c                ; enable reg 8
              acex    x             ; A.X= 8= register address
;;; * Note: Could save a state by setting C.S=3 and doing 'acex' at
;;; *       the expense of destroying A.M
              pt=     13
              lc      3
              pt=     7
              a=c     s             ; A.S= C.S= 3
              c=data
              rcr     6
              c=0     wpt           ; clear reg 8 scratch area
              rcr     8
FNDM10:       c#0?
              rtn c
              a=a-1   x             ; decrement register address
              a=a-1   s             ; alpha register empty?
              rtn c                 ; yes
              acex    x
              a=c     x
              dadd=c
              c=data
              goto    FNDM10


;;; **********************************************************************
;;; *                                                         1-12-81 RSW
;;; * CHKALM - check alarm stack to see if there are any past due alarms
;;; *          and unmark all future alarms
;;; *
;;; * IN: A.X= address of the first register (header reg) in the timer buffer
;;; * ASSUME: hexmode, P selected, Q= 13
;;; * OUT: timer PT=A (in all cases)
;;; *      B.XS= zero   (non-zero) --- there are (no) past due alarms
;;; *      B[1:0]= zero (non-zero) --- there are (no) undisplayed
;;; *                                        past due alarms
;;; * NOTE: CHKALM reads the time once at the beginning and uses that
;;; *       time as the reference for past due versus future alarms.
;;; *
;;; * USES: A, B.X, C, active PT, timer PT, +1 sub levels, DADD, PFAD
;;; *       (no ST)
;;; *
;;; **********************************************************************

              .public CHKALM
CHKALM:       gosub   ENTMR ; enable timer chip, disable RAM, PT=A
              rdtime                ; C= current time
              rcr     12            ; C= SSSSSSSSSSCC00
              c=0     x
              c=c-1   x
              bcex    x             ; B.X= set non-zero
              acex    x
              c=c+1   x             ; C.X= 1st alarm address
                                    ;   (or perhaps trailer reg address)
              a=c
              goto    CHKA35
CHKA20:       b=0     xs            ; there is at least 1 past due alarm
              pt=     1
              ?c#0    pt            ; has this alarm been displayed?
              goc     CHKA25        ; yes
              b=0     wpt           ; B[1:0]= 0= remember undisplayed alarm
CHKA25:       acex    x             ; C.X= alarm address
              gosub   SKPALC        ; A.X= C.X= next alarm address
CHKA35:       dadd=c
              c=data
              c=c+1   s             ; end of alarm stack? (trailer reg?)
              rtn c                 ; yes
              c=c-1   s
              pt=     3
              ?a<c    pq            ; is this a future alarm?
              gonc    CHKA20        ; no
              pt=     1             ; yes
              c=0     pt            ; unmark future alarms
              data=c
              goto    CHKA25


;;; **********************************************************************
;;; * SWPM&D - swap month and day                             12-18-80 RSW
;;; *    if flag 31= 0 (M.DY), swaps month & day
;;; *    if flag 31= 1 (D.MY), does not swap month & day
;;; *  so the output is always D.MY
;;; *
;;; * IN: A= . MMDDYYYY.. ... and flag 31= 0
;;; *      ( or A= . DDMMYYYY.. ...  and flag 31= 1 )
;;; *       where "." means "don't care"
;;; * ASSUME: nothing
;;; * OUT: C= 0DDMMYYYY00 000
;;; *      chip 0 enabled, PT= 6, hexmode
;;; * USES: A, C, active PT, DADD, PFAD, arith mode
;;; *       (no ST, +0 sub levels, no timer chip access)
;;; *
;;; **********************************************************************

              .public `SWPM&D`
`SWPM&D`:     pt=     4
              a=0     wpt
              sethex
GFLG31:       golong  GFLG31_2


              .name   "DATE+"
`DATE+`:      golong  DDATE2

              .name   "DDAYS"
DDAYS:        golong  DDAYS2

              .name   "CLALMX"
CLALMX:       golong  CLALMX2

;;; **********************************************************************
;;; * CLK12                                                   1-6-81 RSW
;;; **********************************************************************

              .name   "CLK12"
              .public CLK12
CLK12:        gosub   ITMRST        ; get timer software status
              s6=     0             ; clear 24 hr format bit
                                    ;  (to get 12 hour format)
CLKST:        c=st
              wrscr                 ; update scratch reg B
              rtn

;;; **********************************************************************
;;; * CLK24                                                   1-6-81 RSW
;;; **********************************************************************
              .name   "CLK24"
              .public CLK24
CLK24:        gosub   ITMRST        ; get software status
              s6=     1             ; set 24 ht format bit
              goto    CLKST

;;; **********************************************************************
;;; * CLKT                                                    1-6-81 RSW
;;; **********************************************************************
              .name   "CLKT"
              .public CLKT
CLKT:         gosub   ITMRST        ; get software status
              s7=     0             ; clear "time & date" bit
              goto    CLKST

;;; **********************************************************************
;;; * CLKTD                                                   1-6-81 RSW
;;; **********************************************************************

              .name   "CLKTD"
              .public CLKTD
CLKTD:        gosub   ITMRST        ; get software status
              s7=     1             ; set "time & date" bit
              goto    CLKST         ;  (to show time & date)


;;; **********************************************************************
;;; * ITMRST - initialize and put up timer status             1-6-81 RSW
;;; *
;;; * IN: warm start constant in alarm B register
;;; *     software status bits in scratch reg B
;;; * ASSUME: nothing
;;; * OUT: timer chip enabled, timer PT=B, timer software status up,
;;; *      RAM disabled, hexmode
;;; * USES: A, C, S0-S7, timer PT, DADD, PFAD, +2 sub levels, arith mode
;;; *       (no 41C PT)
;;; *
;;; **********************************************************************

              .public ITMRST
ITMRST:       gosub   INITMR        ; initialize timer if necessary
              golong  TMRST


;;; **********************************************************************
;;; * DSPDTA - display the date in "A"                        1-28-81 BW
;;; *  shifts the date characters left into the display
;;; *     (the display is not cleared)
;;; *
;;; * IN: Display properly initialized. Display MUST be cleared if S2=1
;;; *       (DSPDTA does not clear the display!!!!)
;;; *     A= positive normalized floating point date (with exponent= 0 or 1)
;;; *         !! it must be a valid date -- no error checking is done !!
;;; * ASSUME: S2 = 0  to display only month and day
;;; *         S2 = 1  to diaplay month, day, year, and day of week
;;; *            if S2= 1 must also have R8[13:8]= day number since
;;; *                Oct 15, 1582
;;; * OUT: chip 0 enabled, peripherals disabled, hexmode
;;; *      S5= 1 (0)  for 24 (12) hour format
;;; *      if S2= 1, display is left justified, and P selected
;;; *      if S2= 0, display has not been left justified, and pointer select
;;; *                is same as input
;;; * USES: A, B, C, G, (P, Q if S2=1)/(active PT if S2=0), S0, S3-S5,
;;; *       +2 sub levels  (no timer chip access)
;;; *
;;; *   *    *    *    *    *    *
;;; *
;;; * DSPDT -- same as DSPDTA except:
;;; *
;;; * IN: A= DDDDDD........= day number since 1/1/1900
;;; * ASSUMES: same as DSPDTA
;;; * OUT: same as DSPDTA, but also R8[13:8]= day number since Oct 15, 1582
;;; * USES: A, B, C, G, N, R8[13:8], (P, Q if S2=1)/(active PT if S2=0), S0, S3-S5,
;;; *       +2 sub levels, arith mode, DADD, PFAD     (no timer chip access)
;;; **********************************************************************

              .public DSPDT, DSPDTA
DSPDT:        gosub   DAYMDF        ; A= date, R8[13:8]= day number
DSPDTA:       ?a#0    x             ; month(day) only 1 digit?
              goc     DSDT10        ; no, month(day) is 2 digits
              asr                   ; A= 00MDDYYYY00000
DSDT10:       ldi     2             ; display month & day
              ?s2=1                 ; display year also?
              gonc    DSDT20        ; no
              sel q
              pt=     8
              sel p
              pt=     8
              lc      1
              lc      9
              pt=     7
              ldi     5             ; display 4 digit year
              ?a#c    pq            ; century = 19?
              goc     DSDT20        ; no, display 4 digit year
              c=c-1   x             ; C.X= 4 to display 2 digit year
DSDT20:       s0=     1             ; doing a date
              s4=     1             ; formatting for display
              s5=     0             ; use CLK12/CLK24 bit for AM/PM
              gosub   DATEIN        ; date to display
              ?s2=1                 ; display day of week?
              gonc    DSDT70        ; no
              gosub   LEFTJ         ; left justify display
              c=0
              ldi     ' '
;;; * Could probably save code by putting this check for blanks in DSWEEK.
              a=c                   ; A.S=0, A.X=' '
              frsabc
              frsabc                ; there will always be 2 blanks
              frsabc
              ?a#c    x             ; is this character used?
              goc     DSDT45        ; yes
              a=a+1   s             ; 3 characters available
              frsabc                ; look at next character
              ?a#c    x             ; next character used?
              gonc    DSDT50        ; no, it's a blank
DSDT45:       cstex
              s7=     1             ; add a colon
              cstex
DSDT50:       slsabc                ; restore the character
              gosub   ENCP00
              c=regn  8             ; C[13:8]= day number since 10/15/1582
              gosub   ENLCD
              pt=     7
              c=0     wpt
              b=a     s             ; save A.S in B.s
              gosub   WKDAYS
              abex    s             ; A.S= 0 (1) for 2 (3) characters
              gosub   DSWEEK
DSDT70:       golong  ENCP00

              .public TGLSHF
TGLSHF:       golong  TGLSHF2     ; moved to page 3


PUGA35:       gosub   SRHBUF
              goto    1$
              gosub   ENTMR
              c=0
              wralm
              rtn
1$:           golong  PUGA40

ENCP0J:       goto    DSDT70
              nop
              nop

              .public CHKLB
CHKLB:        golong  CHKLB2        ; moved to page 3

ALMSG:        s8=     1
              gosub   CLLCDE
              gosub   DSAMSG        ; display it
              nop                   ; (P+1) no message
              golong  ACTM20        ; (P+2)

              nop


;;; **********************************************************************
;;; *                                                         4-2-81 RSW
;;; * INITMR - initialize timer  (if it has just powered up)
;;; *   If the hardware power up status bit is set or the warm start
;;; *   constant in alarm B register is not correct then "INITMR"
;;; *   does the following:
;;; *     - clears & starts main clock
;;; *     - clears & stops stopwatch clock
;;; *     - disables alarms
;;; *     - clears scratch registers A & B
;;; *     - clears alarm status bits, power up status bit, and
;;; *       accurancy factor
;;; *     - stops interval timer
;;; *     - disables both test modes
;;; *     - sets alarm B register= 0 9999999999 000= warm start constant
;;; *
;;; * IN: warm start constant in alarm B register
;;; * ASSUME: nothing
;;; * OUT: timer chip enabled, RAM disabled, timer PT=B, hexmode
;;; *         (don't trust the hardware status set that is up)
;;; * USES: A, C, ST[7:0], timer PT, DADD, PFAD, +1 sub level, arith mode
;;; *       (no 41C PT)
;;; * Minimum execution time= 26 word times (including GSB and RTN)
;;; *
;;; *  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
;;; *
;;; * INITM1 - same as INITMR except expects timer chip enabled,
;;; *          RAM disabled and timer PT=A
;;; * USES: A, C, S0-S7, timer PT, arith mode
;;; *       (no DADD, no PFAD, no 41C PT, +0 sub levels)
;;; **********************************************************************

              .public INITMM, INITMR, INITM1
INITMM:       m=c
INITMR:       gosub   ENTMR         ; save a sub levelm PT=A
INITM0:       startc                ; start main clock
INITM1:       rdsts                 ; read hardware status
              st=c                  ; ST= hardware status
              pt=b
              rdalm                 ; alarm B= warm start constant
              a=c                   ; A= warm start constant
              c=0
              setdec
              c=c-1   m             ; C= 09999999999000
              sethex
              ?a#c                  ; warm start constant wrong?
              goc     INITM3        ; yes, initialize timer chip
              ?s5=1                 ; hardware power up bit set?
              rtn nc                ; no
INITM3:       wralm                 ; ALM B= 09999999999000
              c=0
              dswkup                ; disable test mode B
              stopc                 ; stop stopwatch clock
              dsalm                 ; disable clock B alarm
              wrtime                ; clear stopwatch clock
              wrscr                 ; clear scratch reg B
              wrsts                 ; clear accurancy factor
              pt=a                  ;
              dswkup                ; disable test mode A
              stpint                ; stop interval timer
              dsalm                 ; disable alarm A
              wrtime                ; clear main clock
              wrscr                 ; clear last time set
              wrsts                 ; clear all alarms
              pt=b
              rtn


;;; **********************************************************************
;;; **********************************************************************
;;; *                     Calendar routines
;;; *
;;; *
;;; * Let MONTH = month number (1, 2, ..., 12)
;;; * Let DAY   = day number in month (1, 2, 3, ..., 31)
;;; * Let YEAR  = year number (1582, 1583, ..., 4320)
;;; * Let DAY#  = day number since October 15, 1582  [Oct 15, 1582 = day 0]
;;; *
;;; * Now define the following conditionally depending on the value
;;; * of MONTH:
;;; *   If MONTH  < 3 then let M = MONTH + 13 and let Y = YEAR - 1.
;;; *   If Month >= 3 then let M = MONTH + 1  and let Y = YEAR.
;;; *
;;; * Also define the following functions:
;;; *   SUM3(Y) = int(Y * 365.25) - int(Y/100) + int(Y/400).
;;; *   M306(M) = int (M * 30.6001)
;;; *
;;; *
;;; * Mapping DATE to DAY#
;;; *   DAY#(MONTH,DAY,YEAR) = SUM3(Y) + M306(M) + DAY - 578164
;;; *
;;; *
;;; * Mapping DAY# to DATE :
;;; *   Calculate the value of Y0 as follows:
;;; *     Y0 = int( [(DAY# + 578164) - 121.5] / 365.2425)
;;; *     This is an approximation of the correct year.
;;; *   Now calculate M0 as follows:
;;; *     M0 = int( [(DAY# + 578164) - SUM3(Y0)] / 30.6001)
;;; *   If this M0 is less than 4 then Y0 was one too high therefore
;;; *      let Y0 = Y0 - 1 and recalculate M0 using the new Y0.
;;; *   Once M0 >= 4, the values of MONTH, DAY and YEAR are:
;;; *     DAY = [(DAY# + 578164) - SUM3(Y0)] - M306(M0)
;;; *     If M0 >= 14 then MONTH = M0 - 13 and YEAR = Y0 + 1
;;; *     If M0 <  14 then MONTH = M0 - 1 and YEAR = Y0
;;; **********************************************************************
;;; **********************************************************************
;;; * C-YMDD - C register input -- year, month, day to day#   1-23-81 RSW
;;; *
;;; * IN: C= floating point date (MUST be valid floating point number!!)
;;; *        The legal date range is Oct 15, 1582 ti Sept 10, 4320.
;;; *        Dates outside this range, month= 0 or 13-99, and illegal day
;;; *        will be detected.
;;; * ASSUME: nothing
;;; * OUT: R8[13:8]= day number since Oct 15, 1582= DDDDDD........
;;; *          (not true for error case)
;;; *      A= floating point date   ( M.DY or D.MY )
;;; *        !!! This date must be compared to the input date. If they are
;;; *            not identical floating point numbers (except for sign)
;;; *            the input date is not valid (so R8[13:8] is trash)
;;; *      chip 0 enabled   (in all cases)
;;; *      hexmode          (if no error occurred)
;;; * USES: A, B, C, N, R8[13:6], active PT, +1 sub level, arith mode
;;; *       PFAD, DADD
;;; *       (no ST, no timer chip access)
;;; *
;;; **********************************************************************

              .public `C-YMDD`
`C-YMDD`:     gosub   UNNOR1        ; unnormalize the date
              goto    DAYS20        ; (P+1)
              goto    ENCP0J        ; (P+2) error
;;; * Note: Now A.X= 1 which is different from the input date, so the
;;; *       date comparison after "gosub `C-YMDD`" will catch the error.
DAYS20:       gosub   `SWPM&D`      ; swap month & day if flag 31= 0
              setdec                ;  (now have DMY)
              a=0
              rcr     2             ; C= 0 00DDMMYYYY 000
;;; * PT= 6 from SWPM&D ........
              acex    wpt           ; A= 0000000YYYY00, C= 000DDMM0000000
              rcr     6             ; C= 0 00000000DD MM0
              csr     x
              acex    x             ; A.X= 0MM, C.X= 0
              n=c                   ; N= 0 00000000DD 000
              a=a+1   x             ; M= M+1
              ldi     4
              ?a<c    x             ; M < 4?
              gonc    YMDD40        ; no
              ldi     0x12
              a=a+c   x             ; month + 12 (get "MONTH + 13)
              a=a-1   m             ; YEAR - 1
YMDD40:       b=a     m             ; B.M= 000000YYYY
              c=0
              acex    x             ; C.X= 0MM, A.X= 000
              rcr     11            ; C= 0 00000000MM 000
              gosub   M306
              a=c                   ; A= M*30.6
              c=n                   ; C= 0 00000000DD 000
              c=a+c   m             ; C.M= DAY + int(M * 30.6)
              c=-c    m
              n=c                   ; N.M= -(DAY + M306.M)
              c=b     m             ; C.M= 000000YYYY
              gosub   SUM3D5
              c=-c    m             ; C.M= -( -(DAY + M306) + 578164 - SUM3)
                                    ;  = SUM3(Y) + M306(M) + DAY - 578164
              rcr     9             ; C= DDDDDDXXXX0000
;;; * Note: For dates beyond Sept 10, 4320  (DAY#= 999999) the DAY# will be
;;; *       7 digits. The seventh digit will now be in C[0] where it will
;;; * be truncated so the reconstructed date will not match the input date.

              goto    DAYYMD

;;; **********************************************************************
;;; * DAYMDF - save as DAYYMD except:
;;; *  IN: A= DDDDDD........= day number since 1/1/1900
;;; *
              .public DAYMDF
DAYMDF:       gosub   `115860`      ; C= 11586000000000
              setdec
              c=a+c                 ; add 115860 to day number

;;; **********************************************************************
;;; * DAYYMD - day number to year, month, day                 1-22-81 RSW
;;; *  Calculates the date from the day number.
;;; *
;;; * IN: decmode
;;; *     C= DDDDDD........= day number since 10-15-1582
;;; *        where 10-15-1582 = 000000, 9-10-4320 = 999999
;;; * ASSUME: nothing
;;; * OUT: A= C= positive floating point date (M.DY or D.MY).
;;; *      R8= DDDDDD........= copy of "C" on input
;;; *      hexmode, chip 0 enabled
;;; * USES: A, B, C, N, R8[13:6], active PT, +1 sub level, arith mode,
;;; *       PFAD, DADD
;;; *       (no ST, not timer chip access)
;;; *
;;; *
;;; * DAYMD - same as DAYYMD except:  INPUT= A= DDDDDD........
;;; *
;;; **********************************************************************

              .public DAYMD
DAYYMD:       a=c
DAYMD:        gosub   ENCP00
              c=regn  8
              pt=     7
              a=c     wpt
              acex                  ; C= DDDDDD........
              regn=c  8             ; save day# in R8
              c=0     wpt
              rcr     4             ; C= 0 000DDDDDD0 000
              a=c                   ; A= 0 000DDDDDD0 000
              c=0
              pt=     9             ; "A+C" may carry to digit 10
              lc      5
              lc      7
              lc      8             ; C= 0 0005780425 000
              lc      0
              lc      4
              lc      2
              lc      5             ; (578164-1215) * 10
              a=a+c                 ; [max= 0 0015780415 000]
              pt=     9
              lc      3
              lc      6
              lc      5
              lc      2             ; C[9:3]= 365.2425
              pt=     10
;;; * Because the MSD of the dividend (digit 11) is at most = 1, the MSD of
;;; * the divisor is positioned at digit 10.
              gosub   IDVD4         ; Y0= int[(D#+578164-121.5)/365.2425]
;;; * The MSD of the quotient is in digit 11 due to the special positioning
;;; * of the divisor and the small MSD (MSD <= 1) of the dividend.
              acex                  ; C= 0 0YYYY00000 000
              rcr     5
              a=c                   ; A= 0 000000YYYY 000 = Y0
DAYY20:       c=regn  8
              pt=     7
              c=0     wpt           ; C= DDDDDD00000000
              rcr     5
              n=c                   ; N= DAY#= 0 0000DDDDDD 000
              acex    m             ; C.M= 000000YYYY
              gosub   SUM3D5        ; C= 0 0000000RRR 000 (R= result)
              n=c                   ; N.M= DAY# + 578164 - SUM3(Y0)
              rcr     11            ; mvoe over for "IDVD" by 30.6001
              a=c                   ; A.M= DAY# + 578164 - SUM3(Y0)
              c=0
              pt=     8
              lc      3
              lc      0
              lc      6
              c=c+1   m             ; C.M= 0000306001
              pt=     9
              gosub   IDVD          ; divide by 30.6
              c=0                   ; A= 0 00MM000000 000
              pt=     9
              lc      4
              ?a<c                  ; MONTH < 4?
              gonc    DAYY40        ; no
              c=b                   ; C= R 000000YYYY RRR
              c=c-1   m             ; Y = Y - 1
              a=c     m             ; A= 0 000000YYYY 000
              goto    DAYY20
;;; * IN: N.M= DAY# + 578164 - SUM3(Y0)
;;; *     B.M= 000000YYYY
DAYY40:       acex                  ; C= 0 00MM000000 000
              rcr     9
              a=c     x             ; A.X= 0MM
              c=n
              acex    x
              n=c                   ; save M0 in N.X
              c=0     m             ; C= 0 0000000000 0MM
              gosub   M306
              rcr     11            ; C.M= int[M * 30.6]
              ldi     0x12
              a=c                   ; A.M= int[M * 30.6], A.X= 12
              c=n                   ; C.M= DAY# + 578164 - SUM3(Y0)
                                    ; C.X= 0MM
              acex    m
              c=a-c   m             ; C.M= DAY= 00000000DD
              abex    m             ; A.M= Y0= 000000YYYY
              c=c-1   x             ; M0 - 1
              ?a<c    x             ; 12 < M0 - 1  (M0 >= 14?)
              gonc    DAYY60        ; no
              a=a+1   m             ; YEAR = Y0 + 1
              acex    x             ; C.X= 012, A.X= M0 - 1
              c=a-c   x             ; MONTH= M0-1-12= M0-13
DAYY60:       rcr     13            ; C= 0 0000000DD0 MM0
              csr     m
              rcr     8
              pt=     6
              acex    wpt           ; C= 0 00DDMMYYYY ...
              rcr     12
              a=c                   ; A= 0 DDMMYYYY.. .00
              gosub   `SWPM&D`      ; swap month & day if flag.31 = 0
              golong  NORM          ; normalize


;;; **********************************************************************
;;; * CORRECT - correct time & accurancy factor               2-3-81 RSW
;;; **********************************************************************

              .name   "CORRECT"
              .public CORRECT
CORRECT:      s9=     1             ;  adjust accurancy factor
              goto    XTIM00

;;; **********************************************************************
;;; * SETIME                                                  2-3-81 RSW
;;; **********************************************************************

              .name   "SETIME"
              .public SETIME
SETIME:       s9=     0             ; don't change accurancy factor
XTIM00:       c=0                   ; no date entered
              gosub   CHKXM         ; error if X= alpha data
              n=c                   ; N= H.MS normalized time
              gosub   `R9=T`        ; C= R9= time
              gosub   `C=T+D`
              rcr     1             ; add 0.1 sec to compensate for
              c=c+1                 ; key assignment search time
              rcr     13
              goto    TE10

;;; **********************************************************************
;;; * SETDATE                                                 2-3-81 RSW
;;; **********************************************************************

              .name   "SETDATE"
              .public SDATE
SDATE:        c=0
              c=c-1   s
              n=c                   ; N.S= F to use current time
              gosub   CHECKX        ; error if X= alpha data
              c#0?                  ; is x=0?
              golnc   ERRDE         ; yes, not a valid date
              m=c                   ; M= M.DY (D.MY) date
              gosub   `R9=T`        ; C= reg 9 = time
              s9=     0             ; don't change accurancy factor
              s0=     0             ; use X for date compare
              gosub   `C=T+D`
TE10:         n=c                   ; N= new entered time
              gosub   `T=T+TP`      ; store it
              rdscr                 ; read "last time set"
              a=c                   ; A= last time set
              c=n                   ; C= new entered time
              wrscr                 ; update "last time set"
              ?s9=1                 ; adjust accurancy factor?
              gonc    ADJ100        ; no, beep if we have past due alarms

;;; * IN: New entered time= 00SSSSSSSSSSCC
;;; *     reg 9= incorrect (clock) time= old time= 00SSSSSSSSSSCC
;;; *     A=     old "last time set"= LTS= 00SSSSSSSSSSCC
;;; *     decmode

              gosub   ENCP00
              c=regn  9             ; C= incorrect (CLK) time= old time
              acex                  ; C= LTS, so C.S= 0, A= old time
              a=a-c                 ; A= old time - LTS= OLD - LTS
              ldi     0x10          ; maximum exponent = 10 (units= sec)
              gosub   MPY150        ; normalize to 13 digit form
              c=regn  9             ; C= old time
              acex                  ; A= old time, C=exp&sign
              regn=c  9             ; reg 9= exp & sign (OLD-LTS)
              c=b
              cnex                  ; C= new time  set= LTS
                                    ; N= 13 digit mantissa (OLD-LTS)
              acex                  ; A= NEW, C= OLD
              pt=     12
              c=a-c                 ; C= NEW - OLD
              gonc    ADJ20         ; (if carry, C.S= 9)
              c=-c    wpt           ; clock fast, OLD > NEW
ADJ20:        a=c     wpt           ; A= 13 digit mantissa
              ldi     0x10          ; maximum exponent = 10
              gosub   MPY150
              c=regn  9             ; C=exp & sign (OLD-LTS)
              m=c                   ; M= exp & sign (OLD-LTS)
              c=n                   ; C= 13 digit mantissa (OLD-LTS)
              gosub   DV2_13        ; (NEW-OLD)/(OLD-LTS)
;;; * No overflow/underflow possible
;;; *   Max "NEW-OLD"= 24 HR= 86400 sec
;;; *   Min "OLD-LTS"= 0.01 sec
;;; * Therefore max (NEW-OLD)/(OLD-LTS) = 8640000
;;; *
;;; *   Min "NEW-OLD"= 0.01 sec
;;; *   Max "OLD-LTS"= 1 E11
;;; * Therefore min (NEW-OLD)/(OLD-LTS) = 1 E-13
;;; * Assume that the "old time" cannot equal the "last set time"
              c=0
              ldi     4
              m=c                   ; M= 0...004= exp & sign for 10240
              c=c+1   m
              ldi     0x24          ; C= 0 0000000001 024
              rcr     5             ; C&M= 10240 in 13 digit form
              gosub   MP2_13        ; (NEW-OLD)10240/(OLD-LTS)
;;; * No underflow should be possible since max= (9 E6)(10240) = 0 E11
;;; * Minimum = 1 E-9
              n=c                   ; N= (NEW-OLD)10240/(OLD-LTS)
              gosub   GETAF         ; C= floating point accurancy factor
              setdec
              c#0?                  ; existing AF = 0?
              goc     ADJ40         ; no, 1/X will work
              clrabc                ; A= B= C= 0
              goto    ADJ42
ADJ40:        gosub   ONE_BY_X10
;;; * No underflow/overflow since AF= 0.1 to 99.9
ADJ42:        c=n                   ; C=10240(NEW-OLD)/(OLD_LTS)
                                    ; = 1/(new accurancy factor)
              gosub   AD1_10        ; add the corrections
;;; * No overflow:  Max= 9 E11
;;; * No underflow: Min( 1/OAF )= 0.01 so minimum difference = 1 E-15
              c#0?                  ; result = 0?
              gsubc   ONE_BY_X13    ; no, invert to get resultant AF
              gosub   SETAF0        ; format, round & store AF

;;; * ADJ100 -- sets the new hardware alarm, and beeps if there are any
;;; *           past due alarms
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: hexmode, P selected, Q= 13
;;; *      peripherals disabled (except timer chip)
;;; * USES: A, B.X, C, M.X, P, Q, S8, +3 sub levels, DADD, PFAD, arith mode,
;;; *       timer PT
;;; *
              .public ADJ100
ADJ100:       clr  st
              gosub   NXTALM        ; set new hardware alarm
              gosub   SRHBUF        ; search for alarm stack
              goto    ADJ110        ; (P+1) alarm stack found
              rtn                   ; (P+2) no alarms

;;; *                                                         3-4-81 RSW
;;; * ADJ110 -- beeps if there are any past due alarms
;;; *
;;; * IN: A.X= address of first reg in timer buffer
;;; * ASSUME: hexmode, P selected, Q= 13
;;; * OUT: timer PT=A
;;; *      peripherals disabled (except timer chip)
;;; * USES: A, B.X, C, active PT, S8, +2 sub levels, DADD, PFAD, timer PT
;;; *         (no timer ST)

ADJ110:       gosub   CHKALM        ; check for past due alarms
              pt=     1
              ?b#0    wpt           ; any undisplayed past due alarms?
              golnc   BEEP2         ; yes, beep twice
              rtn


;;; **********************************************************************
;;; * TO24H - convert to 24 hour format                       1-26-81 RSW
;;; *  Converts from 12 or 24 hour user input format to 24 hour form.
;;; *  Exits with "A" rotated so that the hour is in A.X
;;; *
;;; * IN: A= #HHMMSSCC.....  where "#"= 0 for AM or 24 hour input
;;; *                                 = non-zero for PM
;;; *                          and "."= don't care
;;; * ASSUME: nothing
;;; * OUT: A= MMSSCC.....0HH   with HH in 24 hour form
;;; *      decmode, C.X= 012
;;; *      PT= 1
;;; * USES: input A[13:11]= output A.X, C, active PT, arith mode
;;; *         (no ST, +0 sub levels, no DADD, no PFAD)
;;; *
;;; **********************************************************************

              .public TO24H
TO24H:        acex                  ; C= #HHMMSSCC......
              rcr     11
              a=c                   ; A= MMSSCC......#HH
              setdec
              pt=     1
              ldi     0x12
              ?a<c    wpt           ; hour < 12?
              gonc    T24H20        ; no
              ?a#0    wpt           ; hour = 1-11?
              gonc    T24H20        ; no, hour = 00
              ?a#0    xs            ; PM?
              gonc    T24H20        ; no, AM
              a=a+c   wpt           ; add 12 hours
T24H20:       a=0     xs
              rtn


;;; **********************************************************************
;;; * C=T+D0 - C= time + date                                 1-29-81 RSW
;;; *  Combines time & date to get a point on the time line. The input
;;; *  date can be 0 to use current date. If a date is specified, then
;;; *  so must indicate whether it is from X or Y (for error checking).
;;; *
;;; * IN: N = H.MS normalized floating point time
;;; *           (N.S= F  to use current time)
;;; *     M = M.DY (D.MY)  normalized floating point date
;;; *           (M= 0 to use current date)
;;; *          if a date is given (M non-zero) then:
;;; *            S0= 1 (0)  to take comparison date from "Y" ("X")
;;; *     C= clock time
;;; *     if a date is given (M non-zero) then:
;;; *        S0= 1 (0) take comparison date from "Y" ("X")
;;; * ASSUME: S1= 1 (0)  do (not) add "X" or "Y" to "DATA ERROR"
;;; * OUTPUT: C= 100th's of seconds since 1/1/1900= 00SSSSSSSSSSCC
;;; *              where "S"= seconds,  "C"= centiseconds
;;; *              and C[13:12]= 00  fir dates from 1/1/1900 to 12/31/2199
;;; *         decmode, Q= 13, P selected
;;; *    !!!! Does not return if there is an error in time or date !!!!!!
;;; *
;;; * USES: A, B, C, M, N, R8[13:6], S8, P, Q, +2 sub levels, arith mode
;;; *       (if a date is given, meaning M#0, then also:  DADD, PFAD)
;;; *           (no timer chip access)
;;; *
;;; **********************************************************************

              .public `C=T+D`, `C=T+D0`
`C=T+D`:      s1=     0             ; don't add X or Y to "DATA ERROR"
`C=T+D0`:     sel q
              pt=     13
              sel p
              gosub   SDHMSC        ; A= day, hr, min, sec
              b=a                   ; B= DDDDDDHHMMSSCC
              c=n                   ; C= H.MS time
              c=c+1   s             ; any entry in time?
              goc     STMN25        ; no, use clock time
              c=c-1   s             ; restore "C"
              gosub   UNNOR1        ; unnormalize the time
              goto    STMN23        ; (P+1) OK, A= #HHMMSSCC.....
              goto    STMN27        ; (P+2) X register error
STMN23:       gosub   TO24H         ; convert hours ti 24 hour form
                                    ; A= MMSSCC.....0HH, PT=1, C.X= 012
                                    ; decmode
              c=c+c   wpt           ; C[1:0]= 24
              ?a<c    wpt           ; hour < 24?
              gonc    STMN27        ; no, error
              acex
              rcr     8
              a=c                   ; A= .....0HHMMSSCC
STMN25:       pt=     8
              a=0     pq            ; A= 000000HHMMSSCC
              gosub   HMSS40        ; C= 00SSSSSSSSSSCC
              goto    STMN30        ; (P+1) valid time
STMN27:       s0=     0             ; (P+2) X register error
                                    ; assume no error possible when using
              goto    STMNER        ;  current time
STMN30:       cmex                  ; M= time= 00SSSSSSSSSSCC
                                    ; C= M.DY (D.MY) date
              c#0?                  ; any entry in date?
              goc     STMN40        ; yes
              pt=     8             ; no, use current date
              c=b     pq            ; C= DDDDDD00000000
              goto    STMN60        ; C= day number since 1/1/1900
STMN40:       gosub   `C-YMDD`      ; A= positive norm floating point date
              gosub   DATECK        ; C= DAY#= DDDDDD00000000
              bcex                  ; B= DAY# since Oct 15, 1582
              gosub   UNNOR2        ; unnormalize the date
;;; *  !!!! assume no error possible   (P+1) (P+2)
              c=0
              pt=     8
              lc      1
              lc      9             ; C= 0 0000190000 000
              pt=     8
              ?a<c    wpt           ; year < 1900?
              gonc    STMN55        ; no, OK
STMNER:       golong  TERROR        ; IN: S1= 1 (0)  do (not) add X or Y
                                    ;   if S1= 1 then:
                                    ;       S0= 1 (0) add Y (X) to
                                    ;                 "DATA ERROR"
                                    ; ASSUME: nothing
STMN55:       lc      2
              lc      2
              pt=     8
              ?a<c    wpt           ; year < 2200?
              gonc    STMNER        ; no, error
              abex                  ; A= DDDDDD00000000, B=date
              gosub   `115860`      ; C= 115860000000
              c=a-c                 ; subtract 115860 days= day# since 1/1/1900

STMN60:       a=c                   ; A= DDDDDD00000000
              gosub   X20Q8         ; A= days * 20, C= days * 40
              csr                   ; C= days * 4
              a=a+c                 ; A= days * 24= hours= 0HHHHHHH000000
              gosub   `HM-SC`       ; convert HMS to sec & 100ths
              setdec
              c=m                   ; C= time= 00SSSSSSSSSSCC
              c=a+c                 ; C= time + date= 00SSSSSSSSSSCC
              rtn


;;; **********************************************************************
;;; *                                                         1-12-81 RSW
;;; * HMSSEC - hours, minutes, seconds to seconds
;;; *  Converts a floating point normalized H.MS number to 100th's of
;;; *  seconds.
;;; *
;;; *                             (10 to keyboard check inc GSB)
;;; *                             (47 max to exit after key transition)
;;; *     Errors (return to P+2) if:
;;; *             hour > 99
;;; *             minutes or seconds > 59
;;; *
;;; * IN: A= floating point normalized H.MS time < 100 hours
;;; *        (with valid exponent, BCD digits)
;;; * ASSUME: S8= 1 (0)  to check (ignore) keyboard
;;; *             if S8 = 1, then:  S9 = 1 (0)   return on key up (down)
;;; * OUT: if S8=1 & S9=0, jumps directly to "TMRKEY" on key down (garbage out)
;;; *      if return to P+1   --  (normal case)
;;; *         if S8=1 and key up is detected, output= garbage !!!
;;; *         otherwise:
;;; *           A= C= 00SSSSSSSSSSCC   ( CC= centiseconds )
;;; *           P selected, Q= 13, hexmode
;;; *      if return to P+2   --  (error case)
;;; *           hexmode
;;; *
;;; * USES: A,C, P, Q, +1 sub level, arith mode
;;; *       (no ST, no DADD, no PFAD, no timer chip access)
;;; *
;;; * HMSSCB - same as HMSSEC except saves the sign of the number in B.S
;;; * HMSEC1 - same as HMSSEC except allows hour <= 9999, and sets S8=0a
;;; *             so it uses S8 !!!!
;;; * HMSS20 - same as HMSSEC except:
;;; *           IN: A= unnormalized HMS number (output to "UNNOR2")
;;; *               PT= 12
;;; *
;;; **********************************************************************

              .public HMSSCB, HMSSEC, HMSS20, HMSEC1
HMSSCB:       b=a     s
HMSSEC:       gosub   KEYCHK        ; check keyboard if S8= 1
              gosub   UNNOR2        ; allow hour < 100
              goto    HMSS10        ; (P+1) A= #HHMMSSCC.....
              goto    HMSTER        ; (P+2) error, hour > 99
HMSS10:       gosub   KEYCHK        ; check keyboard if S8= 1
HMSS20:       asr     wpt
              asr     wpt
              goto    HMSS35

HMSEC1:       ldi     3             ; allow hour < 10000
              s8=     0             ; ignore keyboard
              gosub   UNNORM        ; unnormalize
              goto    HMSS35        ; (P+1) OK
HMSTER:       golong  `RTNP+2`
HMSS35:       asr     wpt
              asr     wpt
              asr     wpt
              a=0     s             ; A= 0000HHHHMMSSCC
              gosub   KEYCHK        ; check keyboard if S8= 1

;;; *                                                         1-12-81 RSW
;;; * HMSS40 -- converts HMS number to 100th's of seconds
;;; *            errors (return to P+2) if minutes or seconds > 59
;;; *
;;; * IN: A= 0000HHHHMMSSCC  (could have 6 digits of hours, maybe more)
;;; * ASSUME: nothing
;;; * OUT:  same as HMSSEC
;;; * USES: same as HMSSEC

              .public HMSS40        ; (40 max inc rtn [not gsb])
HMSS40:       setdec
              c=0
              pt=     5
              lc      6             ; C= 00000000600000
              pt=     5
              ?a<c    wpt           ; minutes < 60?
              gonc    HMSTER        ; no, error
              pt=     3
              rcr     2             ; C= 00000000006000
              ?a<c    wpt           ; seconds < 60?
              gonc    HMSTER        ; no, error

;;; *                                                         1-12-81 RSW
;;; * HM-SC = hours & minutes to seconds
;;; *
;;; * IN: decmode, A= 00HHHHHHMMSSCC  with minuts & secodns < 60
;;; * ASSUME: nothing
;;; * OUT: hexmode, P selected, Q= 13
;;; *      A= C= 00SSSSSSSSSSCC   (CC = centiseconds)
;;; *        (only returns to P+1,  no error check !!!)
;;; * USES: same as HMSSEC
;;; *
              .public `HM-SC`       ; (29 max inc rtn, not gsb)
`HM-SC`:      sel p
              pt=     6             ; PT= least significant hours digit
              gosub   X20Q          ; Q=13, hours x 20
              a=a+c                 ; A= 00MMMMMMMMSSCC (HR x 60)
              pt=     4             ; PT= least significant minutes digit
              gosub   X20           ; minutes x 20
              c=a+c                 ; A= 00SSSSSSSSSSCC  (min x 60)
              a=c
              sethex
              rtn


;;; **********************************************************************
;;; * DIFF - difference                                       2-11-81 RSW
;;; *
;;; * Calculates the difference between M[11:9] split and the previous
;;; * split and exits with it ready for display by "DSPTMR".
;;; *   (if M[11:9]= reg 0, then diff outputs the input split)
;;; *   (if the difference is invalid on the "enter" key path, diff
;;; *    outputs the input split)
;;; *
;;; * To calculate a diff, it converts negative splits to 10's complement
;;; * SSSSSSSSSSSSCC form, does the subtract, and converts back to HMS.
;;; *
;;; * IN: C= most recent split  ( H.MS floating point normalized number)
;;; *     M.X= reg 0 address
;;; *     M[11:9]= address of most recent split
;;; *              (!! this reg must exist, or may get a memory lost !!!)
;;; *     B.S= sign of the most recent split
;;; * ASSUMES: peripherals disabled
;;; *          S8= 1 (0)   to check (ignore) keyboard
;;; *              if S8= 1, then: S9= 1 (0)  return on key up (down)
;;; * OUT:  if S8=1 & S9=0 and a key goes down, jumps directly
;;; *                                           to "TMRKEY"!!!
;;; *       if return to (P+1):    [normal case]
;;; *         if S8= 1 and key up occurs, output= garbage !!!!
;;; *         if S8= 0 or no key transition:
;;; *           A= C= signed normalized floating point time  (may be a split)
;;; *           B= unnormalized time= #HHMMSSCC.....         (may be a split)
;;; *           hexmode, P selected
;;; *       if return to (P+2):   [current split not valid, or diff >= 100 HR]
;;; *          hexmode
;;; * USES: A, B, C, P, Q, +2 sub levels, DADD, arith mode
;;; *       (no ST, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public DIFF
DIFF:         a=c
              gosub   HMSSCB        ; C= SSSSSSSSSSSSCC
              goto    DIFF20        ; (P+1)
DIFFEX:       goto    HMSTER        ; (P+2) error
DIFF20:       gosub   KEYCHK        ; check keyboard if S8= 1
              c=b     s             ; restore the sign
              n=c                   ; N= uncoded timer time
              c=m                   ; C.X= reg 0 address
              a=c     x
              rcr     9             ; C.X= active reg address
              ?a#c    x             ; OK to use next lower reg?
              goc     DIFF30        ; yes
DIFF25:       c=n                   ; no, show split, not difference
              a=c
              goto    DIFF65
DIFF30:       c=c-1   x
              dadd=c
;;; * !!!! if this register doesn't exist, may get a "MEMORY LOST"
              gosub   P6RTN
              c=b
              gosub   KEYCHK        ; check keyboard if S8= 1
              ?c#0    s             ; negative or alpha?
              gonc    DIFF35        ; no, positive number
              setdec
              c=c+1   s             ; negative number?
              gonc    DIFF38        ; no, alpha data
DIFF35:       abex                  ; A= H.MS time of previous split
              gosub   HMSSEC        ; A= SSSSSSSSSSSSCC
              goto    DIFF40        ; (P+1)
DIFF38:       ?s9=1                 ; (P+2) enter key path?
              goc     DIFF25        ; yes, display split because the diff is
                                    ;      not valid
              goto    DIFFEX        ; error
DIFF40:       gosub   KEYCHK        ; check keyboard if S8= 1
              c=b     s             ; previous split
              setdec
              pt=     12
              ?c#0    s             ; negative?
              gonc    DIFF50        ; no
              c=-c    wpt           ; yes, make it 10's complement
DIFF50:       a=c                   ; A= previous split
              c=n                   ; C= most recent split
              ?c#0    s             ; negative?
              gonc    DIFF60        ; no
              c=-c    wpt           ; make it 10's complement
DIFF60:       acex                  ; A= current, C= previous split
              a=a-c                 ; diff= current - previous
              ?a#0    s             ; negative result?
              goc     DIFF38        ; yes, bad data
DIFF65:       b=a     s
              golong  GTMR30


;;; **********************************************************************
;;; * RSTKBT -- timer reset keyboard                          2-24-81 RSW
;;; *
;;; * IN & ASSUME: hexmode
;;; * USES: C.X only

              .public RSTKBT
RSTKBT:       ldi     122
1$:           c=c-1   x             ; do 40 msec down debounce
              gonc    1$
              golong  RSTKB


;;; **********************************************************************
;;; *                                                         1-5-81 RSW
;;; * CALCRA - calculate new active (STO/RCL) register address
;;; *
;;; * Fetches the register number from "M" and computes the new active
;;; * register address.
;;; *
;;; * IN: M.X= reg 0 address  M[5:3]= STO register number (BCD)
;;; *     M[8:6]= RCL register number
;;; * ASSUME: hexmode
;;; * OUT: M[11:9]= new active reg address
;;; * USES: A.X, C, M[11:9], +2 sub levels
;;; *       (no PT, no DADD, no PFAD, no timer chip access)
;;; *
;;; *
;;; * R-TO-S= RCL to STO:  same as CALCRA except sets to STO mode (S2=0)
;;; *                      so it uses S2 !!!!
;;; *
;;; * CALCRC - same as CALCRA except expects C= M register contents
;;; *

              .public `R-TO-S`, CALCRA, CALCRC
`R-TO-S`:     s2=     0             ; switch out of RCL
              s3=     0             ; don't suppress register number
CALCRA:       c=m
CALCRC:       gosub   `GETR#`       ; C.X= active reg number
              c=0     m             ; C[4:3]= 00 for "GOTINT"
              gosub   GOTINT        ; convert it to binary
              a=c     x             ; A.X= binary reg number
              c=m                   ; C.X= reg 0 address
              a=a+c   x             ; A.X= new active reg address
              rcr     9
              acex    x             ; C.X= new active register address
              rcr     5
              m=c
              rtn


;;; **********************************************************************
;;; *                                                         1-5-81 RSW
;;; * GETM.X - get register whose address is in M.X
;;; *
;;; * IN: M.X= register address
;;; * ASSUMES: peripherals disabled
;;; * OUT: C= register contents, that reg is enabled
;;; * USES: C, DADD,   (no PT, no ST,  +0 sub levels)
;;; *       (no arith mode, no PFAD)
;;; **********************************************************************

              .public GETMXP, `GETM.X`
GETMXP:       pt=     1
`GETM.X`:     c=m                   ; C.X= reg address
              dadd=c
              c=data
              rtn


;;; **********************************************************************
;;; *                   STOPWATCH                             2-24-81 RSW
;;; *
;;; *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
;;; *
;;; *           S7=  1 (0)   shift (not) set
;;; *           S6=  1 (0)   (not) entering register number
;;; *           S5           scratch  [suppress AM/PM in time display]
;;; *           S4=  1 (0)   (2)/3 digit reg number
;;; *           S3=  1 (0)   don't (do) display reg number
;;; *           S2=  1 (0)   RCL (STO) mode
;;; *           S0=  1 (0)   difference/(split) mode
;;; *
;;; * Pointers which are preserved throughout the stopwatch:
;;; *           M.X=     reg 0 address
;;; *           M[5:3]=  STO register number
;;; *           M[8:6]=  RCL register number
;;; *           M[11:9]= active (STO/RCL) register address
;;; *           M[12]=   current tenth of second

              .public SW, TM10, TM20, LB_556C
              .name   "SW"
SW:           c=regn  13
              rcr     3             ; C.X= reg 0 address
              bcex    x             ; B.X= reg 0 addr
              c=0
              c=b     x
              rcr     9
              c=b     x
              rcr     2
              bcex
              gosub   INITMR        ; initialize timer if necessary
              clr st
LB_556C:      rctime      ; read & start holding count
              a=c
              golong  LB_38F4

TM10:         gosub   `36000`       ; C= 00000036000000
;;; * Note: If the stopwatch time has been scrambled but neither the
;;; *       timer warm start constant not the hardware power up bit
;;; *       detected a problem, the keyboard could be locked out for
;;; *       up to 15 minutes here and on every access to the stopwatch
;;; * time.
              c=a+c
TM20:         wdtime                ; correct time exactly
;;; * Note: For times > 88 days, wdtime will write a time that is slightly
;;; *       in error. The error will be (1+N)/100 seconds where
;;; *         N= int([(hours since last use of SW) - 2100]/3000)
;;; *       This is an error of about (1/100 sec)/(3000 HR)(3600 SEC/HR)
;;; *       or about 0.001 PPM which should not be noticeable compared
;;; *       with the timebase error.

              pt=     1
              bcex    pt
              sethex
              c=b
              rcr     3
              m=c                   ; M.X= reg.0 address
                                    ; M5:3]= STO REG number
                                    ; M[8:6]- RCL reg number
                                    ; M[11:9]= active reg address= M.X
                                    ; M[12]= current tenth of second
              gosub   CLRALM        ; clear extraneous alarms
              .public TMR00, TMR01
TMR00:        gosub   RSTKB         ; clear keyboard
TMR01:        chk kb                ; another key down?
              golc    TMRKEY        ; yes
              s8=     1             ; check keyboard
              ?s2=1                 ; RCL mode?
              goc     TMR10         ; yes
              s9=     0             ; return on key down
              gosub   GETMR         ; B= unnormalized timer time
              chk kb                ; key down?
              goc     TMRCHK        ; yes
              sel q
              pt=     4             ; display tenths of seconds
              gosub   HWSTS         ; put up hardware status
              ?s7=1                 ; running?
              goc     TMR07         ; yes
              pt=     3             ; no, display 100th's
TMR07:        cstex                 ; restore timer status
              goto    TMR24

TMR10:        c=0     x
              pfad=c                ; disable peripherals (display)
              c=m
              rcr     9             ; C.X= RCL reg address
              gosub   CHKADR        ; error for invalid address
              s9=     0             ; return on key down
              c=b                   ; C= massaged reg contents
              chk kb                ; key down?
              goc     TMRCHK        ; yes
              ?c#0    s             ; negative or alpha?
              gonc    TMR12         ; no, positive number
              setdec
              c=c+1   s
              c=c-1   s             ; negative number?
              gonc    TMRDE         ; no, ALPHA DATA
TMR12:        ?s0=1                 ; in difference mode?
              gonc    TMR15         ; no, split mode
              gosub   DIFF          ; calculate difference
              goto    TMR18         ; (P+1)
              goto    TMRDE         ; (P+2) "DATA ERROR"
TMR15:        gosub   UNNOR1        ; unnormalize the split
              goto    TMR17         ; (P+1) legal size split
TMRDE:        s8=     0             ; (P+2) error, don't print
              sethex
              gosub   MSGA          ; put "DATA ERROR" in display
              xdef    MSGDE         ; "DATA ERROR"
              s8=     1             ; check keyboard
              gosub   ENLCD
              gosub   `REG#`
              goto    TMRCHK
TMR17:        b=a                   ; B= unnormalized split
TMR18:        chk kb                ; key down?
              goc     TMRCHK        ; yes
              sel q
              pt=     3             ; RCL mode, display 100th's
TMR24:        gosub   CHKLB         ; check low battery
              chk kb                ; key down?
              gsubnc  DSPTMR        ; no, display with R# if necessary
              sel p
              .public TMRCHK
TMRCHK:       chk kb                ; key down?
              goc     TMRKEY        ; yes
              sethex
              gosub   ENTMR
              alarm?
              gonc    TMR70         ; no
              rdsts                 ; C= hardware status
              pt=     0
              c=c+c   pt            ; timer counted through zero?
              gonc    TMR70         ; no
              gosub   BEEPK         ; beep
              chk kb                ; key down?
              gsubnc  BEEPKP        ; no, beep
              chk kb                ; did a key come down during the beep?
              goc     TMRKEY        ; yes, beep aborted, don't clear alarm
              gosub   ENTMR         ; enable timer chip, disable RAM, PT= A
              ldi     0x31          ; don't clear alarm until sure of
                                    ;  sounding 2 beeps
              wrsts                 ; clear DTZ B, DTZ A, ALM B
              golong  TMR01         ; update LCD to remove old tenths digit
TMR70:        pt=     1
              rdsts                 ; C= hardware status
              c=c+c   wpt           ; running?
              gonc    TMRCHK        ; no
              pt=b                  ; select stopwatch clock
              rdtime                ; C= stopwatch time
              a=c
              c=m
              rcr     11            ; C[1]= last tenth of second
              ?a#c    pt            ; time to update the display?
              gonc    TMRCHK        ; no
              chk kb                ; key down?
              goc     TMRKEY        ; yes
              c=a     pt
              rcr     3
              m=c                   ; M[12]= current tenth of second
              ?s2=1                 ; in RCL mode?
              goc     TMRCHK        ; yes, don't change display
              s8=     1             ; return on key down
              s9=     0
              acex                  ; C= timer time
              gosub   GETMRC        ; convert time to HMS
              chk kb                ; key down?
              goc     TMRKEY        ; yes
              gosub   CHKLB         ; check low battery
              sel q
              pt=     4             ; only display tenths
              gosub   DSPTMM        ; display timer time
              goto    TMRCHK

              .public TMRKEY
TMRKEY:       sethex
              c=0     x
              pfad=c                ; disable peripherals
              ldi     19
              gosub   `KEY-FC` ; branch to functions
;;; * execution time= 7(KEY) + 12  including GSB & RTN
              .con    0x87          ; R/S
              .con    0x13          ; ENTER
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
              .con    0x18          ; OFF key
              .con    0x82          ; RCL
              .con    0xc2          ; SST
              .con    0x12          ; SHIFT
              .con    0x83          ; EEX key
              .con    0xc3          ; back arrow
              .con    0x73          ; CHS
              .con    0
              goto    `TMR/S`       ; R/S
              goto    TMENT         ; ENTER
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              c=c+1   xs
              goto    ADENT         ; address entry
              goto    TMROFF        ; OFF
              goto    TMRCL         ; RCL
              goto    TMSST         ; SST
              goto    TMSHF         ; SHIFT
              goto    TMEEX         ; EEX
              goto    TMRBAK        ; back arrow
              goto    TMCHS
;;; ......................................................

              .public TMR00K
TMR00K:       ldi     110
1$:           c=c-1   x             ; wait for key down debounce
              gonc    1$            ;  (min of 40 milliseconds)
              golong  TMR00


;;; **********************************************************************
;;; * CLOCK                                                   6-30-81 RSW
;;; **********************************************************************

              .name   "CLOCK"
              .public CLOCK
CLOCK:        gosub   TMRSTS
              golong  CLOCK2

TMENT:        golong  TMRENT
`TMR/S`:      goto    `TMRR/S`
TMREX:        gosub   LB_3581       ; turn off shift annunciator
              .public TMEXIT, LB_563F
TMEXIT:       gosub   RSTKBT        ; clear keyboard
LB_563F:      gosub   ENCP00
              golong  CLDSP

ADENT:        golong  ADRENT
TMEEX:        golong  TMREEX
TMRCL:        golong  TMRRCL
              gosub   LB_3583       ; who uses this?
TMROFF:       gosub   TMRSTS
              gosub   CLRALS
              .public CLKOFF
CLKOFF:       sel p
TOFF:         golong  LB_333E

TMCHS:        goto    TMRCHS
TMSST:        goto    TMRSST

TMRBAK:       ?s7=1                 ; shift set?
              goc     TMREX         ; yes, exit "SW"
              ?s6=1                 ; entering address?
              gonc    TMBK20        ; no
              gosub   `GETR#M`      ; C.X= STO/RCL reg number
              a=c     x
              pt=     1
              a=a+1   pt            ; A[1]= digit?
              gonc    TMBK10        ; yes
              pt=     2             ; no, so A.XS= last digit
TMBK10:       c=0     pt            ; "F" out last digit
              c=c-1   pt
              gsubc   `PUTR#`       ; !!!! will always carry !!!!
TMR0KJ:       goto    TMR00K
TMSHF:        goto    TMRSHF
TMBK20:       gosub   ENTMR         ; enable timer chip, PT=A
              rdsts                 ; C= hardware status
              pt=     1
              ?s2=1                 ; RCL mode?
              goc     TMRC15        ; yes, switch to STO mode
              c=c+c   wpt           ; running? (?s7=1)
              goc     TMR0KJ        ; yes, ignore the key
              c=0                   ; not running
              pt=b
              wrtime                ; clear the stopwatch
              goto    TMR0KJ

;;; .............................................................

`TMRR/S`:     ?s6=1                 ; entering address?
              goc     TMR0KJ        ; yes, ignore key
              gosub   HWSTS         ; put up hardware status
              pt=b                  ; select timer/stopwatch clock
              ?s7=1                 ; running?
              gonc    TMRS20        ; no
              stopc                 ; yes, stop
              goto    TMRS30

TMRS20:       startc                ; start timer/stopwatch
TMRS30:       st=c                  ; restore status
              ?s2=1                 ; in RCL mode?
              gsubc   `R-TO-S`      ; yes, switch to STO mode
              goto    CLRSHF        ; be sure "SHIFT" is off

;;; .............................................................

TMRCHS:       ?s7=1                 ; shift set?
              goc     TMR0KJ        ; yes, ignore the key
              ?s0=1                 ; difference mode?
              goc     TMRCH3        ; yes
              s0=     1             ; no, go to difference mode
              goto    TMRC30
TMRCH3:       s0=     0             ; go to split mode
              goto    TMRC30

;;; .............................................................

TMRSST:       ?s6=1                 ; entering address?
              goc     TMR0KJ        ; yes, ignore the key
              ldi     50
              gosub   `GTR#MC`      ; C.X= reg number
              setdec
              ?s7=1                 ; shift set?
              goc     TMSST2        ; yes, do a BST
TMSST1:       a=a-1   x             ; wait 100 word times for
              gonc    TMSST1        ;  40 msec total down debounce
              golong  TENT35        ; do a SST
TMSST2:       c=c-1   x             ; do a BST
              gonc    TMSST4
              c=0     x             ; can't BST, at reg 0 already

TMSST4:       sethex
              gosub   `PUTR#`       ; update reg number
TMSST6:       gosub   CALCRC        ; calculate new active reg address
CLRSHF:       s7=     1

;;; Falls into TMRSHF to clear shift annunciator

;;; .............................................................

              .public TMRSHF
TMRSHF:       gosub   TGLSHF        ; toggle shift annunciator
              goto    TMRKJ1

;;; .............................................................

              .public TMRRCL
TMRRCL:       ?s7=1                 ; shift set?
              goc     TMRKJ1        ; yes, ignore the key
              ?s6=1                 ; entering address
              goc     TMRKJ1        ; yes, ignore the key
              ?s2=1                 ; in RCL mode?
              goc     TMRC15        ; yes
              s2=     1             ; no, switch to RCL mode
              goto    TMRC20

TMRC15:       s2=     0             ; switch to STO mode
TMRC20:       gosub   CALCRA        ; calculate new active reg address
TMRC30:       s3=     0             ; don't suppress reg number
              goto    TMRKJ1

;;; .............................................................

              .public TMREEX
TMREEX:       ?s6=1                 ; entering address?
              goc     TMRKJ1        ; yes, ignore the key
              ?s7=1                 ; shift set?
              goc     TMEE20        ; yes
              ?s3=1                 ; suppressing reg number?
              goc     TMRC30        ; yes
              s3=     1             ; suppress reg number
TMRKJ1:       golong  TMR00K
TMEE20:       s3=     0             ; don't suppress register number
              ?s4=1                 ; 3 digit reg number?
              goc     TMEE30        ; yes
              s4=     1             ; no, set to 3 digits
CLRSHJ:       goto    CLRSHF
TMEE30:       s4=     0             ; set to 2 digit reg number
              c=m
              pt=     5
              c=0     pt            ; 2 digit STO pointer
              pt=     8
              c=0     pt            ; 2 digit RCL pointer
              m=c
              goto    TMSST6

;;; .............................................................

              .public ADRENT
ADRENT:       gosub   `GTR#MC`      ; C.X= active reg number
              s3=     0             ; don't suppress register number
              ?s6=1                 ; already entering reg no.?
              goc     ADRE20        ; yes
              c=0     x             ; no, start new reg no.
              c=c-1   x             ; C.X= FFF
ADRE15:       acex    xs            ; C.X= DFF
              s6=     1             ; set reg number entry flag
              goto    ADRE50
;;; * Note: Backarrow may have cleared all the digits so the following
;;; *       test is needed.
ADRE20:       c=c+1   xs
              c=c-1   xs            ; has first digit been entered?
              goc     ADRE15        ; no, C.XS= F
              pt=     1
              asr     x             ; A.X= 0D0
              c=c+1   pt            ; has 2nd digit been entered?
              gonc    ADRE30        ; yes
              acex    pt            ; no, add it
              ?s4=1                 ; 3 digit reg number?
              goc     ADRE50        ; yes
              csr     x             ; no, 2 digits, C.X= 0DD
              goto    ADRE40
ADRE30:       c=c-1   pt            ; fix up the digit
              pt=     0
              asr     x             ; A.X= 00D
              acex    pt            ; add 3rd digit
ADRE40:       s6=     0             ; terminate address entry
ADRE50:       gosub   `PUTR#`
              ?s6=1                 ; still entering reg number?
              goc     CLRSHJ        ; yes
              gosub   CALCRC        ; no, calculate active reg address
              goto    TENT45        ; beep if the reg doesn't exist

;;; ..........................................................................
;;; * Want to read time 47 word times after detecting "ENTER" key since the
;;; * "R/S" key takes 47 word times to start/stop the stopwatch.
;;; *
;;; * Max dead time between "ENTER"s when in STO mode is 0.071 sec with
;;; * slowest 41C clock

              .public TMRENT
TMRENT:       ?s6=1                 ; entering address?
              goc     TMRKJ1        ; yes, ignore the key
              gosub   ENTMR
              pt=b
              rdtime                ; C= stopwatch time
              n=c                   ; save the time
              ?s2=1                 ; RCL mode?
              gsubc   `R-TO-S`      ; yes, set to STO mode
              c=m
              rcr     9             ; C.X= STO reg address
              gosub   CHKADR        ; error if it doesn't exist
              c=n                   ; C= current time
              s8=     0             ; ignore keyboard
              gosub   GETMRC        ; convert to H.MS
              c=m
              rcr     9             ; C.X= STO reg address
              dadd=c
              acex                  ; C= H.MS time
              data=c                ; store the split
              rst kb
              chk kb                ; key still down?
              gonc    TENT30        ; no
              s8=     1             ; yes, check keyboard
              s9=     1             ; return on key up
              ?s0=1                 ; in difference mode?
              gsubc   DIFF          ; yes, calculate the difference
                                    ;    if in difference mode
                                    ; (P+1)
                                    ; (P+2) assume no error can occur
              rst kb
              chk kb                ; key still down?
              gonc    TENT30        ; no, don't display
              sel q
              pt=     3             ; display 100th's
              gosub   DSPTMR        ; display split/difference
              c=0     x             ; disable peripherals for
              pfad=c                ; "key up" abort case
TENT30:       c=m
              rcr     3

;;; * IN: Peripherals disabled
;;; *     C= copy of M rotated so that C.X= active reg number
;;; *     !!!! Must not be entering the register number !!!!

              .public TENT35
TENT35:       setdec
              c=c+1   x             ; increment reg number
              sethex
              ?c#0    xs            ; reg number > 99 ?
              gonc    TENT40        ; no
              s4=     1             ; yes, set to 3 digits
TENT40:       gosub   `PUTR#`
              rcr     9
              c=c+1   x             ; increment active reg address
              rcr     5
              m=c                   ; store incremented address
TENT45:       ?s7=1                 ; shift set?
              gsubc   TGLSHF        ; yes, turn it off
              gosub   RSTKB         ; wait for key up
              c=m
              rcr     9
              c=c+1   x             ; increment address again
              a=0     xs
              a=a+1   xs
              ?a<c    xs            ; reg address > 511 ?
              goc     TENT60        ; yes, invalid address
              dadd=c
              c=data                ; check existance of next reg
              acex                  ; save in A
              c=m                   ; use M as data pattern
              data=c
              c=data
              acex                  ; C= original reg contents
                                    ; A= date read back
              data=c                ; restore original reg contents
              c=m
TENT60:       a#c?                  ; does the next reg exist?
              gsubc   BEEPK         ; no, sound warning beep
              golong  TMR01


;;; **********************************************************************
;;; * KEYCHK - key check                                      2-6-81 RSW
;;; *  This routine is intended to try to give 1/100 sec accuracy to the
;;; *  stopwatch by aborting non-essential routines when a key transition
;;; *  is detected.
;;; *
;;; * IN & ASSUME: S8= 1 (0)  to check (ignore) keyboard
;;; *        if S8=1, then: S9= 1 (0)  return on key up (down)
;;; * OUT: if S8=1 & S9=0 and a key goes down, jumps directly to "TMRKEY"
;;; *      if S8=1 & S9=1 and the key goes up, pops stack and returns
;;; *      if S8=0 or no key transitions, returns normally
;;; * USES: nothing  (except popping a level off return stack)
;;; **********************************************************************

              .public KEYCHK
KEYCHK:       ?s8=1                 ; check keyboard?
              rtn nc                ; no
              ?s9=1                 ; return on key up?
              gonc    KEYCK4        ; no, key down
              rst kb
              chk kb                ; key still down?
              rtn c                 ; yes, return normally
              clrabc                ; clean up garbage output
              sethex                ; avoid address calculation problems
              spopnd
              rtn                   ; exit the calling routine
KEYCK4:       chk kb                ; key down yet?
              golc    TMRKEY        ; yes, go check it out
              rtn


;;; **********************************************************************
;;; * GETR# - get register number                             1-5-81 RSW
;;; *
;;; * IN: C= M register contents
;;; *     S2= 0 for STO mode, S2= 1 for RCL mode
;;; * ASSUME: nothing
;;; * OUT: C= rotated M register contents
;;; *      if S2= 0 on input, C.X= STO register number
;;; *      if S2= 1 on input, C.X= RCL register number
;;; * USES: C only
;;; **********************************************************************

              .public `GTR#MC`, `GETR#M`, `GETR#`
`GTR#MC`:     a=c     x
`GETR#M`:     c=m
`GETR#`:      rcr     3             ; C.X= STO reg number
              ?s2=1                 ; in RCL mode?
              rtn nc                ; no, done
              rcr     3             ; C.X= RCL reg number
              rtn


;;; **********************************************************************
;;; * PUTR# - put register number                             1-5-81 RSW
;;; *
;;; * IN: C= rotated M register contents
;;; *      if S2= 0 on input, C.X= STO register number
;;; *      if S2= 1 on input, C.X= RCL register number
;;; * ASSUME: nothing
;;; * OUT: M register updated, C=M
;;; * USES: C only
;;; **********************************************************************

              .public `PUTR#`
`PUTR#`:      rcr     8             ; position for RCL mode
              ?s2=1                 ; in RCL mode?
              goc     PUTR10        ; yes, so done
              rcr     3             ; position for STO mode
PUTR10:       m=c
              rtn


;;; **********************************************************************
;;; * REG# - register number                                  4-15-81 RSW
;;; *  Shifts register number left into display.
;;; *
;;; * IN & ASSUME: display enabled, hexmode
;;; *              S8= 1 (0) check (ignore) keyboard
;;; *                 if S8= 1, then: S9= 1 (0)  return on key up (down)
;;; *              S6= 1 (0) (not) entering register number
;;; *              S4= 1 (0) for 3 (2) digit register number
;;; *              S2= 1 (0) for RCL (STO) mode
;;; *              S0= 1 (0) for difference (split) mode
;;; *
;;; *              M register pointers accurate
;;; *                If the user is entering the register number, the
;;; *                not-yet-specified digits must be F's and must be
;;; *                as shown:
;;; *                          2 digit reg number
;;; *                               0DD  DFX  FFX  (X= don't care)
;;; *                          3 digit reg number
;;; *                               DDD  DDF  DFF  FFF
;;; * OUT: hexmode
;;; * USES: A.X, C, +1 sub level, arith mode
;;; *       (no ST, no PT, no timer chip access)
;;; *
;;; **********************************************************************

              .public `REG#`
`REG#`:       ldi     0x2e          ; right arrow
              ?s2=1                 ; in RCL mode?
              gonc    DSTM10        ; no, in STO mode
              ldi     0x3d          ; =
DSTM10:       slsabc
              ldi     0x12          ; R
              ?s0=1                 ; in difference mode?
              gonc    DSTM20        ; no, split mode
              ldi     4             ; D
DSTM20:       slsabc
              gosub   `GETR#M`      ; C.X= reg number
              gosub   KEYCHK        ; check keyboard if S8 = 1
              a=c     x
              c=0     s
              c=c+1   s
              ?s4=1                 ; 3 digit reg number?
              gonc    DSTM30        ; no, 2 digit
              c=c+1   s
              goto    DSTM35
DSTM30:       ?s6=1                 ; entering reg number?
              goc     DSTM35        ; yes, A.X= FDF
              asl     x             ; no, A.X= DD0
DSTM35:       ldi     0x30
DSTM40:       rcr     12
              c=a     xs            ; C[4:2]= LCD format digit
              rcr     2
              a=a+1   xs            ; prompt needed?
              gonc    DSTM50        ; no, this digit was entered
              ldi     31            ; yes, prompt character
DSTM50:       slsabc
              asl     x             ; A.XS= next reg number digit
              c=c-1   s             ; done?
              gonc    DSTM40        ; no
              rtn


;;; **********************************************************************
;;; * DSPTMR - display time of timer (stopwatch)              2-2-81 RSW
;;; *  DSPTMR first clears the display.
;;; *  If the register number is being displayed, the register number
;;; *  (with prompts if it is not complete) is left shifted into the
;;; *  display. Then the time from "B" is placed in the left side of
;;; *  the display.
;;; *
;;; * IN: Q= 3  to try to display 100th's
;;; *        4  to try to display tenth's
;;; *     B= #HHMMSSCC...  where #= 0 for positive or 9 for negative
;;; * ASSUME: S8= 1 (0)  check (ignore) keyboard
;;; *           if S8= 1, then: S9= 1 (0)  return on key up (down)
;;; *         S6= 1 (0)  (not) entering register number
;;; *         S4= 1 (0)  for 3 (2) digit register number
;;; *         S3= 1 (0)  to suppress (display) the register number
;;; *         S2= 1 (0)  for RCL (STO) mode
;;; *         S0= 1 (0)  for difference (split) mode
;;; *
;;; *         M register pointers accurate
;;; *                If the user is entering the register number, the
;;; *                not-yet-specified digits must be F's and must be
;;; *                as shown:
;;; *                          2 digit reg number
;;; *                               0DD  DFX  FFX  (X= don't care)
;;; *                          3 digit reg number
;;; *                               DDD  DDF  DFF  FFF
;;; * OUT: if S8=1 & S9=0 and a key goes down, jumps directly to "TMRKEY"
;;; *      if S8=0 or no key transition:  P selected, peripherals disabled
;;; *                                     hexmode, S5= 1
;;; *      if S8=1 & S9=1 and the key goes up, output= garbage
;;; * USES: A, B, C, P, Q, S5, +2 sub levels, DADD, PFAD, arith mode
;;; *       (no timer chip access)
;;; *
;;; *                      56= max to exit after key transition
;;; *                      Max total time= 213 for 3 prompts
;;; *                                      205 for 3 digits
;;; **********************************************************************

              .public DSPTMR
DSPTMR:       sel p
              gosub   CLLCDE
              sethex
              ?s3=1                 ; suppress register number?
              gsubnc  `REG#`        ; no, put reg number in display


;;; *
;;; * ...................................................................
;;; * DSPTMM
;;; *  Assumes that the register number is already in the display
;;; *  (if displaying reg number) so "DSPTMM" just updates the time.
;;; *
;;; * IN: hexmode
;;; *     B= #HHMMSSCC.....  where "#"= 0 for positive
;;; *                                 = non-zero for negative
;;; *     Q= 3  to try to display 100th's
;;; *        4  to try to display tenth's
;;; * ASSUME: S3= 1 (0)  to suppress (display) the register number
;;; *         S4= 1 (0)  for 3 (2) digit register number
;;; *         S8= 1 (0)  check (ignore) keyboard
;;; *           if S8= 1, then: S9= 1 (0)  return on key up (down)
;;; * OUT: if S8=1 & S9=0 and a key goes down, jumps directly to "TMRKEY"
;;; *      if S8=0 or no key transition:  P selected, peripherals disabled
;;; *                                     hexmode, S5= 1
;;; *      if S8=1 & S9=1 and the key goes up, output= garbage
;;; * USES: A, B, C, P, Q, S5, +1 sub level, DADD, PFAD, arith mode
;;; *       (no timer chip access)

              .public DSPTMM        ; 55 max to exit after a key
DSPTMM:       gosub   KEYCHK        ; check keyboard if S8 = 1
              abex                  ; A= HMS time
              sel q
              ?s3=1                 ; suppressing reg number?
              gonc    DSTM55        ; no
              ?a#0    s             ; negative?
              gonc    DSTM59        ; no
              dec pt                ; yes
              goto    DSTM59
DSTM55:       ?a#0    s             ; negative?
              gonc    DSTM58        ; no
              pt=     3             ; yes, only room for tenths
DSTM58:       ?s4=1                 ; 3 digit reg number?
              gonc    DSTM59        ; no, 2 digit
              pt=     4             ; yes, leave 5 char for reg number
DSTM59:       goto    DSTM64


;;; **********************************************************************
;;; * DSPINT - display reset interval                         2-2-81 RSW
;;; *
;;; * IN: C= .HHHHMMSSCC...
;;; * ASSUME: nothing
;;; * OUT: P selected, peripherals disabled, hexmode
;;; *      S8= 0, S5= 1
;;; * USES: A, B.S, B[4:0], C, P, Q, S5, S8, +1 sub level, DADD, PFAD,
;;; *       arith mode   (no timer chip access)
;;; **********************************************************************

              .public DSPINT
DSPINT:       sel q
              pt=     2             ; display tenth's of seconds
              sel p
              c=0     s             ; make it positive
              a=c
              gosub   CLLCDE
              c=c+1   s             ; C.S= 1
              s8=     0             ; don't check keyboard
              s5=     1             ; don't show AM/PM
              pt=     12
DSPT10:       ?a#0    pt            ; leading zero?
              gonc    DSPT20        ; yes, remove it
              c=c+1   s             ; no, 3-4 hour digits
              goto    DSTM70
DSPT20:       asl     wpt
              sel q
              inc pt
              sel p
              c=c-1   s             ; down to 2 hour digits?
              gonc    DSPT10        ; no
              goto    DSTM65        ; yes

;;; **********************************************************************
;;; * DSPTM - display time                                    1-28-81 RSW
;;; *  The righthand side of the display [Q:0] is assumed to have been
;;; *  appropriately initialized.  "DSPTM" puts the time in the lefthand
;;; *  side and leaves the righthand side unchanged.
;;; *  !! This means the display must be cleared if necessary, since "DSPTM"
;;; *     does not clear the display !!
;;; *
;;; * IN: A= 24 hour form of time (unnormalized), with A.S= 0
;;; *                [Example:  A= 0HHMMSSCC.....]
;;; *     P selected
;;; *     Q= (rightmost time digit to be displayed) - 1
;;; *        where the leftmost display character= digit 11 and
;;; *                  rightmost= digit 0
;;; * ASSUMES: "CLK24"/"CLK12" bit in timer chip is in proper state
;;; * OUT: P selected, peripherals disabled, hexmode
;;; *      S8= 0, S5= 1 (0)  for 24 (12) hour display
;;; * USES: A, B.S, B[Q:0], C, P, Q, S5, S6, S8, +1 sub level, DADD, PFAD,
;;; *       arith mode, timer PT
;;; **********************************************************************

              .public DSPTM
DSPTM:        s8=     0             ; don't check keyboard
              gosub   TMRSTS        ; put up software status
              ?s6=1                 ; 24 hour display?
              goc     DSTM63        ; yes
              cstex                 ; no, 12 hour
              gosub   TO12H         ; convert to 12 hour, S5=0, S6 initialized
              pt=     12
              ?a#0    pt            ; 2 digit hour?
              goc     DSTM65        ; yes
              b=0     s             ; 1 hour digit
              goto    DSTM75

DSTM63:       cstex
DSTM64:       s5=     1             ; no AM/PM
DSTM65:       c=0     s
DSTM70:       c=c+1   s
              bcex    s             ; B.S= (number of hour digits) - 1

;;; * ......................................................................
;;; * DSTM75                                                  1-28-81 RSW
;;; *  The righthand side of the display [Q:0] is assumed to have been
;;; *  appropriately initialized (cleared, for example). This code
;;; *  puts the time in the lefthand side and leaves the righthand side
;;; *  unchanged.
;;; *
;;; * IN: A= #HHMMSSCC.....= unnormalized time to display
;;; *          A.S= 0 for positive time
;;; *          A.S  non-zero for negative time
;;; *                   (sign-magnitude, not 10's complement)
;;; *          Q= (rightmost time digit to be displayed) - 1
;;; *             where the leftmost display character= digit 11 and
;;; *                       rightmost= digit 0
;;; *             !! Note: If AM/PM is selected (S5=0) it will be added
;;; *                      starting at Q !!
;;; * ASSUME: B.S= (number of hour digits) - 1    [B.S= 3 is expected max]
;;; *         S8= 1 (0)   do (not) check keyboard
;;; *             if S8= 1, then: S9= 1 (0)  return on key up (down)
;;; *         S5= 1 (0) don't (do) add AM/PM
;;; *             if S5= 0, then:  S6= 1 (0)  for PM (AM)
;;; * OUT: if S8=1 & S9=0 and a key goes down, jumps directly to "TMRKEY"
;;; *      if S8=0 or no key transition:  P selected, peripherals disabled
;;; *                                     hexmode, S5= 1
;;; *      if S8=1 & S9=1 and the key goes up, output= garbage !!!
;;; * USES: A, B[Q:0], C, P, Q, S5, +1 sub level, DADD, PFAD, arith mode
;;; *       (no ST, no timer chip access)

DSTM75:       gosub   ENLCD
              flldb                 ; read display backwards
              srldb                 ; reverse display
              flldb                 ; C[11:0]= display reg B
              srldb                 ; restore display
              sethex
              sel q
              bcex    wpt           ; save right side of LCD in B
              sel p
              pt=     11
              asr     m             ; A[11]= leading hour digit
              ?a#0    s             ; negative?
              gonc    DSTM85        ; no
              asr     m             ; open A[11] for minus sign
              lc      13            ; minus sign (A[11]= D, C[11]= 2)
              pt=     11
              a=c     pt
              lc      2             ; minus sign
DSTM85:       c=b     s             ; C.S= hours counter
              ?b#0    s             ; more than 1 hour digit?
              goc     DSTM87        ; yes
              lc      2             ; no, add leading blank
DSTM87:       gosub   KEYCHK        ; check keyboard if S8 = 1
              goto    DSTM92
DSTM90:       lc      3
DSTM92:       c=c-1   s
              gonc    DSTM90
              lc      11            ; digit with colon  (HH:)
              lc      3             ; digit
              lc      11            ; digit with colon (MM:)
              lc      3             ; digit
              lc      7             ; digit with decimal point (SS.)
              lc      3             ; digit
              lc      3             ; digit (CC)
              sel q
              inc pt
              lc      3             ; remove any punctuation on last digit
              ?s5=1                 ; add AM/PM?
              goc     DTM150        ; no
              a=0     wpt
              ?pt=    7             ; time & date display? (+HH:MM only)
              goc     DTM105        ; yes, put AM/PM next to time
              lc      2             ; add a blank [A.PT= 0, C.PT= 2]
DTM105:       ?s6=1                 ; PM?
              goc     DTM110        ; yes
              a=a+1   pt
              lc      0             ; add an "A"  [A.PT= 1, C.PT= 0]
              goto    DTM120
DTM110:       lc      1             ; add a "P"  [A.PT= 0, C.PT= 1]
DTM120:       lc      13
              inc pt
              a=c     pt
              lc      0             ; add a "M"  [A.PT= D, C.PT= 0]
DTM150:       c=b     wpt           ; restore reg number stuff
              srldb                 ; update display B reg
              fllda
              srlda
              fllda
              a=c     wpt           ; add reg number stuff to HMS
              acex
              srlda
              sel p
              c=0     x
              pfad=c                ; disable peripherals
              rtn


;;; **********************************************************************
;;; *
;;; *    Alarm catalog
;;; *
;;; **********************************************************************
;;; * Internal status use:
;;; *       S5= 1 (0)          (don't) print     [temporary use]
;;; *       S7= 1 (0)          shift (not) set
;;; *       M.S= non-zero (0)  catalalog (not) running

              .name   "ALMCAT"
              .public ALMCAT
ALMCAT:       gosub   SRHBFI        ; search for timer buffer
              goto    ACT110        ; (P+1) found it
              golong  CTMPTY        ; (P+2) catalog empty
ACT110:       a=a+1   x             ; A.X= address of first alarm
              acex    x
              c=0     s
              c=c+1   s             ; catalog running
              m=c                   ; M.X= 1st alarm address
              clr st
              s9=     0             ; no printer errors
;;; * !!! S9 must be preserved throughout ALMCAT since it is tested by
;;; *     the printer subroutine calls.

;;; * IN: hexmode, peripherals disabled, M reg pointers
              .public ACT120
ACT120:       gosub   RSTKBT        ; reset keyboard

;;; * IN: peripherals disabled, M reg pointers

              .public ACT125
ACT125:       disoff                ; turn display off
              gosub   DSTMDA        ; display time & date
              s5=     0             ; not printing
              gosub   WAITKD        ; wait 0.6 sec
              s8=     0             ; print only in TRACE
              gosub   IAUALL        ; OK to print?
              goto    ACT140        ; (P+1) don't print
              gosub   OUTPCT        ; (P+2) send paper advance
              disoff                ; turn display off
              gosub   TMSG          ; print alarm time & date
              disoff                ; turn display off
              s6=     1             ; (P+2) OK to print
              gosub   INTVAL        ; display reset interval
              goto    ACT135        ; (P+1) no reset interval
              gosub   TMSG          ; (P+2) print reset interval
              gosub   WAITK6        ; wait 0.6 seconds
ACT135:       ;; originally called BECHK & PECHK, but not any longer
ACT140:       disoff                ; turn disoff off
              gosub   DSAMS0        ; show 1st 12 chars of alarm message
              goto    ACT175        ; (P+1) no message
              c=n
              regn=c  9             ; save message reg in reg 9
;;; * S8= 0 from "DSAMS0" !!!!
              gosub   IAUALL        ; OK to print?
              goto    ACT150        ; (P+1) don't print
              gosub   PRTLCD        ; (P+2) print contents of LCD
              s5=     1             ; printing
              goto    ACT155
ACT150:       s5=     0             ; not printing
ACT155:       c=regn  9
              n=c                   ; restore message reg
              gosub   WAITKD        ; wait 0.6 seconds
              disoff                ; turn display off
              gosub   DSA2ND        ; show last 12 chars of alarm message
              goto    ACT165        ; (P+1) no more chars, display unchanged
              ?s5=1                 ; (P+2) print?
              gsubc   PRTLCD        ; yes, print contents of display
              gosub   WAITKD        ; wait 0.6 seconds, checking keyboard
              goto    ACT170
ACT165:       distog                ; turn display on
              .public ACT170
ACT170:       ?s5=1                 ; printing?
              gsubc   OUTPCT        ; yes, EOLL, BECHK, PECHK
ACT175:       disoff
              distog                ; turn display on
              s7=     0             ; clear "shift" bit
              goto    ACT190
ACT180:       c=m                   ; stop the catalog
              c=0     s
ACT185:       m=c
              gosub   RSTKBT        ; reset keyboard
ACT190:       gosub   CHKLB         ; check low battery
              gosub   ENCP00
              c=m
              ?c#0    s             ; catalog running?
              gonc    ACT300        ; no
              chk kb                ; any key down?
              goc     ACT250        ; yes
ACT240:       gosub   ALMSST        ; single step to next alarm
              goto    ACT242        ; (P+1) continue running catalog
              ldi     1023          ; (P+2) no more alarms
;;; * Wait 0.5 seconds before exiting to give user a chance to hit R/S
ACT241:       chk kb
              goc     ACT250
              c=c-1   x
              gonc    ACT241
              goto    ACTEXT        ; timeout, exit catalog
ACT242:       golong  ACT125

ACT250:       c=keys                ; load the key
              rcr     3
              c=0     xs
              a=c     x             ; A.X = key code
              ldi     0x18          ; OFF key code
              ?a#c    x             ; OFF key?
ACTOFF:       golnc   TMROFF        ; yes
              ldi     0x87          ; R/S key code
              ?a#c    x             ; R/S key?
A180J1:       gonc    ACT180        ; yes
              ldi     403           ; wait 0.125 sec
ACT265:       c=c-1   x
              gonc    ACT265
              rst kb
              chk kb                ; key still down?
              gsubnc  RSTKB         ; no, do up debounce
              goto    ACT240

;;; *
;;; *    Idle loop when catalog is not running
;;; *

ACT300:       c=0
              pt=     7
              lc      2             ; load 2 minute time out counter
ACT310:       chk kb                ; any key down?
              goc     ACT320        ; yes
              ?lld                  ; low battery?
              gonc    ACT312        ; no
              c=c-1   m             ; yes, make it time out faster
              goc     ACTEXT        ; timeout, exit ALMCAT
ACT312:       c=c-1   m
              gonc    ACT310
ACTEXT:       golong  TMEXIT        ; clear keyboard & message flag
;;; * The whole stack has been blown, so must do golong NFRPU

ACTRST:       gosub   RSTALM        ; reset the alarm
              m=c                   ; (P+1) alarm had reset interval
              gosub   DSTMDA
              gosub   LB_5921
              goto    A180J1
ACTR10:       gosub   LB_5921
              goto    ACTRTJ
ACT320:       pt=     3
              c=keys
              c=c+c   pt            ; ON key?
              goc     ACTOFF        ; yes, turn off w/o clearing shift
              ?s7=1                 ; shift set?
              gonc    ACT340        ; no
              gosub   TGLSHF        ; toggle shift annunciator off
              ldi     6             ; table length - 1 = 6
              gosub   `KEY-FC`
              .con    0x34          ; R
              .con    0x70          ; C
              .con    0xc2          ; BST
              .con    0x84          ; T
              .con    0x12          ; shift
              .con    0xc3          ; back arrow
              .con    0
              goto    ACTRST        ; reset the alarm
              goto    PURGA         ; purge alarm
              goto    ACTBST        ; back step
              goto    CURNTT        ; current time
A180J2:       goto    A180J1        ; shift is already off
ACTEXT2:      goto    ACTEXT        ; exit alarm catalog
              goto    SHFTON        ; ignore other keys
                                    ; (turn "shift" back on)
PURGA:        gosub   PUGALM        ; purge the alarm
              goto    .+2           ; (P+1) alarm catalog empty
              goto    ACTR10        ; (P+2)
ACTEXJ:       golong  CTMPTY
CURNTT:       gosub   GDHMS         ; get days-hours-min-sec
              sel q
              pt=     5             ; display seconds
              goto    DST10
ACTBST:       gosub   ALMBST        ; backstep to previous alarm
              ?a#0    pt
ACTRTJ:       golnc   ACT120
              goto    ACTM19
`ACTR/S`:     c=m                   ; start catalog
              c=0     s
              c=c+1   s
              golong  ACT185

SHFTON:       gosub   TGLSHF        ; toggle shift annunciator on
              goto    A180J2

ACT340:       ldi     8             ; table length - 1 = 8
              gosub   `KEY-FC`      ; process the key
              .con    0x80          ; D
              .con    0x34          ; R
              .con    0x82          ; M
              .con    0xc2          ; SST
              .con    0x84          ; T
              .con    0x87          ; R/S
              .con    0x12          ; shift
              .con    0xc3          ; back arrow
              .con    0
              goto    ALDATE        ; alarm date
              goto    RESETI        ; alarm reset interval
              goto    ALMMSG        ; alarm message
              goto    ACTSST        ; single step
              goto    ALTIME        ; alarm time
              goto    `ACTR/S`      ; run stop
              goto    SHFTON        ; shift on
              goto    ACTEXT2       ; exit ALMCAT
              goto    ACTM20        ; undefined key

ALMMSG:       goto    ALMSG0
ACTSST:       gosub   ALMSST        ; single step to next alarm
              goto    ACTRTJ        ; (P+1) M.X= addr of next alarm
ACTM19:       gosub   BLINK1     ; (P+2) M.X unchanged
              goto    ACTM20

ALTIME:       gosub   `A-DHMS`      ; get & convert alarm time to D.H.M.S
              sel q
              pt=     4

              .public DST10
DST10:        gosub   DSPTMP
ACTM20:       s7=     0
              golong  ACT180

ALDATE:       gosub   `A-DHMS`      ; get & convert alarm time to D.H.M.S
              gosub   CLLCDE
              s2=     1
              gosub   DSPDT
              goto    ACTM20

RESETI:       s6=     0             ; display 00:00:00 for no interval
              gosub   INTVAL        ; display reset interval
              nop                   ; (P+1)
              goto    ACTM20        ; (P+2)
ALMSG0:       golong  ALMSG


;;; **********************************************************************
;;; * ALMBST - back step to previous alarm                    4-21-81 RSW
;;; * INPUT: M.X= address of current alarm
;;; *             (address of trailer reg is OK as long as there is at
;;; *              least 1 alarm in the buffer)
;;; * ASSUME: hexmode, timer buffer does exist
;;; * OUTPUT: B.X= C.X= M.X= address of previous alarm
;;; *         A.S= 0
;;; * USES: A, B.X, C, M.X, S8, P, Q, +1 sub level, DADD, PFAD
;;; *       (no timer chip access)
;;; *
              .public ALMBST
ALMBST:       gosub   SRHBUF
              a=a+1   x             ; A.X= address of first alarm
              b=a     x
ABST10:       c=m                   ; C.X = addr of current alarm
              ?a#c    x             ; reach current alarm?
              gonc    ABST20        ; yes
              gosub   LB_32C5
              gosub   SKPALM        ; A.X= C.X= next alarm address
              goto    ABST10
ABST20:       c=b     x             ; C.X= addr of previous alarm
              m=c
              rtn

;;; **********************************************************************
;;; * WAITK6 - wait 0.6 sec while checking for key down       1-5-81 RSW
;;; *
;;; * IN: keyboard cleared unless it is necessary to recognize past keys
;;; *     display turned on   (display off for "WAITKD")
;;; * ASSUMES: hexmode
;;; * OUT: key detected - jumps to ACT155
;;; *           display turned on
;;; *      no key detected - returns
;;; *           display turned off
;;; * USES: C.X      (no ST, no PT, +0 sub levels, no DADD, no PFAD)
;;; *

              .public WAITK6, WAITKD
WAITKD:       distog                ; turn display on
WAITK6:       ldi     753           ; wait 0.6 seconds
WAITK:        chk kb                ; key down?
              golc    ACT170
              c=c-1   x
              gonc    WAITK
              disoff
              rtn


;;; **********************************************************************
;;; * TMSG - timer message
;;; *  Prints the display in NORM & TRACE, and sets message flag
;;; *
;;; * IN & ASSUME: hexmode
;;; * OUT: chip 0 enabled, peripherals disabled, status set 0 up
;;; * USES: A, C, G, N, B[12] for PIL printer, S0-S8, active PT,
;;; *       +2 sub levels

              .public TMSG
TMSG:         s8=     1             ; print & set message flag
              golong  MSG105        ; print display in NORM & TRACE


`KEY-FC`:     golong  `KEY-FC2`

CTMPTY:       s11=    1
              golong  LB_3790

LB_5921:      c=m
              n=c
              clr st
              gosub   NXTALM
              c=n
              m=c
              rtn

              nop
              nop
              nop

;;; **********************************************************************
;;; * 36000 - load constant 0 0000036000 000 to reg C         4-21-81 RSW
;;; *
;;; * IN: A= positive stopwatch time in 100th's of seconds format
;;; * ASSUME: nothing
;;; * OUT: dec mode, PT= 5, C= 0 0000036000 000
;;; *      A= (stopwatch time) MOD (100 hours)  with 1 too many subrtracts
;;; * USES: C, active PT, arith mode
;;; *           (no ST, no DADD, no PFAD, no timer chip access,
;;; *            +0 sub levels)
              .public `36000`
`36000`:      setdec
              pt=     7
              c=0
              lc      3
              lc      6
1$:           a=a-c
              gonc    1$
              rtn


;;; **********************************************************************
;;; * RNGERR - range error                                    4-7-81 RSW
;;; *  Returns only if the range error ignore flag is set.
;;; *
;;; * IN & ASSUME: chip 0 enabled, peripherals disabled
;;; * OUT: input S0-S7 preserved in C[1:0]
;;; * USES: C, S0-S7
;;; *       (no PT, +0 sub levels, no arith mode, no timer chip access)
;;; *

              .public RNGERR
RNGERR:       c=regn  14
              rcr     6
              cstex
              ?s7=1                 ; range error ignore flag set?
              rtn c                 ; yes
              golong  ERROF         ; no, "OUT OF RANGE"

;;; **********************************************************************
;;; * XYZALM                                                  2-19-81 RSW
;;; **********************************************************************
;;; * XYZALM - fully programmable set alarm function
;;; *
;;; * IN: X-reg = alarm time in H.MS form
;;; *     Y-reg = alarm date in M.DY(D.MY) form
;;; *     Z-reg = alarm auto-reset interval in H.MS form
;;; *     alpha reg = alarm message
;;; *
;;; * If alarm date = 0 then XYZALM will use today's date
;;; *          ( illegal date gives "DATA ERROR Y" )
;;; * If Z-reg is zero there will be no reset interval
;;; *          ( illegal interval gives "DATA ERROR Z" )
;;; * If alpha reg is clear the alarm will have no message
;;; *
;;; **********************************************************************

              .name   "XYZALM"
              .public XYZALM
XYZALM:       ldi     2             ; take date from Y-reg
              gosub   CHECK         ; error if alpha data
                                    ; M= M.DY (D.MY) date
              gosub   CHKXM         ; error if X= alpha data
              n=c                   ; N= H.MS time
              gosub   INITMR        ; initialize timer if necessary
              pt=a
              rdtime                ; C= current time
              s0=     1             ; use Y for date compare
              s1=     1             ; add X or Y to "DATA ERROR"
              gosub   `C=T+D0`      ; C= time+date in seconds
              rcr     12            ; C= SSSSSSSSSSCC00
              c=0     x
              c#0?                  ; whole register = 0?
              goc     XYZA20        ; no, it's OK
              c=c+1   m             ; yes, add 0.1 sec to time to avoid
                                    ;   67/97 card reader bug
XYZA20:       n=c                   ; N= SSSSSSSSSSC000
              s0=     0             ; assume no reset interval
              c=c+1   x             ; C.X= 1= address of Z reg
              gosub   CHECK         ; error of Z= alpha data
              a=c
              c#0?                  ; any reset interval given?
              gonc    XYZA40        ; no
              s0=     1             ; there is a reset interval
              gosub   HMSEC1        ; convert to seconds (A= 0000SSSSSSSSCC)
;;; * The maximum reset interval of 9999.595999 fits in 8 digits of seconds
              goto    XYZA30        ; (P+1) interval OK
XYZA25:       ldi     26     ; (P+2) illegal interval, "DATA ERROR Z"
              golong  TERR20
XYZA30:       c=0
              c=c+1   xs
              a<c?                  ; reset interval < 1 second?
              goc     XYZA25        ; yes, error
XYZA40:       acex                  ; C= 0 000SSSSSSS SCC
              rcr     12            ; C= 00SSSSSSSSCC00
              c=0     x             ; remove 100th's of seconds
              regn=c  9             ; reg 9= reset interval

;;; *
;;; *    Store an alarm
;;; *
;;; * IN:     N[13:3]= alarm time in 10th's of seconds since Jan. 1, 1900
;;; *         N.X = 000
;;; *     if S0 = 0 no auto-reset interval with this alarm
;;; *     if S0 = 1 the auto-reset interval is stored in reg-9
;;; * Procedure to store store an alarm:
;;; * 1. Find out after the chain head if there is enough empty memory
;;; *    to expand the timer I/O buffer. The required empty memory = 1 +
;;; *    alarm message length in registers.
;;; * 2. Search the first register of the timer buffer. If not found,
;;; *    initialize an I/O buffer with the size of 2 registers. This
;;; *    initial timer I/O buffer doesn't have any alarm in it.
;;; * 3. Go through the alarm stack to determine where to store this new alarm.
;;; * 4. Lift up a hole in the timer buffer for storing the new alarm time
;;; *    and its message, if it has any.
;;; * 5. Stores the alarm and its message into the hole just generated.
;;; *    The message is stored the same way as it is in the alpha register.
;;; * ........................................................................
;;; * The exp field of the alarm time carries the following information:
;;; * digit 0 : length of alarm message in registers
;;; * digit 1 : non-zero if the alarm has an auto-reset interval
;;; *
;;; *
;;; *

              sethex
              gosub   FNDMSG        ; find 1st non-null char in alpha reg
              c=n
              ldi     4             ; C= SSSSSSSSSSC004
              c=a-c   x             ; C= A= # reg of message
              a=c     x
              ?s0=1                 ; any auto increment?
              gonc    STA100        ; no
              a=a+1   x             ; yes, 1 more reg required
              c=c+1   xs            ; mark auto reset alarm
STA100:       n=c                   ; N= alarm & info
              a=a+1   x             ; count alarm reg
              acex    x             ; C.X= # of reg required
              m=c
              gosub   MEMLFT        ; check memory left
              a=c     x             ; A.X= # unused reg left
              c=m                   ; C.X= # of reg required
              ?a<c    x             ; is there a space problem?
              goc     NOROOM        ; yes
              s0=     1             ; assume enough room
              c=c+1   x             ; may need 2 registers for buffer
              c=c+1   x             ;  header & trailer
              ?a<c    x             ; is there a space problem now?
              gonc    STA150        ; no, still OK
              s0=     0             ; yes, no room to create buffer
STA150:       gosub   SRHBUF     ; search for the timer buffer
                                    ; A.X= beginning of buffer
              goto    STA200        ; (P+1) buffer found
;;; *
;;; *      Set up the timer ROM I/O buffer in the unused memory
;;; *
;;; * IN: hexmode, peripherals disabled
;;; *     A.X= address of first unused reg after I/O buffers
;;; *
;;; *     Buffer size = 2 registers
;;; *     first register  = AA020000000000
;;; *     second register = F0000000000000
              ?s0=1                 ; is there room to create buffer?
              goc     STA160        ; yes

;;; * NOROOM -- if the error ignore flag is cleared, put up "NO ROOM" message
;;; *           and jump to ERR110 in 41C mainframe
;;; *
;;; * IN & ASSUME: nothing
;;; *                    !!! does not return !!!
;;; *

              .public NOROOM
NOROOM:       gosub   ERRSUB
              gosub   CLLCDE
              gosub   MESSL
              .messl  "NO ROOM"
              fllabc                ; rotate display left 4 characters
              rabcl                 ; left justify display
              golong  TERR50

STA160:       b=a     x             ; B.X= addr of 1st unused reg
              c=b     x
              c=c+1   x
              dadd=c
              c=0
              c=c-1   s             ; C.S= F (to mark last reg)
              data=c
              c=b     x             ; C.X= first register address
              dadd=c
              c=0
              pt=     13
              lc      10
              lc      10
              lc      0
              lc      2
              data=c
;;; *
;;; * 1. Make sure the timer buffer will not be overflowed and get the
;;; *    address of the last register of last I/O buffer.
;;; *

STA200:       s3=     0             ; not purging alarm
              gosub   CHKBUF        ; update timer buffer length
                                    ; B.X= header reg of timer buffer
              m=c                   ; M.X= last reg of last I/O buffer
;;; *
;;; * 2. Determine where to insert the new alarm into the alarm stack
;;; *
              c=n                   ; C= alarm time & info
              c=b     x             ; C.X= addr of 1st reg
              c=c+1   x             ; C.X= addr of 1st alarm
              a=c                   ; A= alarm time & addr of 1st alarm
              gosub   NEWLOC        ; A.X= place to insert alarm
;;; *
;;; * IN: A.X= addr to store at,  M= last reg & etc
;;; *
;;; * Need to lift other I/O buffers even if storing at end of timer buffer.
;;; *
              b=a     x             ; B.X= start lifting address
              c=m                   ; C.X= last reg of last buf
              a=c     x
              c=n                   ; C= alarm & info
              gosub   SKPAL1        ; A.X= new address of last reg
              c=m                   ; C.X= old last reg of last buffer
              acex    x             ; A.X= old last reg addr
              m=c                   ; M.X= new last reg addr
;;; *
;;; * Open an empty space in timer I/O buffer
;;; *
;;; * IN: A.X= addr of last reg in last I/O buffer
;;; *     M.X= new addr for last reg in last I/O buffer
;;; *     B.X= addr of lowest addressed reg to be moved
;;; *

LFTMEM:       acex    x
              dadd=c
              c=c-1   x
              a=c     x
              c=data
              cmex
              dadd=c
              c=c-1   x
              cmex
              data=c
              ?a<b    x             ; done lifting?
              gonc    LFTMEM        ; no
;;; *
;;; * 4. Store the new alarm time and its message into the empty space
;;; *
              c=b     x             ; C.X= inserting address
              dadd=c
              c=c+1   x
              m=c
              c=n                   ; C= alarm & info
              ?c#0    xs            ; has auto-reset interval?
              gonc    STA325        ; no
              data=c                ; store the alarm time
              c=0     x
              dadd=c
              c=regn  9             ; load reset interval from reg.9
              a=c
              c=m
              dadd=c
              c=c+1   x
              m=c
              acex                  ; C= auto-reset interval
STA325:       data=c
              c=n                   ; C[0]= message length in registers
              pt=     0
              c=c-1   pt            ; message length = 0?
              goc     STA350        ; yes, all done
              gosub   FNDMSG        ; find 1st char in alpha reg
STA340:       c#0?                  ; any characters in this reg?
              goc     STA342        ; yes
              c=c+1   m             ; no, all nulls, so make in non-zero

;;; * Note: The advanced programming(*) ROM allows long embedded null strings
;;; *       in alpha register. Due to the 67/97 card read bug, an I/O buffer
;;; *       cannot have any registers = 0, so whole registers of nulls must
;;; *       be modified to be non-zero.
;;; *
;;; * (*) This was the original name of what later become the
;;; *      Extended Functions ROM.
;;; *      It is also possible to create such strings by other means.
;;; *      I am not sure about this 67/97 card reader bug, sounds like
;;; *      a problem with the HP41 card reader ROM. I could not find a
;;; *      reference to it in "Extend your HP-41" either, I suppose that
;;; *      since HP was well aware of it, may have fixed it at some point.
;;; *
STA342:       cmex                  ; M= message register
              dadd=c                ; C.X= addr to store message in buffer
              c=c+1   x
              cmex
              data=c
STA345:       a=a-1   s             ; all message moved?
              goc     STA350        ; yes, all done
              acex    x
              c=c-1   x
              dadd=c
              a=c     x
              c=data                ; load next message reg
              goto    STA340
STA350:       golong  ADJ100        ; set new hardware alarm, and beep
                                    ;  if there are past due alarms

;;; **********************************************************************
;;; * T+X                                                     2-23-81 RSW
;;; **********************************************************************

              .name   "T+X"
              .public `T+X`
`T+X`:        gosub   CHECKX        ; error if X= alpha data
              gosub   `R9=T`        ; C= reg 9= clock time, A=0
              a=a+b                 ; A= B= entered time
              m=c                   ;  M= clock time
              gosub   HMSEC1        ; H.MS time to 100th's of sec
              goto    PLUS20        ; (P+1) entry legal
              golong  ERRDE         ; (P+2) "DATA ERROR"
PLUS20:       setdec
              ?b#0    s             ; subtract?
              gonc    PLUS25        ; no, add
              c=-c
              a=c                   ; A= entered interval
PLUS25:       n=c                   ; N= entered interval
              c=m                   ; C= current time
              a=a+c
              ?a#0    s             ; resulting year < 1900?
              gonc    PLUS30        ; no, OK
              a=0
PLUSER:       gosub   RNGERR        ; return only if error ignore= 1
              acex                  ; C= time to set
              goto    PLUS40
PLUS30:       c=0
              pt=     11
              lc      9             ; (beginning of 300 year= 1/1/1900)
              lc      4             ;  then 12/31/2199= 109572 days + 1
              lc      6             ;             = 9467107200 seconds
              lc      7
              lc      1
              lc      0
              lc      7
              lc      2
              acex                  ; A= max, C= new time
              a<c?                  ; max < new time?
              goc     PLUSER        ; yes, "OUT OF RANGE"
PLUS40:       gosub   `T=T+TP`      ; set new time
              rdscr
              a=c                   ; A= last time set
              c=n                   ; C= entered interval
              c=a+c
              wrscr                 ; update "last time set"
              goto    STA350
;;; * If the time is read within 1/100 sec of the write&correct in "T=T+TP"
;;; * it may be 1/100 sec low !!!!!!!

;;; **********************************************************************
;; *                                                          12-11-80 RSW
;; * CHKBUF - Check if the buffer size will overflow after adding a new
;; *  alarm and update the buffer size. Check if there is any other
;; *  I/O buffer on top of timer I/O buffer.
;; *
;; * INPUT: A.X= addr of first register of the timer I/O buffer
;; *        N.X= exponent field of alarm register
;; *        S3= 1  purging the alarm
;; *        S3= 0  adding an alarm
;; * ASSUME: peripherals disabled, hexmode
;; * OUTPUT: C.X= address of last register of last I/O buffer
;; *         B.X= address of first register of the timer buffer
;; *    Timer ROM I/O buffer size will be updated by adding (subtracting)
;; *    for S3=1) the required registers to the original buffer size.
;; * Return to "NO ROOM" routine if the buffer size will overflow
;; *
;; * USES: A, B.X, C, S8, active PT, DADD, +1 sub level
;; *       (no timer chip access)
;; *
;;; **********************************************************************

              .public CHKBUF

CHKBUF:       b=a     x             ; B.X= addr of 1st reg in buffer
              a=0     x
              c=n
              gosub   SKPAL1        ; A.X= alarm length
              c=b     x
              dadd=c
              c=data                ; C= 1st reg in timer buffer
              rcr     10
              pt=     1
              acex    wpt           ; A.X= old buffer length
                                    ; C[1:0]= alarm length
              ?s3=1                 ; purging alarm?
              goc     CHKB20        ; yes
              c=a+c   wpt           ; C[1:0]= new buffer length
              golc    NOROOM        ; buffer overflow
              goto    CHKB30
CHKB20:       c=a-c   wpt           ; adjust buf length
CHKB30:       rcr     4
              data=c                ; update buffer length
              a=a+b   x
              acex    x             ; C.X= last tmr buf reg + 1
;;; * C.X must point there so the "?a#c pt" test in "FNDEOB" won't return
              s8=     0             ; don't allow return to P+2
              gosub   FNDEOB        ; A.X= (last reg of last I/O buffer) + 1
              a=a-1   x
              acex    x             ; C.X= addr of last reg of last
                                    ;   I/O buffer
              rtn

;;; **********************************************************************
;;; * NEWLOC - new location (for alarm)                       12-15-80 RSW
;;; * NEWLSK - new location, skip alarm
;;; *
;;; *  Given an alarm time in B[13:3], finds the place in the alarm stack
;;; *  to insert the new alarm.
;;; *
;;; * IN:  (NEWLOC) A.X= C.X= address at which to start searching
;;; *               (trailer reg addr OK, otherwise it must be a valid
;;; *                alarm address)
;;; *      (NEWLSK) same except sets A.X=C.X, and skips that alarm
;;; *               before starting the search, so C.X must be a valid
;;; *               alarm address.
;;; * ASSUMES: A[13:3]= new alarm time in tenths of seconds
;;; *          Q= 13, P selected, hexmode, peripherals disabled
;;; * OUT: A.X= address of trailer reg of alarm stack
;;; *      A.X= address of first alarm > new alarm
;;; * USES: A, C, active PT, +1 sub level, DADD
;;; *       (no ST, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public NEWLSK, NEWLOC
NEWL00:       acex    x             ; C.X= current alarm address
NEWLSK:       gosub   SKPALC        ; get A.X= C.X= next alm addr
NEWLOC:       dadd=c
              c=data
              pt=     3
              c=c+1   s             ; end of buffer?
              rtn c                 ; yes, show last alarm
              c=c-1   s             ; restore C.S
              ?a<c    pq            ; given alarm < current alarm?
              gonc    NEWL00        ; no, keep looking
              rtn


;;; **********************************************************************
;; *                                                          1-9-81 RSW
;; * SKPALM - advance address of current alarm to next alarm address
;; *
;; * INPUT:  (SKPALM)  A.X= C.X= current alarm address
;; *        !!!Note - The alarm address must really be the address of
;; *                  an alarm, not the address of the trailer register
;; *                  or other register.
;; *         (SKPAL1)  A.X= current alarm address
;; *                   C.X= exponent field of current alarm
;; *
;; * ASSUME: hexmode, peripherals disabled
;; * OUT: A.X= C.X= next alarm address (current alarm register enabled
;; *                                    for SKPALM)
;; *       !!! This may be the address of the trailer register !!!
;; * USES: A.X, C, DAD
;; *       (no PT, no ST, +0 sub levels, no PFAD, no timer chip access)
;; *
;;; **********************************************************************

              .public SKPALC, SKPALM, SKPAL1
SKPALC:       a=c     x
SKPALM:       dadd=c
              c=data                ; load current alarm
SKPAL1:       ?c#0    xs            ; does alarm have reset interval?
              gonc    SKPAL2        ; no
              a=a+1   x             ; yes, count the interval register
SKPAL2:       a=a+1   x             ; count the time&date register
              rcr     1             ; C.S= number of message regs
              c=0     x             ; clear reset interval flag digit
                                    ;  and "already acknowledged" flag digit
              rcr     13
              c=a+c   x             ; C.X= address of next alarm
              a=c     x
              rtn


;;; **********************************************************************
;;; *                                                         4-2-81 RSW
;;; * SRHBUF - search timer I/O buffer in the user memory after
;;; *          chain head
;;; *
;;; * IN & ASSUME: hexmode
;;; * OUT:   P selected, P = 12, peripherals disabled
;;; *        Q = 13
;;; *      Return to P+1 if I/O buffer found
;;; *        A.S= 0
;;; *        A.X= addr of first reg of timer buffer, with that reg enabled
;;; *        C= contents of first register of buffer
;;; *      Return to P+2 if I/O buffer not found
;;; *        If C.X= 0, then A.X= addr of 1st unused reg after I/O buffers
;;; *
;;; * USES: A, C, S8, P, Q, DADD, PFAD, +0 sub levels
;;; *       (no timer chip access)
;;; *
;;; **********************************************************************
;;; * SRHBFI - Same as SRHBUF except it initializes the timer chip if the
;;; *          power lost status bit is set or warm start constant is
;;; *          not there.
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: P selected, P= 12, Q= 13, peripherals disabled, hexmode
;;; *      (P+1) & (P+2) output same as SRHBUF
;;; * USES: A, C, S0-S8, P, Q, +2 sub levels, DADD, PFAD, arith mode
;;; *
;;; **********************************************************************

              .public SRHBFI, SRHBUF
SRHBFI:       gosub   INITMR        ; initializes timer chip if necessary
SRHBUF:       c=0
              pfad=c
              sel q
              pt=     13            ; Q= 13
              sel p
              ldi     0x0c0         ; address of low end of memory
              s8=     1             ; allow return to P+2
;;; *
;;; * The following comments apply when "FNDEOB" is called from "CHKBUF".
;;; *
;;; * IN: C.X= (address of last reg of timer buffer) + 1
;;; *     S8= 0 to prevent return to P+2
;;; * ASSUME: hexmode, peripherals disabled
;;; * OUT: A.X= (address of last reg in last I/O buffer) + 1
;;; * USES: A, C, active PT, DADD
;;; *       (no timer chip access, +0 sub levels)

              .public FNDEOB
FNDEOB:       pt=     12
              lc      10
              pt=     12
              a=c
              goto    SRBF10
SRBF08:       a=a+1   x             ; point to next reg
SRBF10:       c=0
              dadd=c                ; enable chip 0
              c=regn  13            ; C.X= addr of bottom of program memory
              ?a<c    x             ; reached program buffer yet?
              gonc    SRBF30        ; yes, I/O buffer not found
              c=a    x
              dadd=c
              c=data
              c=c+1   s             ; is this a key reg?
              goc     SRBF08        ; yes
              c=c-1   s             ; restore C.X (for C=0 test below)
              ?a#c    pt            ; is this 1st reg of timer buffer?
              rtn nc                ; yes, we found the timer buffer
              rcr     10
              c=0     xs            ; buffer size
              a=a+c   x             ; jump over this I/O buffer
              c#0?                  ; is this an I/O buf?
              goc     SRBF10        ; yes
SRBF30:       ?s8=1                 ; allow return to P+2?
              rtn nc                ; no
              goto    `RTNP+2`


;;; **********************************************************************
;;; * ALMSST - single step to next alarm
;;; *
;;; * INPUT: M.X= address of current alarm
;;; * !!!Note - The alarm address must really be an alarm address, not the
;;; *           address of the trailer reg or some other reg.
;;; *
;;; * ASSUME: hexmode, peripherals disabled
;;; * OUT:   (P+1):  C.X= M.X = next alarm address, A.X= original address
;;; *        (P+2):  There is no next alarm  (M.X unchanged)
;;; * USES: A.X, C, M.X, DADD, +1 sub level
;;; *       (no ST, no PT, no PFAD)
;;; *
;;; **********************
;;; * NEWM.X - puts A.X into M.X
;;; *
;;; * IN: A.X= alarm address to be placed in M.X
;;; * ASSUME: nothing
;;; * OUT: C.X= M.X= input A.X
;;; * USES: A.X, C, M.X  only
;;; *
;;; **********************************************************************

              .public ALMSST, `NEWM.X`
ALMSST:       c=m
              gosub   SKPALC        ; skip over current alarm
              dadd=c
              c=data                ; load next alarm
              c=c+1   s             ; end of timer buffer?
              goc     `RTNP+2`      ; yes, return to P+2

`NEWM.X`:     c=m                   ; C.X= M.X= next alarm address
              acex    x
              m=c
              rtn


;;; **********************************************************************
;;; * ACKALM - acknowledge an alarm                           2-9-81 RSW
;;; *  If the alarm has a reset interval, reset it to next (hopefully)
;;; *  future occurrance.  If the alarm has no reset interval, purge it.
;;; *
;;; * INPUT: M.X= alarm address
;;; * ASSUME: hexmode, peripherals disabled
;;; *         reset interval stored in this format: 0 0SSSSSSSST 000
;;; *           where "T"= tenths of seconds
;;; * OUT: P selected, Q= 13
;;; *      return to (P+1):
;;; *               [no alarm left, stack purged]
;;; *               [some alarms left, but no higher addressed alarms]
;;; *      return to (P+2):
;;; *               At least 1 higher addressed alarm left.
;;; *               M.X= next (toward future) alarm address
;;; * USES: A, B, C, N, may update M.X, P, Q, S3, S8, +3 sub levels,
;;; *       DADD, PFAD, arith mode, timer PT   (no timer ST)
;;; *
;;; **********************************************************************

              .public ACKALM
ACKALM:       gosub   RSTALM        ; yes, reset this alarm
              goto    `RTNP+2`      ; (P+1) alarm has reset interval
ACKAL10:      gosub   PUGALM        ; (P+2) purge this alarm
                                    ;   (no reset interval)
              rtn                   ; (P+1) no alarms, stack purged
              a=a+1   s             ; any higher address alarm in stack?
              rtn nc                ; no, done

              .public `RTNP+2`
`RTNP+2`:      sethex                ; need hexmode for "c=stk"
              c=stk                 ; return to P+2
              c=c+1   m
              gotoc


;;; **********************************************************************
;;; *                                                         2-17-81 RSW
;;; * INTVAL - reset interval time
;;; *
;;; *    if S6=0, displays interval time or 00:00:00 for no interval
;;; *             (always returns tp P+2)
;;; *    if S6=1, no interval -- no display, returns to P+1
;;; *             interval -- display interval and return to P+2
;;; *
;;; * IN: S6 initialized properly
;;; *     peripherals disabled
;;; * ASSUME: M.X= address of current alarm, hexmode
;;; * OUT:  (P+1) returns here if S6=1 and the alarm has not reset interval
;;; *                peripherals disabled, S6= 1
;;; *       (P+2) returns here is (S6= 0) or (S6= 1 and the alarm has a
;;; *                                         reset interval)
;;; *                display enabled, RAM disabled
;;; * USES: A, B, C, P, Q, S5, S8, +2 sub levels, DADD, PFAD, arith mode
;;; *       (no timer chip access)
;;; *
;;; **********************************************************************

              .public INTVAL
INTVAL:       gosub   `GETM.X`      ; C= current alarm
              ?c#0    xs            ; has an auto reset interval?
              gonc    INTV20        ; no
              c=m
              c=c+1   x             ; point to reset interval
              dadd=c
              c=data                ; C= SSSSSSSSSSC000
              rcr     2             ; C= 00SSSSSSSSSSC0
              gosub   SDHMSC        ; A= DDDDDDHHMMSSCC
              gosub   X20Q8         ; A= (days) x 20
              csr                   ; C= (days) x 4
              c=a+c                 ; C= (days) x 24
              rcr     11            ; truncate to 4 hour digits
INTV10:       gosub   DSPINT
              gosub   ENLCD
              rabcr                 ; rotate one place to the right
              goto    `RTNP+2`
INTV20:       ?s6=1
              rtn c
              c=0                   ; no reset interval
              goto    INTV10


;;; **********************************************************************
;;; *                                                         1-19-81 RSW
;;; * IGDHMS - initialize & get days, hours, minutes, seconds
;;; *
;;; * IN: nothing
;;; * ASSUME: valid clock time  (no more than 1 year past 12/2199,
;;; *                            no garbage)
;;; * OUT: timer chip enabled, RAM disabled, timer PT=A
;;; *      A= C= DDDDDDHHMMSSCC, hexmode
;;; * USES: A, B.M, C, active PT, S0-S8, +2 sub levels, DADD, PFAD,
;;; *       arith mode, timer PT    (no timer ST)
;;; *
;;; * GDHMS -- same as IGDHMS except:
;;; *            - assumes the timer chip doesn't need to be initialized
;;; *            - doesn't use S0-S7
;;; *            - only uses +1 sub level
;;; *
;;; **********************************************************************

              .public IGDHMS, GDHMS
IGDHMS:       gosub   INITMR        ; initialize timer if necessary
GDHMS:        gosub   ENTMR         ; enable timer chip, disable RAM, PT=A
              rdtime                ; C= clock time
              goto    SDHMSC        ; A= C= DDDDDDHHMMSSCC


;;; **********************************************************************
;;; *                                                         1-15-81 RSW
;;; * A-DHMS - convert alarm time (from alarm stack) to
;;; *          days, hours, minutes and seconds
;;; * INPUT: M.X= address of current alarm  (!!Must be valid alarm address,
;;; *                                          not trailer register!!)
;;; * ASSUMES: peripherals disabled
;;; * OUTPUT: A= C= DDDDDDHHMMSSCC, hexmode
;;; *         alarm register enabled, S8= 0
;;; *
;;; * USES: A, B[13:3], C, active PT, S8, arith mode, DADD
;;; *       (+0 sub levels, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public `A-DHMS`
`A-DHMS`:     c=m
              dadd=c
              c=data                ; C= SSSSSSSSSSCXXX
              c=0     x
              rcr     2             ; C= 00SSSSSSSSSSC0

;;; **********************************************************************
;;; *                                                         1-15-81 RSW
;;; * SDHMSK - convert seconds into days, hours, minutes, seconds, 100th's
;;; *
;;; *  !! if S8=1 & S9=0, jumps directly to TMRKEY on key down !!!
;;; *
;;; *
;;; * INPUT: A= 00SSSSSSSSSSCC
;;; *        C.X and the active PT must be related as follows:
;;; *     C.X    active PT    "A" contains a number of seconds equivalent to
;;; *      0         6                     0-9 days    (1 digit)
;;; *      1         7                   10-99 days    (2 digits)
;;; *      2         8                 100-999 days    (3 digits)
;;; *      3         9               1000-9999 days    (4 digits)
;;; *      4        10             10000-99999 days    (5 digits)
;;; *      5        11         100,000-999,999 days    (6 digits)
;;; *       If S8= 1, then the keyboard must be cleared right before calling
;;; *           SDHMSK if you only want to detect keys pushed during SDHMSK.
;;; * ASSUME: S8= 0  to ignore keyboard   (S9= don't care)
;;; *         S8= 1  to check keyboard
;;; *             and S9= 1 (0) return on key up (down)
;;; * OUT: if (S8= 0) or (S8= 1 and no key transitions detected) then:
;;; *           A= C= DDDDDDHHMMSSCC, hexmode, PT= 3
;;; *      if S8= 1 and a key transition has been detected then:
;;; *           decmode
;;; *  !!!Note: Since SDHMSK doesn't clear the keyboard, the key could
;;; *           have been pushed before ever calling SDHMSK.
;;; * USES: A, B.M, C, active PT, arith mode
;;; *       (+0 sub levels, no DADD, no PFAD, no timer chip access)
;;; *
;;; *
;;; * SDHMSA -- same as SDHMSK except:
;;; *           sets C.X= 5, and PT= 11   (6 digits of days)
;;; *           sets S8= 0 to ignore keyboard
;;; *             !!! so uses S8 !!!
;;; *
;;; * SDHMSC -- same as SDHMSA except the seconds are input in C
;;; *   Note: Takes about 341 word times worst case for dates in the range
;;; *         1/1/1900 - 12/31/2199  (99999 days, 19 hours, 59 minutes)
;;; *
;;; **********************************************************************

              .public SDHMSK, SDHMSC
SDHMSC:       a=c
              s8=     0             ; ignore keyboard
              ldi     5             ; repeat for 6 digits of days
              pt=     11
SDHMSK:       c=0     m
              lc      8
              lc      6
              lc      4             ; 86400 seconds= 1 day
              inc pt
              inc pt
              inc pt
              inc pt
              setdec
              bcex    m
              c=0     m
              goto    DHMS25
DHMS20:       c=c+1   pt
DHMS25:       a=a-b   m
              gonc    DHMS20
              a=a+b   m
              ?s8=1                 ; check keyboard
              gonc    DHMS28        ; no
              ?s9=1                 ; return on key up?
              gonc    DHMS27        ; no, on key down
              rst kb
              chk kb                ; key still down?
              rtn nc                ; no, abort
              goto    DHMS28
DHMS27:       chk kb                ; key down
              golc    TMRKEY        ; yes, abort
DHMS28:       c=c-1   x
              goc     DHMS30
              dec pt
              bsr     m
              goto    DHMS25
DHMS30:       ?pt=    7             ; just finished days?
              gonc    DHMS40        ; no, finished hours or minutes
                                    ; yes, set up for hours
              bcex    m             ; save C in B
              c=0     m
              pt=     6
              lc      3
              lc      6             ; 3600 seconds in 1 hour
              pt=     6             ; C.M= 0000003600= 10 hours
DHMS35:       bcex    m             ; restore C, B= new constant
              c=0     x
              c=c+1   x             ; repeat for 2 digits
              goto    DHMS25
DHMS40:       ?pt=    5             ; just finished hours?
              gonc    DHMS50        ; no, just finished minutes?
                                    ; yes, set up for minutes
              bcex    m             ; C.M= 0000000360, save C in B
              lc      0             ; C.M= 0000000060= 10 minutes, PT= 4
              goto    DHMS35
DHMS50:       rcr     13            ; C= DDDDDDHHMM0000
              acex    wpt           ; C= DDDDDDHHMMSSCC
              a=c
              sethex
              rtn                   ; 13 to exit after last key check


;;; **********************************************************************
 ;;; * SETAF - set accuracy factor                             2-4-81 RSW
;;; **********************************************************************

              .name   "SETAF"
              .public SETAF, SETAF0
SETAF:        gosub   INITMR        ; initialize so new A.F. won't get cleared
              pt=a                  ; select main clock
              rdtime                ; C= current clock
              wrscr                 ; update "last time set"
              gosub   CHECKX        ; error if X= alpha data

;;; * ................................................................
;;; * SETAF0 - set (store) accuracy factor                    2-4-81 RSW
;;; *
;;; * IN: C= floating point normalized accuracy factor
;;; * ASSUME: nothing
;;; * OUT: new accuracy factor store in AF register in timer chip
;;; *      timer chip enabled, RAM disabled
;;; * USES: A, C, active PT,  +1 sub level, arith mode,
;;; *       DADD, PFAD, timer PT   (no timer ST)
;;; *

SETAF0:       c#0?                  ; AF= 0 exactly?
              gonc    SETA40        ; yes, don't round to 0.1
              gosub   UNNOR1        ; unnormalize AF
              goto    SETA10        ; (P+1) OK, A= #DDD.......000
              c=0                   ; (P+2) AF >= 100, set to
                                    ;   minimum correction
              goto    SETA40        ; don't set AF of 0 to 0.1
SETA10:       pt=     13
              lc      5
              acex                  ; C= unnormalized AF, A.S= 5
              rcr     10            ; C.X= AF
              c=a+c   s             ;  need to round up AF?
              gonc    SETA30        ; no
SETA20:       c=c+1   x             ; round up
              goc     SETA40        ; +-99.95 goes to +-0 (no correction)
SETA30:       ?c#0    x             ; AF = 0?
              gonc    SETA20        ; yes, round to 0.1
SETA40:       rcr     11            ; C= .......SDDD...
              gosub   ENTMR         ; enable timer, disable RAM
              rcr     2             ; C= .........SDDD.
              pt=b
              wrsts
              rtn


;;; **********************************************************************
;;; * 115860 - set C= 11586000000000                          2-19-81 RSW
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: C= 11586000000000
;;; * USES: active PT   only
;;; *
;;; **********************************************************************

              .public `115860`
`115860`:     c=0
              pt=     13
              lc      1
              lc      1
              lc      5
              lc      8
              lc      6
              rtn


;;; **********************************************************************
;;; * CLRALM - clear alarm  (hardware alarm bits)             1-15-81 RSW
;;; *
;;; * IN & ASSUME: timer chip enabled, RAM disabled
;;; * OUT: timer PT=A
;;; *      hardware alarm bits DTZA, ALMB, and DTZIT cleared
;;; *         DTZA= decrement through zero on clock A  (shouldn't happen)
;;; *         DTZIT= decrement through zero on interval timer
;;; *         ALMB= alarm on clock B  (shouldn't happen)
;;; *   !! Note: DTZIT could be set again on exit if the interval timer
;;; *            is running
;;; *
;;; * USES: C.X, timer PT  only
;;; *
;;; *
;;; * CLRAL0 - same as CLRALM except assumes timer PT=A
;;; *          uses only C.X
;;; *
;;; * CLRALW - Writes the contents of "C" to timer scratch reg B, then
;;; *          clears DTZA, ALMB, DTZIT.
;;; *          IN: C[1:0]= updated timer software status, timer PT=B
;;; *          ASSUME: timer chip enabled, RAM disabled
;;; *          OUT: timer scratch reg B updated,  + CLRALM output
;;; *          USES: C.X, timer PT only
;;; *
;;; *
;;; * CLRALS - stops the interval timer
;;; *          Clears clock display bits and updates the software status
;;; *          bit pattern in timer scratch reg B.
;;; *          IN: S0-S7= timer software status bits, timer PT=B
;;; *          ASSUME: timer chip enabled, RAM disabled
;;; *          OUT: same as CLRALW but also  S0-S7= input C[1:0]
;;; *                                        interval timer stopped
;;; *          USES: C.X, S0-S7, timer PT    only
;;; *
;;; **********************************************************************

              .public CLRALD, CLRALS, CLRALW, CLRALM, CLRAL0
CLRALD:       s0=     0             ; clear DSWKNO bit
CLRALS:       stpint                ; stop interval timer
              s3=     0
              s4=     0
              cstex
CLRALW:       wrscr
CLRALM:       pt=a
CLRAL0:       ldi     0x29          ; don't clear ALM A, DTZB, PUS
              wrsts                 ; clear all other alarms
              rtn


;;; **********************************************************************
;;; * R9=T - register 9 = time                                12/4/80
;;; *
;;; * IN: C= floating point number
;;; * ASSUME: nothing
;;; * OUT: C= reg 9= main clock time, B= copy of input contents of "C"
;;; *      A= 0
;;; *      timer PT=A, chip 0 enabled, peripherals disabled, decmode
;;; * USES: A, B, C, S0-S7, timer PT, DADD, PFAD, arith mode,
;;; *       +2 sub levels   (no 41C PT)
;;; *
;;; **********************************************************************

              .public `R9=T`
`R9=T`:       bcex                  ; B= H.MS time (for T+X)
              gosub   INITMR
              pt=a
              rdtime                ; C= main clock time
              a=c
              c=0
              dadd=c
              acex
              regn=c  9             ; reg 9= main clock time
              setdec
              rtn


;;; **********************************************************************
;;; * SETSW - use X register to set the time in the stopwatch
;;; *                                                         1-30-81 RSW
;;; **********************************************************************

              .name   "SETSW"
              .public SETSW
SETSW:        gosub   UNNORX        ; check alpha data, unnormalize X
              goto    XTMR05        ; (P+1) A= #HHMMSSCC.....
              goto    SETSDE        ; (P+2) error

XTMR05:       b=a     s             ; save the sign
              s8=     0             ; ignore keyboard
              gosub   HMSS20
              goto    XTMR10        ; (P+1) C= 00SSSSSSSSSSCC
SETSDE:       golong  ERRDE     ; (P+2) "DATA ERROR"
XTMR10:       gosub   INITMM        ; initialize, timer PT=B
              c=m
              ?b#0    s             ; negative time?
              gonc    XTMR30        ; no, positive
              setdec
              c=-c
XTMR30:       wrtime                ; store in stopwatch
              rtn


;;; **********************************************************************
;;; *                                                         1-29-81 RSW

              .name   "ATIME24"
              .public ATIME24
ATIME24:      s0=     0             ; doing a time
              s5=     1             ; unconditional 24 hour format
              goto    ATD007

;;; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
;;; *                                                         1-29-81 RSW

              .name   "ATIME"
              .public ATIME
ATIME:        s0=     0             ; doing a time
              goto    TIMEIN

;;; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
;;; *                                                         1-29-81 RSW

              .name   "ADATE"
              .public ADATE
ADATE:        s0=     1             ; doing a date
TIMEIN:       s5=     0             ; assume 12 hour format
ATD007:       s4=     0             ; not formatting for display
              gosub   UNNORX        ; unnormalize X register
              goto    ATD010        ; (P+1) OK
              goto    SETSDE        ; (P+2) "DATA ERROR"
ATD010:       c=regn  14
              rcr     4             ; C[0]= number of display digits

;;; **********************************************************************
;;; * DATEIN - date in  (date display entry point)            1-26-81 RSW
;;; *
;;; *  Internal pointers & status bits
;;; *    S0= 1 (0)  doing a date (time)
;;; *       if S0= 1, then:  S3= 1 (0)  DMY (MDY)
;;; *    S4= 1 (0)  formtting for display (alpha register)
;;; *    S5= 1 (0)  24 (12) hour format
;;; *    S6= 1 (0)  PM (AM)  !! for time only, not dates !!
;;; *
;;; *    A[0]= format counter= number of digits to output
;;; *    A[1]= field counter
;;; *    A[2]= digits since last separator counter
;;; *
;;; * IN: TIME --   A= #HHMMSSCC.....  where "#"=  0 for AM
;;; *                                 = non-zero for PM
;;; *     DATE --   A= 0MMDDYYYY..... or 0DDMMYYYY.....
;;; *     for both -- C[0]= number of digit to the right of the decimal
;;; *                       point in "fix" mode
;;; *                     (odd numbers will be rounded up, numbers >= 6
;;; *                      will be set = 6)
;;; *                 S5= 1 for unconditional 24 hour format
;;; *                 S5= 0 to use "CLK12"/"CLK24" bit
;;; * ASSUMES:  S0= 1    To create a date format.
;;; *              S4= 1 To send output to display. The characters are
;;; *                    shifted left into the display, so the display
;;; *                    must be properly initialized.
;;; *                    (!! DATEIN does not clear the display !!!)
;;; *              S4= 0 To send output to alpha register.
;;; *                 !!! S4= 0 is required for time format !!!
;;; *
;;; * OUT: hexmode
;;; *      S5= 1 (0)  for 24 (12) hour format
;;; *      if TIME (S0=0) is being formatted: S6= 1 (0)  for PM (AM)
;;; *      if DATE (S0=1) is being formatted: S3= 1 (0)  for DMY (MDY)
;;; *      if S4= 1, then display enabled, RAM disabled
;;; *      if S4= 0, then chip 0 enabled, peripherals disabled
;;; * USES: A, B, C,G, S3 if S0=1, S5, S6 if S0=0, active PT, +1 sub level
;;; *       arith mode, PFAD, DADD  (no timer chip access)
;;; *
;;; **********************************************************************

              .public DATEIN
DATEIN:       pt=     1
              lc      5             ; A[1]= 5 for century delete (dates)?
              sethex                ; now PT=0
              a=c     x
              gosub   TMRSTS
              ?s6=1                 ; 24 hour format?
              gonc    ATD015        ; no, 12 hour format
              cstex
              s5=     1             ; remember 24 hour format
              goto    ATD017
ATD015:       cstex
ATD017:       gosub   ENCP00
              ldi     0x126         ; digit ctr=1, field ctr=2, format ctr= 6
              ?a<c    pt            ; display format < 6?
              gonc    ATD020        ; no, set format = 6
              acex    pt
ATD020:       c=c+1   pt            ; round format up
              cstex
              s0=     1             ; add 2 digits to left of decimal point
              cstex
              ?s0=1                 ; doing a date?
              gonc    ATD032        ; no, a time
              asr     x             ; A[0]= 5
              ?a#c    pt            ; format + 1 = 5?
              goc     ATD030        ; no, don't delete century
              pt=     8             ; delete century
              asl     wpt
              asl     wpt
ATD030:       a=c     x             ; A.X= format, field & digit ctrs = 12X
              s3=     0             ; assume MDY
              gosub   GFLG31        ; get flag 31
              c=c+c   pt            ; DMY?
              gonc    ATD061        ; no, MDY
              s3=     1             ; remember DMY
              goto    ATD061
ATD032:       a=c     x             ; A.X= format, field, digit ctrs = 12X
              ?s5=1                 ; 24 hour format?
              goc     ATD050        ; yes

              gosub   TO12H         ; convert hours to 12 hour format
              pt=     12
              ?a#0    pt            ; 2 digit hour/month
              goc     ATD061        ; yes
              pt=     13
              lc      2
              goto    ATD070        ; send leading blank to alpha reg

ATD050:       gosub   TO24H         ; convert to 24 hours format
              sethex
              acex                  ; C= MMSSCC.....0HH
              rcr     3
              a=c                   ; A= 0HHMMSSCC..12N  where
                                    ;   N= #digits to output
              goto    ATD061

ATD060:       asl     m             ; A[12]= next digit
ATD061:       ?s4=1                 ; formatting for display?
              goc     ATD080        ; yes
              pt=     13
              lc      3
ATD070:       acex    pt
              gosub   ATD120        ; append the digit to the alpha reg
              abex                  ; restore time/date & ctrs
              goto    ATD090

ATD080:       gosub   ENLCD
              pt=     0
              lc      0
              lc      3
              acex    pt            ; C[12]= A[12]
              rcr     12            ; C.X= LCD format digit
              slsabc
ATD090:       pt=     0             ; check format ctr
              a=a-1   pt            ; end of digits
              gonc    ATD150        ; no
              ?s0=1                 ; doing a date?
              rtn c                 ; yes done
              ?s5=1                 ;  24 hour format?
              rtn c                 ; yes, done
;;; * Must be formatting a time, so not formatting for display,
;;; * so chip 0 is enabled
              ldi     ' '
              gosub   ATD125        ; append the blank to alpha reg
              ldi     65            ; ASCII "A"
              ?s6=1                 ; PM?
              gonc    ATD110        ; no, AM
              ldi     80            ; ASCII "P"
ATD110:       gosub   ATD125        ; append "A" or "P" to alpha reg
              ldi     77            ; ASCII "M"

              .public ATD120, ATD125
ATD120:       abex                  ; saves code (B= time/date & counters)
ATD125:       g=c
              golong  APNDNW        ; append the character to alpha reg
ATD150:       a=a-1   xs     ; 2 digits sent since last separator?
ATD152:       gonc    ATD060     ; no, send 2nd digit
              pt=     1
              ?s0=1                 ; doing a date?
              goc     ATD190        ; yes
              a=a-1   pt            ; just sent seconds?
              gonc    ATD180        ; no
              lc      2
              lc      14            ; ASCII decimal point
ATD160:       pt=     0
              gosub   ATD120        ; append it to alpha reg
              abex                  ; A= time date & counters
ATD170:       a=0     xs
              a=a+1   xs            ; digit ctr= 1
              goto    ATD152

ATD180:       lc      3
              lc      10            ; ASCII colon
              goto    ATD160
ATD190:       a=a-1   pt     ; just sent first 2 digits of year?
              goc     ATD170        ; yes, don't send a separator
              ldi     47            ; ASCII or LCD "/"
              ?s3=1                 ; DMY?
              gonc    ATD200        ; no, MDY -- use "/"
              c=c-1   x             ; C.X= 02E = ASCII "."
              ?s4=1                 ; formatting for display?
              gonc    ATD160        ; no
              frsabc                ; fetch rightmost character
              cstex
              s6=     1             ; add "."
              cstex
              goto    ATD210
ATD200:       ?s4=1                 ; formatting for display?
              gonc    ATD160        ; no
ATD210:       slsabc                ; yes, send it to LCD
              goto    ATD170


;;; **********************************************************************
;;; * M306 - month * 30.6                                     1-14-81 RSW
;;; *
;;; * IN: C= month  [not in C.X or C[0], and the rest of C should be cleared
;;; *                to be safe]
;;; * ASSUME: dec mode
;;; * OUT: C= 30.6*C
;;; * !!! This includes the fractional part -- the calling routine must
;;; *     clean up !
;;; * USES: A, C,  (no PT, no ST, no DADD, no PFAD, not arith mode,
;;; *               +0 sub levels, no timer chip access)
;;; *
;;; **********************************************************************

              .public M306
M306:         a=c
              c=c+c
              c=a+c                 ; C= 3*C
              a=c
              c=c+c                 ; C= 6*C
              csr                   ; C= 0.6*C
              asl                   ; A= 30*C
              c=a+c                 ; C= 30.6*C
              rtn


;;; **********************************************************************
;;; *                                                         1-6-81 RSW
;;; * NDAYS - convert an integer number of days to normalized floating
;;; *         point form
;;; *
;;; * IN:  C= DDDDDD00000000 ( 6 digits of days )
;;; * ASSUMES: nothing
;;; * OUT: A= C= positive normalized floating point number of days
;;; *      dec mode
;;; * USES: A, C, active PT, +1 sub levels, arith mode
;;; *       (no ST, no DADD, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public NDAYS
NDAYS:        csr                   ; C= 0 DDDDDD0000 000
              ldi     4             ; exponent= 5 - 1
              gosub   NORM
              setdec                ; A= C= normalized number in days
              rtn


;;; **********************************************************************
;;; * UNNORM - unnormalize                                    1-5-81 RSW
;;; *
;;; * IN: A= Normalized floating point number (the exponent must be valid
;;; *        since negative zero, A.XS= 1-8, or non-BCD digits will not
;;; *        work).
;;; *     C.X= Positive exponent to which to normalize
;;; *        = [number of digits to left of decimal point] - 1
;;; *        (negative exponent can give trouble as when C.X= 977 and A.X= 085)
;;; *
;;; * !!!! Warning: If have C.X < A.X, an error will result
;;; *
;;; * ASSUMES: nothing
;;; * OUT: P+1:  A= unnormalized number (with leading zeros)
;;; *                 Note:  UNNORM may output a negative zero!!!!!!
;;; *            dec mode, PT= 12
;;; *      P+2:  Error exit with hex mode set (input number was too big)
;;; * USES: A[12:0], C.X, C[6:3] used on error exit, active PT, arith mode
;;; *       (no ST, no DADD, no PFAD, +0 sub levels, no timer chip access)
;;; *
;;; *
;;; *     *     *     *     *     *
;;; * UNNORX - unnormalize the X register contents            1-20-81 RSW
;;; *
;;; * IN & ASSUME: peripherals disabled
;;; *              X containts a floating point number
;;; * OUT: save as UNNORM but also: chip 0 enabled, S9=1
;;; * USES: A, B, C, active PT, S9, +2 sub levels, arith mode, DADD
;;; *       (no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public UNNORX, UNNOR1, UNNOR2, UNNORM
UNNORX:      gosub   CHECKX        ; error if X= alpha data
UNNOR1:       a=c
UNNOR2:       ldi     1             ; error if HH > 99
UNNORM:       setdec                ; 35 max for .01 sec input (inc GSB & RTN)
              acex    x             ; A= max exp, C= actual exp
              pt=     12
              c=a-c   x             ; C.X= max - actual
              c=c+1   xs            ; max < actual ?
              golc    `RTNP+2`      ; yes, "DATA ERROR"
              c=c-1   xs            ; no, fix C.X
              a=0     x             ; clean up X field
              goto    UNORM6
UNORM4:       asr     wpt           ; add leading zeros
UNORM6:       c=c-1   x             ; done?
              gonc    UNORM4        ; no
              rtn


;;; **********************************************************************
;;; *                                                         1-12-81 RSW
;;; * X20 - integer multiply by 20
;;; *  This special purpose routine sets up for multiplication by 24
;;; *  or 60. The PQ field in "A" is moved to "C", shifted (to multiply
;;; *  by 10) and doubled, then added to "A" to add 20 times the PQ field
;;; *  to the 2 MSD of the rest of "A". C is doubled again before returning
;;; *  so another addition will result in multiplication by 60. Shifting
;;; *  then adding results in the PQ field of "A" being multiplied by
;;; *  24 and added to the 2 MSD of the rest of "A".
;;; *
;;; * IN: A= input data
;;; * ASSUMES:  1. dec
;;; *           2. Q= 13
;;; *           3. Pointer P at rightmost digit of upper field  (P >= 1 )
;;; * OUT:  1. A= 20 * PQ field + 2nd field
;;; *       2. C= 40 * PQ field
;;; *       3. pointer unchanged
;;; * USES: A, C  (no ST, no PT, +0 sub levels, no DADD, no PFAD)
;;; *
;;; * X20Q -- same as X20 except expects P selected and sets Q= 13,
;;; *         so uses Q
;;; *
;;; **********************************************************************

              .public X20Q8, X20Q, X20
X20Q8:        setdec
              sel p
              pt=     8
X20Q:         sel q
              pt=     13
              sel p
X20:          c=0
              acex    pq            ; upper data to C
              csr                   ; = 10x data in A
              c=c+c                 ; =  20x
              a=a+c                 ; A= 20*upper + lower
              c=c+c                 ; = 40x
              rtn


;;; **********************************************************************
;;; * DSPTMP - display time (left justified)                  1-29-81 RSW
;;; *
;;; * IN: A= ......HHMMSSCC  where HH= 24 hour form, "."= don't care
;;; *     Q= (rightmost time digit to be displayed) - 1, where the
;;; *        leftmost display character= digit 11, rightmost= digit 0
;;; * ASSUMES: "CLK12"/"CLK24" bit in timer chip is in proper state
;;; *          (12/24 hour display)
;;; * OUT: P selected, peripherals disabled, hexmode
;;; *      S5= 1 (0)  for 24 (12) hour display
;;; *      S2= 1
;;; * USES: A, B.S, B[Q:0], C, N, P, Q, S2, S5, S6, S8, +2 sub levels,
;;; *       DADD, PFAD, arith mode, timer PT
;;; *
;;; *
;;; * .     .     .     .     .     .     .
;;; * DSPTMD -- display time and date
;;; *
;;; * IN: A= DDDDDDHHMMSSCC  (like output of SDHMSC)
;;; * ASSUMES: same as DSPTMP
;;; * OUT: P selected, chip 0 enabled, peripherals disabled, hexmode
;;; *      S5= 1 (0)  for 24 (12) hour format
;;; *      R8[13:8]= day number since OCt 15, 1582
;;; * USES: A, B, C, G, N, R8[13:6], P, Q, S0, S2-S6, S8, +2 sub levels,
;;; *       arith mode, DADD, PFAD, timer PT
;;; *
;;; **********************************************************************

              .public DSTMDA, DSPTMD, DSPTIM, DSPTMP
DSTMDA:       gosub   `A-DHMS`
DSPTMD:       s2=     0
              sel q
              pt=     7             ; display minutes
              goto    DSPTM5
DSPTIM:       sel q
              pt=     5             ; display seconds
DSPTMP:       s2=     1
DSPTM5:       sel p                 ; A= DDDDDDHHMMSSCC
              gosub   CLLCDE
              acex
              n=c                   ; save day# in N
              rcr     9             ; C= DHHMMSSCCDDDDD
              c=0     s
              a=c                   ; A= 0HHMMSSCCDDDDD
              gosub   DSPTM
              ?s2=1                 ; display time only?
              rtn c                 ; yes, done
              gosub   ENLCD
              flldab                ; rotate display left 6 characters
              rabcl
              c=n
              a=c                   ; A= DDDDDD... = day# since 1/1/1900
              golong  DSPDT         ; add the date


;;; **********************************************************************
;;; * DSWEEK - display day of week in english                 1-14-81 RSW
;;; *  Shifts the day of week into the right side of the display.
;;; *
;;; * INPUT: C= 0D000000000000
;;; *        where D is day of week.  Sunday=0, ..., Saturday=6
;;; *        A.S= 0  to display two letters
;;; *        A.S= 1  to display three letters
;;; * ASSUME: LCD enabled, RAM disabled, hexmode
;;; * USES: A[13:3], C, +1 sub level
;;; *       (no PT, no ST, no DADD, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public DSWEEK
DSWEEK:       a=a+1   s
              rcr     9             ; C= 0 000000000D 000
              a=c     m
              c=c+c   m
              a=a+c   m             ; A.M = 3(day of week)
              gosub   DSWEKA
              .con    0x13          ; S
              .con    0x15          ; U
              .con    0x0e          ; N
              .con    0x0d          ; M
              .con    0x0f          ; O
              .con    0x0e          ; N
              .con    0x14          ; T
              .con    0x15          ; U
              .con    0x05          ; E
              .con    0x17          ; W
              .con    0x05          ; E
              .con    0x04          ; D
              .con    0x14          ; T
              .con    0x08          ; H
              .con    0x15          ; U
              .con    0x06          ; F
              .con    0x12          ; R
              .con    0x09          ; I
              .con    0x13          ; S
              .con    0x01          ; A
              .con    0x14          ; T

              .public DSWEKA
DSWEKA:       c=stk                 ; C.M = address of top of table
              c=a+c   m             ; C.M= top of table + 3(day)
DSWK30:       cxisa
              slsabc
              c=c+1   m
              a=a-1   s
              gonc    DSWK30
              rtn


;;; **********************************************************************
;;; * BEPI - beep initialize routine                          4-28-81 RSW
;;; *
;;; * IN & ASSUME: hexmode
;;; * OUT: chip 0 enabled, A[1:0]= input S7-S0
;;; *       if audio enable flag is not set:
;;; *         S7-S0= 00000000
;;; *       if audio enable flag is set:
;;; *         S7-S0= 00000001
;;; * USES: A.X, C, S0-S7, DADD, PFAD, +1 sub level
;;; *       (no PT, no timer chip access)
;;; *
;;; **********************************************************************

              .public BEPI
BEPI:         c=st
              a=c     x             ; save S7-S0 in A[1:0]
              clr st
              gosub   ENCP00
              c=regn  14            ; C= user flag register
              rcr     5
              c=c+c   xs
              c=c+c   xs
              c=c+c   xs            ; audio enable flag set?
              rtn nc                ; no, don't beep  (S7-S0= 00000000)
              s0=     1             ; yes, S7-S0= 00000001 so will beep
              rtn


;;; **********************************************************************
;;; * BEEP2K - routine sounds two beeps                       1-6-81 RSW
;;; *  If the audio enable flag is not set, it will not beep.
;;; *  If the audio enable flag is set:
;;; *    1. Beep
;;; *    2. Pause briefly, checking keyboard if S8= 1
;;; *    3. Beep a second time, checking keyboard if S8= 1
;;; *
;;; *    If S8= 1 and a key is detectedm BEEP2K returns immediately
;;; *    after clearing the flag out register and restoring the input
;;; *    status bits.
;;; *
;;; *    !!!! CAUTION !!!!  Since the keyboard is not cleared
;;; *    in BEEP2K, an earlier keystroke could cause a return!!!!
;;; *
;;; * IN & ASSUME:  S8= 1  to check keyboard
;;; *               S8= 0 to ignore keyboard
;;; *               hexmode
;;; *               flag out register = 0
;;; * OUT: chip 0 enabled, flag out register cleared,
;;; *      input status bits restored
;;; *     !! The keyboard is not cleared !!!
;;; * USES: A.X, C, +2 sub levels, DADD, PFAD
;;; *       (no PT, S0-S7 restored, no timer chip access)
;;; *
;;; *   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
;;; *
;;; * BEEP2 - same as BEEP2K except sets S8= 0 so it ignores keyboard
;;; *
;;; * BEEPKP - pause, then beep
;;; *    Same as BEEP2K except it doesn't do the first beep.
;;; *
;;; * BEEPK - same as BEEP2K except it only does the second beep
;;; *         (it sets S8= 1 so the keyboard will be checked)
;;; *
;;; **********************************************************************

              .public BEEP2, BEEP2K, BEEPKP, BEEPK, BEEPNK
BEEP2:        s8=     0             ; don't check keyboard
BEEP2K:       gosub   BEPI
              ldi     601           ; ..... first beep .....
BEP210:       fexsb                 ; (no keyboard check)
              c=c-1   x
              gonc    BEP210
              goto    BEPK05

BEEPKP:       gosub   BEPI
BEPK05:       ldi     30            ; ..... pause between beeps .....
BEPK10:       ?s8=1                 ; check keyboard?
              gonc    BEPK20        ; no
              chk kb                ; key down?
              goc     BEPK50        ; yes
BEPK20:       c=c-1   x
              gonc    BEPK10
              goto    BEPK28
BEEPK:        s8=     1             ; check the keyboard
BEEPNK:       gosub   BEPI
BEPK28:       ldi     301           ; ..... second beep .....
BEPK30:       fexsb
              ?s8=1                 ; check the keyboard?
              gonc    BEPK40        ; no
              chk kb                ; yes, key down?
              goc     BEPK50        ; yes
BEPK40:       c=c-1   x
              gonc    BEPK30
BEPK50:       clr st
              f=sb                  ; clear flag out register
              c=a     x             ; C= input status bits
              st=c                  ; restore input status
              rtn


;;; **********************************************************************
;;; * TMRSTS - timer status                                   1-5-81 RSW
;;; *  Gets timer software status from timer scratch reg B and puts it
;;; *  in S[7:0], saving the old status bits in C[1:0].
;;; *
;;; * IN & ASSUME: timer software status bits in scratch reg B
;;; * OUT: ST[7:0]= timer status bits 7-0, input S0-S7 saved in C[1:0]
;;; *      timer chip enabled, RAM disabled, PT=B,
;;; *      C[13:2]= scratch reg B[13:2]
;;; * USES: C, ST[7:0], DADD, PFAD, timer PT
;;; *       (no 41C PT, no arith mode, +0 sub levels)
;;; *
;;; *   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
;;; *
;;; *
;;; * TMRST -
;;; *  IN: timer software status bits in scratch reg B
;;; *  ASSUME: timer chip enabled, RAM disabled, timer PT=B
;;; *  OUT: S0-S7= timer software status bits 0-7
;;; *       C[1:0]= input S0-S7, C[13:2]= timer scratch reg B[13:2]
;;; *  USES: C, S0-S7   (no PT, no arith mode, +0 sub levels)
;;; *
;;; **********************************************************************

              .public TMRSTS, TMRST
TMRSTS:       ldi     0x10
              dadd=c                ; disable RAM
              ldi     0xfb          ; enable timer chip
              pfad=c
              pt=b                  ; select scratch reg B
TMRST:        rdscr                 ; read it
              goto    CSTRTN


;;; **********************************************************************
;;; * HWSTS - hardware status                                 1-5-81 RSW
;;; *  Gets timer chip hardware status bits.
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: S[7:0]= timer hardware status, input S0-S7 saved in C[1:0]
;;; *      timer chip enabled, RAM disabled, PT=A
;;; * USES: C, ST[7:0], timer PT, DADD, PFAD, +1 sub level
;;; *       (no 41C PT, no arith mode)
;;; *
;;; **********************************************************************

              .public HWSTS
HWSTS:        gosub   ENTMR         ; enable timer chip, PT=A
              rdsts                 ; read it
CSTRTN:       cstex
              rtn


;;; **********************************************************************
;;; * TO12H - to 12 hour                                      1-20-81 RSW
;;; *  Converts 12 or 24 hour input to 12 our output (unless hour>23)
;;; *
;;; * IN: A= #HHMMSSCC.....  where "#"=  0 for AM
;;; *                                    1-9 for PM
;;; *                          and "."= don't care
;;; * ASSUMES: nothing
;;; * OUT: A= C= #HHMMSSCC.....  where HH= 12 hour format (unless HH > 23)
;;; *      hexmode
;;; *      S5= 0 (12 hour format) for hour < 24
;;; *      S5= 1 (24 hour format) for hour >= 24
;;; *               ( S6= 1 also, and the hour will be unchanged )
;;; *      S6= 0 for AM
;;; *      S6= 1 for PM
;;; *      PT= 1
;;; * USES: A[13:11], C, S5, S6, active PT, arith mode
;;; *       (+0 sub levels, no PFAD, no DADD, no timer chip access)
;;; *
;;; **********************************************************************

              .public TO12H
TO12H:        acex
              s5=     0             ; assume 12 hour format
              s6=     0             ; assume "AM"
              rcr     11
              a=c                   ; A= MMSSSCC.....#HH
              ldi     0x12
              pt=     1
              ?a<c    wpt           ; hour < 12 ?
              goc     T12H30        ; yes
              ?a#c    wpt           ; hour = 12 ?
              gonc    T12H25        ; yes
              setdec
              a=a-c   wpt           ; PM hour= hour - 12
;;; * This code is for "ATIME" to make hour > 23 switch to 24 hour format
              ?a<c    wpt           ; PM hour < 12
              goc     T12H25        ; yes
              a=a+c   wpt           ; no, restore hour
              s5=     1             ; 24 hour format
;;; * end of code for "ATIME"
              goto    T12H25
T12H20:       ?a#0    xs            ; PM?
              gonc    T12H40        ; no
T12H25:       s6=     1             ; remember PM
              goto    T12H40
T12H30:       ?a#0    wpt           ; hour = 00 ?
              goc     T12H20        ; no
              a=c     x             ; yes, set hour = 12
T12H40:       sethex
              acex
              rcr     3
              a=c
              rtn


;;; **********************************************************************
;;; *                                                         1-5-81 RSW
;;; * T=T+TP - time + processing time
;;; *  Adds the processing time to the new time&date and set the time&date.
;;; *
;;; * IN: C= calculated new time= "TC"= 00SSSSSSSSSSCC
;;; *     peripherals (other than timer) disabled
;;; * ASSUMES: reg 9= clock time at start of processing
;;; * OUT: dec mode, C= new corrected time (may be 1/100 sec off -- slow)
;;; *      timer chip enabled, RAM disabled, timer PT=A
;;; * USES: A, B, C, active PT, timer PT, +1 sub level, DADD, PFAD,
;;; *       arith mode  (no ST)
;;; *
;;; * !!! CAUTION !!! Doesn't check for TC+TP > 12/31/2199
;;; *
;;; **********************************************************************

              .public `T=T+TP`
`T=T+TP`:     a=c
              c=0
              dadd=c
              c=regn  9             ; C= old clock time
              bcex                  ; B = old clock time (begin of proc.)
              gosub   ENTMR         ; enable timer chip, PT=A
              rctime                ; C= current time (start correction)
              setdec
              acex                  ; A= current time, C= calculated time
              a=a-b                 ; A= processing time
              c=a+c                 ; C= corrected time
              wdtime                ; store and correct if necessary
              rtn


;;; **********************************************************************
;;; * STOPSW - stop stopwatch                                 1-8-81 RSW
;;; **********************************************************************

              .name   "STOPSW"
              .public STOPSW
STOPSW:       gosub   INITMR        ; initialize timer if necessary
              stopc                 ; stop stopwatch
              rtn                   ; note: the timer chip automatically
                                    ; disables when a RAM chip is enabled


;;; **********************************************************************
;;; * SUM3D5                                                  1-22-81 RSW
;;; *
;;; * This routine is based on the date algorithm give above. It calculates
;;; *  N.M + 578164 - SUM3(Y).
;;; *
;;; * IN: C.M= 000000YYYY= year
;;; *     N.M= accumulating total
;;; * ASSUME: nothing
;;; * OUT: C.M= input annunciator total + 578164 - SUM3(Y)
;;; *              [right justified in C.M]
;;; *      dec mode
;;; *      B.M= 000000YYYY= copy of input year
;;; * USES: A, B, C, N.M, active PT, arith mode
;;; *       (no ST, +0 sub levels since saves a sub level, no DADD,
;;; *        no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public SUM3D5
SUM3D5:       sethex                ; C= X 000000YYYY XXX  (X= don't care)
              rcr     10            ; C= 0 00YYYYXXXX 000
              c=stk                 ; save return address
              rcr     4             ; C= R 000000YYYY RRR
              setdec
              bcex                  ; save year and return address
              a=0
              pt=     2
              lc      3
              lc      6
              lc      5             ; C= R 000000YYYY 365
              acex    x             ; A.X= 365, C.X= 0
              c=c+1   xs            ; 3 digit multipler
;;; *   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
;;; *
;;; *  Integer multiply
;;; *  Start with A.M= 0 and A.X= multiplier. The year in the
;;; *  mantissa of C is added to A.M for each count of A[0]. All of "A" is
;;; *  shifted to position the next digit of the multiplier in A[0].
;;; *  The number of digits of A.X used is (C.XS+2).
;;; *     (so C.XS=0 uses A[1:0], and C.XS=1 uses A[2:0] )
;;; *  Result: A= A.X * C.M
;;; *
;;; * INPUT:  1. A.M = 0
;;; *         2. multiplicand in mantissa of B
;;; *         3. multiplier right justified in A.X
;;; *         4. C.XS = (number of digits in A.X to use as multiplier) - 2
;;; * ASSUME: decmode
;;; * OUT:
;;; *         1. answer in A (optional position)
;;; *         2. PT = 0
;;; *         3. C.XS = 9, rest of C unchanged
;;; * USES: A, C.XS, active PT
;;; *

              c=c+1   xs            ; C.XS= 2  (3 digit multiplier)
              pt=     0
              goto    IMPY3

IMPY2:        a=a+b   m             ; add constant to A
IMPY3:        a=a-1   pt            ; decrement A[0]
              gonc    IMPY2

              asr                   ; position for next pass
              c=c-1   xs            ; used all specified digits
              gonc    IMPY3         ; no, do next one

;;; *   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .

              acex                  ; C= 0 00000DDDDD DDD (D..D= Y*365)
              rcr     11            ; C= 0 00DDDDDDDD 000
              a=c
              c=b     m             ; C= 0 000000YYYY 000
              rcr     2             ; C.M= int[Y/100]
              a=a-c   m             ; A.M= 365*Y - int[Y/100]
              c=n                   ; C= total
              acex    m             ; C.M= Y*365 - int[Y/100], A.M= total
              c=a-c   m
              n=c                   ; store new total
              a=b     m             ; A= 0 000000YYYY 000
              c=0
              pt=     6
              lc      4             ; C= divisor= 0 0000004000 000
              pt=     7
              gosub   IDVD4         ; A= Y/4 (4 digit answer)
              acex                  ; C= 0 0000QQQ00 000
              rcr     2             ; C.M= int[Y/4]
              a=c                   ; A= 0 000000QQQQ 000
              rcr     2             ; C= 0 00000000QQ QQ0
              a=a+c   m             ; A.M= int[Y/4] + int[Y/400]
              c=0
              pt=     8
              lc      5
              lc      7
              lc      8
              lc      1
              lc      6
              lc      4
              acex                  ; A.M= 0000578164
                                    ; C= int[Y/4] + int[Y/400]
              a=a-c   m
              c=b                   ; C= R 000000YYYY RRR
              rcr     10
              stk=c                 ; ! works in decmode !
              c=n                   ; C.M= total
              c=a+c   m
              rtn


;;; **********************************************************************
;;; * CLRFLG - clear flags                                    2-25-81 RSW
;;; *
;;; * Clears the following flags : alpha, partial key seq, pausing,
;;; *                              catalog, shift, data entry, message
;;; * and clears the SHIFT & ALPHA annunciators.
;;; *
;;; * IN & ASSUME: hexmode
;;; * OUT: Status set 0 up, chip 0 enabled, peripherals disabled,
;;; *      and the above mentioned flags cleared.
;;; * USES: A, C, S0-S7, (maybe S13), +1 sub level, DADD, PFAD
;;; *       (no PT, no timer chip access)
;;; *
;;; **********************************************************************

              .public CLRFLG
CLRFLG:       gosub   LDSST0
;;; * Note: The "TRUN" code can be accessed during a pause as the pause or
;;; *       any digit key during a pause passes through the NFRS on the
;;; *       way to "PAUSLP"
;;; *       The pause flag can only be set during a running program, but
;;; *       S13 will be cleared, so this code set S13=1 again.

              ?s1=1                 ; pausing?
              gonc    CLRF10        ; no
              s13=    1             ; yes, set running flag
CLRF10:       s7=     0             ; clear alpha flag
              c=st
              regn=c  14
              gosub   RSTSQ         ; clear partial key seq, pausing, catalog
                                    ;   shift, data entry & message flags
              golong  ANNOUT

;;; **********************************************************************
;;; * CLKDSP - clock display                                  3-18-81 RSW
;;; *
;;; * IN: S0-S7= timer software status
;;; * ASSUME: nothing
;;; * OUT: P selected, hexmode, peripherals disabled
;;; * USES: A, B, C, G, N, R8[13:6], P, Q, S0, S2-S6, S8, +3 sub levels,
;;; *       arith mode, DADD, PFAD, timer PT
;;; *
;;; **********************************************************************

              .public CLKDSP
CLKDSP:       gosub   GDHMS         ; A= C= DDDDDDHHMMSSCC
              ?s7=1                 ; display time & date?
              golnc   DSPTIM        ; no, display hours, min & sec
              disoff
              gosub   DSPTMD        ; display hours, min & date
              distog                ; turn display on
              rtn


;;; **********************************************************************
;;; * TIME+1 - get incrementing time                          3-16-81 RSW
;;; *
;;; * IN & ASSUME: nothing
;;; * OUT: C= slightly future time
;;; *      hexmode
;;; *      timer chip enabled, RAM disabled, timer PT=A
;;; * USES: C, +1 sub level, DADD, PFAD, arith mode
;;; *       (no 41C PT, no ST)
;;; *
;;; **************
;;; * FTIME -- same as TIME+1 except:
;;; *                   IN & ASSUME: timer chip enabled, RAM disabled
;;; *                                timer PT=A
;;; *
;;; **********************************************************************

              .public `TIME+1`, FTIME
`TIME+1`:     gosub   ENTMR         ; enable timer chip, disable RAM, PT=A
FTIME:        rdtime                ; C= current time
              setdec
              c=c+1
              c=c+1
              sethex
              rtn


;;; **********************************************************************
;;; * TRUN -- "NFR" entry point                               3-10-81 RSW
;;; *    (only accessed when F13=1 or I/O flag=1)
;;; *
;;; * This entry point is accessed from the MFRS if some hardware is
;;; * pulling on F13 of the flag in line or if the I/O flag is set.
;;; * Partial key sequences can enter here if a key (or keys) are hit
;;; * and an alarm occurs before passing through tge NFRS.
;;; *
;;; **********************************************************************

              .fillto 0xd59
              .public TRUN
TRUN:         s8=     1
              goto    LSWK01

;;; *
;;; * TRUN10
;;; *
;;; * IN: S0-S7= timer software status
;;; *     timer chip enabled, RAM disabled, timer PT=B
;;; *     C[11]= timer scratch register B[11]= user flags 8-11
;;; *

TRUN10:       alarm?
              gonc    TRUN40        ; no, some other peripheral
              ?s0=1                 ; just came from DSWKNO?
              gonc    TRUN40        ; no, alarm came during a function
              a=c                   ; A[11]= user flags 8-11
              c=0
              dadd=c
              c=regn  14
              pt=     11
              acex    pt            ; restore user flags 8-11
              regn=c  14
              gosub   HWSTS         ; S0-S7= hardware status
                                    ;   C[1:0]= software status
              ?s0=1                 ; alarm A?
              gonc    TRUN35        ; no
              st=c                  ; S2= "run label" bit
              goto    TRUN55
TRUN35:       ?s4=1                 ; int timer alarm?
              gonc    TRUN50        ; no
              gosub   CLLCDE        ; yes, clear display
              s6=     1             ; don't put up default display
              s2=     0             ; clear "run label" bit
              goto    TRUN60
TRUN40:       gosub   CLRALD        ; clear "DSWKNO" bit, stop clock mode
TRUN50:       s2=     0             ; clear "run label" bit
TRUN55:       s6=     0             ; don't set message flag
TRUN60:       s0=     0             ; not light sleep
              golong  LSWK90

;;; **********************************************************************

              .public LSWK00
LSWK00:       s8=     0
;;; * Must not use more than 1 sub level due to partial key sequences
LSWK01:       m=c
              gosub   ENTMR         ; enable timer chip, PT=A
              gosub   INITM0        ; initialize timer if necessary, PT=B
              rdscr
              st=c                  ; put up software status
              ?s8=1                 ; called from TRUN?
              goc     TRUN10        ; yes
              alarm?
              goc     LSWK10        ; yes
              ?s4=1                 ; doing clock display?
LSWK05:       golong  RMRT01        ; no
              goto    LSWK6J        ; yes, end it
LSWK10:       pt=a                  ;  (save a sub level, partial key seq)
              rdsts
              cstex                 ; S0-S7= hardware status
                                    ; C[1:0]= software status
              ?s4=1                 ; int timer alarm?
              golnc   LSWK80        ; no, some other alarm
              cstex
              ?s3=1                 ; setting to clock mode?
              goc     LSWK15        ; yes
              ?s4=1                 ; doing clock display?
              gonc    LSWK65        ; no
LSWK15:       c=0     x             ; yes, check for evidence of a key down
              dadd=c
              c=regn  14
              rcr     1
              cstex
              ?s1=1                 ; message flags cleared?
              gonc    LSWK58        ; yes, a key went down
              ?s5=1                 ; partial key sequence?
              goc     LSWK58        ; yes, a key went down
              ?s6=1                 ; data entry flag set?
              goc     LSWK58        ; yes, a key went down
              cstex
              ?s3=1                 ; setting to clock mode?
              gonc    LSWK70        ; no, already esatblished
              gosub   CLKDSP        ; yes, put up clock display
              gosub   TMRSTS        ; S0-S7= timer software status
              s4=     1
              c=st
              pt=b
              wrscr                 ; update software status
                                    ;   (in case of alarm)
              pt=a
LSWK20:       rdtime                ; C= current time
              pt=     1
              ?c#0    wpt           ; on seconds transition?
              goc     LSWK25        ; no, hundreths non-zero
              ?s7=1                 ; yes, display minutes?
              gonc    LSWK28        ; no, start seconds wakeups
              gosub   SDHMSC        ; C= DDDDDDHHMMSSCC, PT= 3
              ?c#0    wpt           ; on minutes transition?
              goc     LSWK25        ; no, seconds non-zero
              c=0                   ; yes, start minutes wakeups
              lc      6             ; C= 60.00 seconds
              goto    LSWK30
LSWK25:       rdsts                 ; C= hardware status
              rcr     1             ; C.S= digit 0 of hardware status
              c=c+c   s             ; timer/stopwatch alarm?
              goc     LSWK85        ; yes
              ?c#0    s             ; alarm A?
              goc     LSWK85        ; yes
              ?lld                  ; low battery?
              golc    CLKOFF        ; yes, turn off
              chk kb                ; key down
              gonc    LSWK20        ; no
LSWK6J:       goto    LSWK60        ; end clock mode
LSWK28:       c=0
              c=c+1   xs            ; C= 1.00 seconds
LSWK30:       wsint                 ; write & start interval timer
              goto    LSWK67
LSWK58:       gosub   ENTMRS

LSWK60:       s4=     0             ; clear clock display bit
LSWK65:       stpint                ; stop interval timer
LSWK67:       s3=     0             ; clear setting to clock mode bit
              cstex
              pt=b
              wrscr                 ; update software status
LSWK70:       gosub   ENTMR         ; enable timer chip, disable RAM, PT=A

              .public LSWK80
LSWK80:       gosub   CLRAL0        ; clear interval timer/garbage alarms
LSWK85:       s0=     1             ; remember light sleep
              s2=     0             ; clear "run label" bit
              s6=     0

              .public LSWK90
LSWK90:       s1=     1             ; leave display on
              s7=     0             ; not PWOFF with no key


;;; **********************************************************************
;;; * ALM000 - alarm wakeup routine
;;; *
;;; * IN: S0= 1 (0)  (not) called from IOSERV entry point [light sleep]
;;; *     S1= 1 (0)  turn display on (off) at exit
;;; *     S2= 1 (0)  do (not) run oldest label alarm = "run label" bit
;;; *     S6= 1 (0)  do (not) set message flag
;;; *     S7= 1 (0)  called (not called) from PWOFF
;;; * OUT: does not return, goes to RMCK10 !!!!!!!
;;; * !!!! Must preserve M[10:3]= ROMCHK stuff !!!!!
;;; *
;;; * INTERNAL USE:
;;; *     S3         scratch
;;; *     S4= 1 (0)  (not) timer alarm
;;; *     S5= 1 (0)  the display has (not) been changed
;;; *     S8, S9     scratch
;;; *
;;; **********************************************************************

ALM000:       s4=     0             ; not timer alarm
              s5=     0             ; display not changed yet
              sethex
              gosub   ENTMR         ; save sub level (partial key seq)
              rdsts                 ; read hardware status
              cstex
              ?s0=1                 ; main clock?
              gonc    ALM032        ; no
              cstex
              ldi     0x38          ; clear alarm A, DTZ A, ALM B
              wrsts                 ; clear alarm A
              golong  ALM185

ALM032:       ?s3=1                 ; timer counted through zero?
              goc     ALM033        ; yes
              cstex
              golong  ALM230
ALM033:       st=c
              s4=     1             ; remember timer alarm
              ldi     0x31          ; clear timer alarm, DTZA, ALM B
              wrsts
              golong  ALM135


;;; **********************************************************************
;;; *                                                         2-24-81 RSW
;;; * GTALBL - get the alpha label from a label alarm message
;;; *
;;; * IN: nothing
;;; * ASSUME: M.X= alarm address
;;; *         hexmode, peripheral disabled
;;; *
;;; * OUT: jump to ALM116 if the alarm is not a label alarm
;;; *      jump to ALM045 if the alarm is a label alarm with:
;;; *         C= first 7 characters of the alarm message
;;; *           (The message is C-reg is read from right to left and is
;;; *            right justified [with zeros in unused character positions],
;;; *            which is the format required by the alpha search routine.)
;;; *    P selected, Q= 13
;;; *
;;; * USES: A, C, P, Q, DADD
;;; *       (no ST, +0 sub levels, no PFAD, no timer chip access)
;;; *
;;; **********************************************************************

              .public GTALBL
GTALBL:       c=m                   ; get alarm address
              a=c     x
              dadd=c
              c=data                ; load the alarm
              pt=     0
              c=c-1   pt            ; does the alarm have message?
              goc     GALB28        ; no, not a label alarm
              ?c#0    xs            ; has reset interval?
              gonc    GALB05        ; no
              a=a+1   x
GALB05:       a=a+1   x             ; point to 1st message reg
              rcr     1
              a=c     s             ; A.S= message length - 1
              c=a    x
              dadd=c                ; load 1st message reg
              c=data
              acex                  ; A= 1st msg reg, C= length & addr
              c=c-1   s             ; more than 1 reg?
              gonc    GALB10        ; yes
              c=0                   ; message only one reg long
              goto    GALB20
GALB10:       c=c+1   x
              dadd=c
              c=data                ; load 2nd message reg
GALB20:       acex                  ; C= 1st msg reg, A= 2nd msg reg
              sel q
              pt=     13
              sel p
              pt=     12
              c#0?                  ; whole reg= nulls?
GALB28:       golong  ALM116        ; yes, avoid locking up
GALB30:       ?c#0    pq            ; found first character?
              goc     GALB40        ; yes
              acex    pq
              asl
              asl
              rcr     12            ; move the char/null to C[1:0]
              goto    GALB30
GALB40:       rcr     12            ; C[1:0]= 1st char of message
              a=c     x
              ldi     94            ; ASCII code for up arrow
              acex    x
              pt=     1
              ?a#c    wpt           ; is 1st char an up arrow?
              goc     GALB28        ; no, not a label alarm
              rcr     2
              pt=     12
              acex    pq            ; replace "^" with next character
              rcr     12
              a=c                   ; reverse the string order
              c=0
GALB50:       acex    pq
              asl
              asl
              ?a#0    pq            ; all moved?
              gonc    GALB55        ; yes
              rcr     2
              goto    GALB50
GALB55:       pt=     1             ; right justify the string in C
              c#0?                  ; any label given?
              gsubc   RTJLBL        ; yes, right-justify alpha label

;;; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
;;; *
;;; * ALM045 -- the alarm is a label alarm                    3-11-81 RSW
;;; *
;;; * IN: hexmode
;;; *     C= Alpha label in right to left order and right justified.
;;; *         i.e., for "ABC", C= 0000CBA
;;; *     S13= 1 (0)  running (not running)
;;; *     S10= 1 (0)  current PC in ROM (RAM)
;;; *     M.X= valid alarm address  (of the label alarm)
;;; *

ALM045:       a=c                   ; A= alpha label
              gosub   TMRSTS        ; S0-S7= software ST, C[1:0]= temp ST
              s2=     0             ; clear "run label" bit
              b=c     x             ; B[1:0]= alarm temporary status
              pt=     1
              c=c+c   wpt           ; powoff? (?S7=1)
              gonc    ALM050        ; no
              disoff                ; turn display off
              s2=     1             ; set "run label" bit
ALM047:       gosub   `TIME+1`      ; C= slightly future time
              wralm
              enalm                 ; enable alarm
              golong  RMRT02

ALM050:       rcr     1             ; C.S= digit 0 of alarm temp status
              ldi     94            ; code for up arrow
              ?a#c    wpt           ; 2nd up arrow?
              goc     ALM052        ; no
              asr
              asr                   ; eliminate 2nd up arrow
              ?s11=1                ; stack lift flag set?
              goc     ALM060        ; yes, OK to run
              ?s13=1                ; no, running?
              goc     ALM047        ; yes, wait for S11=1
              goto    ALM060
ALM052:       c=c+c   s             ; run label alarm?
              goc     ALM060        ; yes
              c=b     x             ; C.X= alarm temporary status
              ?s0=1                 ; deep sleep wakeup?
              goc     ALM060        ; yes, run label alarm
              ?s4=1                 ; clock display?
              goc     ALM060        ; yes, run label alarm
              cstex                 ; ST= alarm temp status
              s4=     0             ; not a timer alarm
              ?s13=1                ; running a program?
              gonc    ALM116        ; no
              gosub   GETMXP        ; yes, C= alarm register, PT= 1
              lc      15            ; mark the alarm as activated
              data=c
              gosub   BEEP2         ; yes, beep twice
ALM055:       golong  ALM200


;;; **********************************************************************
;;; * ALM060 -- run a label program                           3-12-81 RSW
;;; *
;;; * IN: S0-S7= timer software status
;;; *     timer PT=B, hexmode
;;; *     timer chip enabled, RAM disabled
;;; *     A= alpha label in right to left order and right justified,
;;; *        i.e., for "ABC", C= 0000CBA
;;; *     B.X= alarm temporary status
;;; *     S13= 1 (0)  running (not running)
;;; *     S10= 1 (0)  current PC in ROM (RAM)
;;; *     M.X= valid alarm address (of the label alarm)
;;; *
;;; **********************************************************************

ALM060:       c=b     x             ; C[1:0]= alarm temporary status
              gosub   CLRALD        ; clear DSWKNO bit & end clock mode
              gosub   ENCP00
              ?s2=1                 ; called from ALMNOW?
              goc     ALM063        ; yes, honor the single-step flag
;;; * S2 can also be set when running a past due alarm after power off,
;;; * but the deep sleep wakeup will have cleared the SST flag already.

              c=regn  14
              cstex                 ; put up status set 0
              s4=     0             ; clear the single-step flag
              cstex
              regn=c  14            ; update register 14
ALM063:       acex                  ; C= alpha label

;;; *                                                         3-2-81 RSW
;;; * IN: hexmode, chip 0 enabled, peripheral disabled
;;; *     C= alpha label in right to left order and right justified,
;;; *        i.e., for "ABC", C= 0000CBA
;;; *     S13= 1 (0)  running (not running)
;;; *     S10= 1 (0)  current PC in ROM (RAM)
;;; *     M.X= valid alarm address (of the label alarm)
;;; *
              regn=c  9             ; reg 9= label
              gosub   ACKALM
              goto    ALM070        ; (P+1) alarm catalog empty or no higher
                                    ;       addressed alarms
              golong  LB_3863       ; (P+2)

              .public ALM065
ALM065:       gosub   `TIME+1`      ; C= slightly future time
              wralm                 ; set hardware alarm
              enalm                 ; enable alarm
;;; * !!! Must either set this alarm or set the next future alarm since
;;; *     "ACKALM" does not set the next future alarm.

;;; * IN: hexmode, R9= alpha label
              .public ALM070
ALM070:       ?s13=1                ; running?
              gsubnc  CLRFLG        ; no, clear misc flags
              gosub   LDSST0
              ?s3=1                 ; in program mode?
              gonc    ALM080        ; no
              s3=     0             ; yes, exit program mode
              c=st
              regn=c  14
              gosub   DECMPL        ; decompile program memory
ALM080:       rcr     11
              st=c
              s0=     0             ; clear user flag 11
              c=st
              rcr     3
              regn=c  14
              c=regn  9
              m=c                   ; M= alpha label
              c#0?                  ; any label given?
              golnc   RUN           ; no, run at current PC
              s9=     0
              golong  AXEQ          ; fall into mainframe alpha XEQ

;;; * IN: hexmode, peripherals disabled
;;; *     alarm temporary status set up
;;; *     M.X= !valid! current alarm address
              .public ALM116
ALM116:       ?s2=1                 ; run label alarm?
              goc     ALM055        ; yes
              gosub   GETMXP        ; C= alarm time & information, PT=1
              lc      15            ; mark the alarm
              data=c

              .public ALM135
ALM135:       c=m
              s5=     1             ; remember that display changed
              rcr     11
              c=st
              rcr     3
              m=c                   ; M[12:11]= alarm temporary status

;;; *                                                         2-25-81 RSW
;;; *          Alarm display code
;;; *
;;; * This code does the beeping and flashing when an alarm goes off.
;;; * If the user pushes a key, S6 is set = 0 (don't set message flag) since
;;; * the alarm message should go away if the alarm is acknowledged. If
;;; * a timeout occurs before a key is pushed, the clock display is
;;; * disabled (interval timer stopped and clock display bits S3=S4= 0)
;;; * and S6=1 so the alarm message will remain in the display.
;;; *
;;; * IN: M[12:11]= alarm temporary status,
;;; *        where S4= 1 (0) means alarm is (not) a timer/stopwatch alarm.
;;; * ASSUME: hexmode
;;; *         if S4= 0, then M.X= valid alarm address
;;; * OUT: peripherals disabled, alarm temporary status restored
;;; *   if no key:  alarm temporary status bit S6=1 to set message flag
;;; *               clear S2-S4 of timer software status
;;; *               stop interval timer & clear its alarm
;;; *               jump to ALM160
;;; *   if key down: alarm temporary stop bit S6=0 (don't set message flag)
;;; *                G= keycode
;;; * USES: A, B, C, G, M.S, N, R8[13:6], P, Q, S3,
;;; *       S6 of alarm temporary status, S8, S9, (maybe S13=1),
;;; *       +3 sub levels, DADD, PFAD, arith mode, timer PT
;;; *       if no key down, clears S2-S4 or timer ST

              gosub   CLRFLG
              disoff
              distog                ; be sure display is on
              gosub   BEEP2
              c=m
              rcr     11
              st=c
              ?s4=1                 ; timer alarm?
              gonc    DSPA10        ; no
              gosub   CLLCDE
              gosub   MESSL
              .messl  "TIMER ALARM "
              goto    DSPA20

DSPA10:       gosub   DSAMS0
              goto    DSPA15        ; (P+1) not message/label alarm
              goto    DSPA20        ; (P+2) message/label alarm
DSPA15:       gosub   DSTMDA        ; display time and date
              c=m
              rcr     11
              st=c                  ; restore alarm temporary status
DSPA20:       c=0     x
              pfad=c                ; disable display
              c=c-1   x
DSPA21:       c=c-1   x
              gonc    DSPA21        ; wait 1.3 sec
              gosub   RSTKB         ; clear keyboard
              c=m
              pt=     13
              lc      4             ; 4 sec flash before beeping
              s9=     0             ; not beeping

;;; * IN : hexmode
;;; *      C.S= timeout counter, rest of C= copy of M
;;; *      S4= 1 (0)  alarm is (not) a timer/stopwatch alarm
;;; *          if S4=1, then:  M.X= valid alarm address
;;; *      S9= 1 (0)  (not) beeping
;;; *

DSPA25:       disoff                ; turn off display
              m=c                   ; M.S= timeout counter
              ldi     241           ; wait 0.15 sec with dislay off
DSPA30:       chk kb                ; key down?
              goc     DSPA80        ; yes, check it out
              c=c-1   x
              gonc    DSPA30
              distog                ; turn display on
              ldi     806
              ?s9=1                 ; beeping?
              gonc    DSPA40        ; no, wait 0.5 sec with display on
              s8=     1             ; check keyboard
              gosub   BEEP2K        ; beep twice
              c=0     x             ; don't wait, just check keyboard
DSPA40:       chk kb                ; key down?
              goc     DSPA81        ; yes, check it out
              c=c-1   x
              gonc    DSPA40
              c=m
              c=c-1   s             ; timeout?
              gonc    DSPA25        ; no
              ?s9=1                 ; yes, beeping
              goc     DSPA60        ; yes
              s9=     1             ; no, beep
              goto    DSPA25        ; C.S= F from previous timeout
                                    ;  so beep&flash for 15 seconds
DSPA60:       s6=     1             ; no key down, set message flag
              ?s7=1                 ; poweroff?
              goc     ALM160        ; yes, don't stop clock mode
              gosub   TMRSTS
              gosub   CLRALS        ; clean any in timer alarm
                                    ;   & stop clock mode
              goto    ALM160

;;; * !!!! This is the "no key" exit from DSPALM !!!!
DSPA80:       distog                ; turn display on
DSPA81:       c=keys
              s6=     0             ; don't set msg flag, alarm acknowledge
              pt=     3
              g=c                   ; save keycode in G
              rcr     3
              pt=     1
              a=c     wpt           ; A= keycode
              golong  LB_32D2
              .public DSPA82
DSPA82:       ldi     0xc3          ; back arrow
              ?a#c    wpt           ; back arrow?
              gonc    DSPA97        ; yes
              b=0                   ; assume no message
              ?s4=1                 ; timer alarm?
              gosub   DSAMS0        ; no
              nop                   ; (P+1) no message
DSPA85:       gosub   RSTKBT        ; (P+2) wait for key up
              gosub   DSA2ND        ; display rest of message (if any)
              nop                   ; (P+1)
              c=0     x             ; (P+2)
              c=c-1   x
DSPA95:       chk kb                ; key down?
              goc     DSPA81        ; yes
              c=c-1   x
              gonc    DSPA95
DSPA97:       gosub   RSTKBT        ; clear keyboard

;;; * !!! This is the "key down" exit from DSPALM !!!!
;;; *        (except the "ON" key branch to ALM169)
;;; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

              gosub   OFSHFT10
              ?s4=1                 ; was it a timer alarm?
              goc     ALM168        ; yes
              pt=     0
              c=g
              c=0     xs
              a=c     x             ; A.X= hardware keycode
              ldi     0x72          ; "STO" keycode
              ?a#c    x             ; STO key hit?
              goc     ALM170        ; no
ALM160:       ?s4=1                 ; timer alarm?
              gonc    ALM200        ; no
ALM168:       golong  ALM230        ; yes, timer alarm

              .public ALM169
ALM169:       ?s7=1                 ; poweroff path?
              gonc    DSPA97        ; no
              s4=     1             ; don't display any more alarms
              gosub   ALM200        ; set new hardware alarm
                                    ;  (if not alarm is going off)
              goto    ALM168        ; return to ROMCHK
ALM170:       gosub   ACKALM     ; reset alarm if it has interval

;;; * !! Note: ACKALM uses 4 sub levels, so must not display alarms if
;;; *          it is desired to exit this alarm code with a RTN (S4=1) !!!!

              goto    ALM210        ; (P+1) no more alarms, or no higher
                                    ;    addressed alarms
              .public ALM171
ALM171:       c=m                   ; (P+2) C.X= current alarm address
              goto    ALM220

;;; **********************************************************************
;;; * ALMNOW
;;; **********************************************************************

              .name   "ALMNOW"
              .public ALMNOW, NXTALM
ALMNOW:       gosub   INITMR        ; initialize timer chip if necessary
              s11=    1             ; set stack lift flag
              clr     st            ; not powoff with no key down
              s2=     1             ; set "run label" bit
NXTALM:       s4=     1             ; return and don't display
              sethex

;;; *
;;; * .    .    .    .    .    .    .    .    .    .    .    .    .    .
;;; *

              .public ALM185
              .public ALM210
ALM185:       gosub   SRHBUF        ; no, find beginning of alarm stack
              goto    ALM215        ; (P+1) buffer found
              goto    ALM210        ; (P+2) buffer not found

              .public ALM200
ALM200:       gosub   ALMSST        ; single step to next alarm
              goto    ALM220        ; (P+1) C.X= M.X= next alarm address
ALM210:       gosub   ENTMR         ; enable timer chip, PT=A
              a=0                   ; set alarm to 0 so it will never go off
              goto    ALM225

ALM215:       a=a+1   x             ; A.X= address of first alarm
              gosub   `NEWM.X`      ; C.X= M.X= address of first alarm

ALM220:       dadd=c
              c=data
              bcex    x             ; B.X= alarm information
              c=0     x
              rcr     2
              a=c                   ; A= alarm time= 00SSSSSSSSSSC0
              gosub   ENTMR         ; enable timer chip, disable RAM, PT=A

;;; * Save sub levels for partial key sequences !!!!!
              gosub   FTIME         ; C= slightly future time
              a<c?                  ; is alarm really past due?
              gonc    ALM225        ; no, set future alarm
              ?s2=1                 ; run label alarm?
              goc     ALM222        ; yes
              ?s4=1                 ; called from XYZALM?
              goc     ALM200        ; yes, don't display alarm
              ?s7=1                 ; poweroff?
              goc     ALM222        ; yes, display past due alarms
              pt=     1
              ?b#0    pt            ; alarm already displayed?
              goc     ALM200        ; yes, don't display it again
ALM222:       golong  GTALBL


;;; * Set alarm in timer chip                                 3-19-81 RSW
;;; *
;;; * IN: A= 00SSSSSSSSSSC0 = alarm time
;;; *     timer chip enabled, RAM disabled, timer PT=A, hexmode
;;; *     temporary alarm status set up (S0, S2, S4, S6 specifically)

ALM225:       ?s4=1                 ; suppressing alarm display?
              gonc    ALM226        ; no, displaying alarms
              rdsts                 ; C= hardware status

;;; *
;;; * Note: An alarm can't go off at this point and be missed. It would
;;; *       have to been judged to be past due in the previous test
;;; *       (but really was 1/100 sec in the future) and it takes more
;;; *       than 1/100 sec to single step to the next alarm and get here
;;; *       to set it.

              cstex
              ?s0=1                 ; main clock alarm?
              gonc    AL225B        ; no
              st=c
              rtn
AL225B:       st=c                  ; restore status
ALM226:       acex                  ; C= alarm
              wralm                 ; store alarm
              enalm                 ; enable the alarm
ALM227:       ldi     0x38          ; clear all alarms except
              wrsts                 ;  timer, int timer & PUS
              ?s4=1                 ; called from XYZALM?
              rtn c                 ; yes, done

;;; * IN: hexmode, alarm temporary status set up (S0, S2, S4, S6 specifically)
;;; *     M[10:3]= copy of C[10:3] at entry from ROMCHK

              .public ALM230
ALM230:       disoff                ; display off
              ?s1=1                 ; turn display on?
              gonc    ALM232
              distog                ; yes, display on
ALM232:       gosub   ENCP00
              ?s6=1                 ; no, displaying alarm msg?
              goc     ALM270        ; yes, set message flag
              ?s13=1                ; called in running program?
              golc    RUN           ; put the goose back in the display
              ?s0=1                 ; called from light sleep?
              gonc    RMRT00        ; no
              gosub   TMRSTS        ; yes, put up software status
              ?s4=1                 ; do clock display?
              goc     ALM260        ; yes
              cstex
              ?s5=1                 ; has the display been changed?
              gonc    RMRT00        ; no
              golong  NFRC          ; refresh the display

ALM260:       ?lld                  ; low battery?
              golc    CLKOFF        ; yes, turn off
              gosub   CLKDSP        ; put up clock display
ALM270:       gosub   STMSGF        ; set message flag

;;; * IN: M[10:3]= copy of C[10:3] at entry from ROMCHK

              .public RMRT01, RMRT02
RMRT00:       gosub   TMRSTS
RMRT01:       s2=     0             ; clear "run label" bit
RMRT02:       s0=     0             ; clear "DSWKNO" bit
              c=st
              pt=b
              wrscr
ROMRTN:       sethex
              sel p
              gosub   LDSST0
RMRT05:       c=m
              golong  RMCK10

;;; **********************************************************************
;;; *
;;; * Deep sleep wake up with no key down                     2-24-81 RSW
;;; *
;;; **********************************************************************
;;; *
;;; * If there is an alarm:
;;; *    - sets I/O flag to stay awake
;;; *    - sets DSWKNO bit in timer software status
;;; *    - saves user flags 8-11 in scratch reg B[11]
;;; *    - clears user flags 8-11
;;; *

              .public DSWKNO
DSWKNO:       m=c                   ; save C in M
              c=regn  14
              bcex                  ; B= reg 14
              gosub   INITMR        ; initialize timer if necessary
              alarm?
              gonc    ROMRTN        ; return to ROMCHK
              rdscr                 ; C= software status
              st=c                  ; put up software status
              s0=     1             ; remember DSWKNO
              c=st
              pt=     11
              c=b     pt            ; save user flags 8-11
              wrscr                 ;   (11 = auto run flag)
              gosub   LDSST0
              s2=     1             ; set I/O flag to stay awake
              c=st
              c=0     pt            ; clear user flags 8-11
              regn=c  14
              goto    RMRT05


;;; **********************************************************************
;;; * Power off entry point                                   3-19-81 RSW
;;; **********************************************************************

              .public PWOF00
PWOF00:       gosub   INITMM        ; initialize timer if necessary
              rdscr                 ; C= timer software status
              st=c                  ; put up software status
              s2=     0             ; clear run label bit
              s0=     0             ; clear "DSWKNO" bit
              gosub   ENLCD
              readen                ; read annunciators
              rcr     2             ; move shift annunciator to C.S
              gosub   ENTMR         ; enable timer chip, disable RAM
              pt=b
              c=c+c   s             ; shift annunciator set?
              gonc    PWOF20        ; no
              s3=     1             ; yes, setting clock mode
              c=0
              goto    PWOF05

ENBNK1:       enrom1
              rtn
ENBNK2:       enrom2
              rtn

PWOF05:       c=c+1
              wsint                 ; write and start interval timer
PWOF10_relay: golong  PWOF10

PWOF20:       ?s4=1                 ; doing clock display?
              gonc    PWOF10_relay  ; no
              gosub   CLRALS        ; end clock mode
RMRTN:        goto    ROMRTN


;;; **********************************************************************
;;; * Wake up from deep sleep  (polled every time)            3-4-81 RSW
;;; **********************************************************************

DSWKON:       m=c                   ; save reg-C in M
;;; *
;;; * Reclaim the timer I/O buffer
;;; *
              gosub   SRHBFI        ; search for timer buffer
              goto    TDSWK3        ; (P+1) found the timer buffer
              goto    RMRTN         ; (P+2)

TDSWK3:       pt=     13
              lc      10            ; C= AA...
              data=c                ; reclaim the timer I/O buffer
              gosub   TMRSTS        ; put up software status
              ?s0=1                 ; from DSWKNO?
              goc     RMRTN         ; yes, don't beep
              gosub   CHKALM        ; look for past due alarms
              ?b#0    xs            ; any past due alarms?
              gsubnc  BEEP2         ; yes, beep twice
              goto    RMRTN

TMRUN:        golong  TRUN
DPWKNK:       golong  DSWKNO

;;; * Entry point for PIL printer to print time & date
;;; *
;;; * The timer code must only use:
;;; *  A, B, C, G, M, N, R8[13:6], P, Q, S0-S8, +3 sub levels
;;; *
;;; * IN: nothing
;;; *

              gosub   IGDHMS        ; initialize: get days, hours, min, secs
              gosub   DSPTMD
;;; * !! Must be in hexmode at this point !!!!!!
              golong  TMRMSG        ; PIL printer, print display

PWROFF:       golong  PWOF00
LSWKUP:       golong  LSWK00
              nop                   ; pause loop
              goto    TMRUN         ; main running loop
              goto    DPWKNK        ; wkup from deep sleep w/no key
              goto    PWROFF        ; power off entry location
              goto    LSWKUP        ; I/O service entry location
              goto    DSWKON        ; deep sleep startup entry location
              nop                   ; cold start entry location
              .con    3             ; Rev C
              .con    '2'           ; Rev 2
              .con    0x200 + 13    ; bank switched + M
              .con    20            ; T
              .con    0             ; checksum position
