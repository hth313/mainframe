#include "hp41cv.h"

AOUTIN:       .equlab 0x72b6
CHKPCT:       .equlab 0x7d0c
FLSCH:        .equlab 0x780b
FLSCHX:       .equlab 0x780e
FLTYER:       .equlab 0x788a
IAUALL:       .equlab 0x6db3
OUTPCT:       .equlab 0x63dd
PRTLCD:       .equlab 0x6bb9
RDDFRM:       .equlab 0x7110
REWENT:       .equlab 0x7c65
SDATA0:       .equlab 0x7126
SDATA:        .equlab 0x7128
SEEKRN:       .equlab 0x7f77
SEKSUB:       .equlab 0x70d6
SNDATA:       .equlab 0x70e6
TALKER:       .equlab 0x70b2
TMRMSG:       .equlab 0x6e5c
UNL:          .equlab 0x70af
UNT:          .equlab 0x70ac
UNTCHK:       .equlab 0x77e5
WAITS:        .equlab 0x741a

              .extern `X=NN? 2`
              .extern `X≠NN? 2`
              .extern `X<=NN? 2`
              .extern `X<NN? 2`
              .extern `X>=NN? 2`
              .extern `X>NN? 2`
              .extern PAKEXM
              .extern `CUR#`
              .extern ACKALM
              .extern ACT120
              .extern TOBNK1
              .extern ALEN
              .extern EOFL
              .extern ACT125
              .extern ACT170
              .extern ADATE
              .extern ADJ100
              .extern ADR608
              .extern `BIN-D`, `BIN-D3`
              .extern FAHED
              .extern NOREGCX
              .extern RUNST2
              .extern PUFLSB
              .extern DUPFER
              .extern ADRENT
              .extern ADVADR, ADVAD1
              .extern ADVREC, ADVREB
              .extern ALM116
              .extern ALM135
              .extern ALM185
              .extern ALM200
              .extern ALM210
              .extern PUGA10
              .extern ALM230
              .extern ALMBST
              .extern ALMCAT
              .extern ALMNOW, NXTALM
              .extern ALMSST, `NEWM.X`
              .extern ANUM2
              .extern APOS10
              .extern APPCHR, APCH10
              .extern APPREC, APRC10
              .extern ARCLRC
              .extern AROT2
              .extern ASROOM2
              .extern ATD120, ATD125
              .extern ATIME
              .extern ATIME24
              .extern BEEP2, BEEP2K, BEEPKP, BEEPK, BEEPNK
              .extern BEPI
              .extern BYTLFT
              .extern CHKALM
              .extern CHKBUF
              .extern CHKLB
              .extern CHKLB2
              .extern CHKXM, CHECKX, CHECK
              .extern CLK12
              .extern CLK24
              .extern CLKDSP
              .extern CLKEYS2
              .extern CLKOFF
              .extern CLKT
              .extern CLKTD
              .extern CLOCK
              .extern CLOCK2
              .extern CLRALD, CLRALS, CLRALW, CLRALM, CLRAL0
              .extern CLRFL
              .extern CLRFL
              .extern CLRFLG
              .extern CLRGX2
              .extern CNTBYE, CNTBY7
              .extern CORRECT
              .extern CRFLD, CRFLAS
              .extern CURFL, CURFLD, CURFLT, CURFLR, EFLS02
              .extern DATE
              .extern DATECK
              .extern DATEIN
              .extern DAYMD
              .extern DAYMDF
              .extern DDAYS2
              .extern CLALMX2
              .extern DELCHR, DELREC, DLRC30, DLRC50
              .extern LB_33F5
              .extern LB_33EE
              .extern CAT2CX, CAT2_, CXCAT
              .extern CAT2CX_10, CAT2CX_20, END2CX
              .extern LB_325C
              .extern LB_386F
              .extern LB_3837
              .extern LB_3194
              .extern LB_3698
              .extern LB_3B10
              .extern RMCK10_B1
              .extern NXCH30
              .extern DIFF
              .extern DISERR, APERMG, APEREX
              .extern DMY
              .extern DSA2ND
              .extern DSAMS0, DSAMSG
              .extern DSPDT, DSPDTA
              .extern DSPINT
              .extern DSPTM
              .extern DSPTMM
              .extern DSPTMR
              .extern DSTMDA, DSPTMD, DSPTIM, DSPTMP
              .extern DSWEEK
              .extern DSWEKA
              .extern DSWKNO
              .extern ED
              .extern ED2
              .extern EFLSCH, FSCHT, FSCHP, RFLSCH
              .extern EMDIR
              .extern EMDIRX2
              .extern EMROOM
              .extern EMROOM2
              .extern ENRGAD
              .extern ENTMRS, ENTMR
              .extern FILNER
              .extern FLSHAP, FLSHAB, FLSHAC
              .extern FNDEOB
              .extern FNDMSG
              .extern FNDPIL
              .extern GETAF
              .extern GETAS
              .extern GETAS2
              .extern GETKEY2
              .extern GETKEYX
              .extern GETMR, GETMRC, ENTMR
              .extern GETMXP, `GETM.X`
              .extern GETREC
              .extern GETSUB, GETP
              .extern GETXX, SAVEX
              .extern GFLG31_2
              .extern GTALBL
              .extern GTFRA, GTFRAB
              .extern GTINDX, GTIND2
              .extern GTMR30
              .extern GTPRNA, GTPRAD, GTFLNA, ALNAM2
              .extern GTRC05
              .extern HMSS40
              .extern HMSSCB, HMSSEC, HMSS20, HMSEC1
              .extern HWSTS
              .extern IDVD, IDVD4
              .extern IGDHMS, GDHMS
              .extern INITMM, INITMR, INITM1
              .extern INSCHR
              .extern INSREC, INCR20
              .extern INTVAL
              .extern ITMRST
              .extern KEYCHK
              .extern LB_32C5
              .extern LSWK00
              .extern LSWK80
              .extern LSWK90
              .extern M306
              .extern MDY
              .extern NDAYS
              .extern NEWLSK, NEWLOC
              .extern NO_ROOM
              .extern NORM, NORMC
              .extern NORMEX
              .extern NOROOM
              .extern NXCHR, NXREG
              .extern NXTMDL
              .extern PASN10
              .extern PCLPS2
              .extern POSA2, XPOANF2, XPOAFN2
              .extern POSFL
              .extern PSIZ10_2
              .extern PUGALM
              .extern PURFL
              .extern PUTAPH
              .extern PWOF00
              .extern RCLAF
              .extern RCLALM2
              .extern RCLPTA, RCLPT, RCLP30
              .extern RCLSW
              .extern REGSWP, REGMOV
              .extern RESZFL
              .extern RGMV
              .extern RMRT01, RMRT02
              .extern RNGERR
              .extern RP330
              .extern RSTALM
              .extern RSTKBT
              .extern RSTKCA
              .extern RUNSW
              .extern SAPHSB, SAPHS5
              .extern SAVEAS
              .extern SAVEAS2
              .extern SAVEP
              .extern SAVEP2
              .extern SAVER, GETR
              .extern SAVERX, GETRX
              .extern SDATE
              .extern SDHMSK, SDHMSC
              .extern SEEKP2
              .extern SEKPTA, SEKPT
              .extern SETAF, SETAF0
              .extern SETIME
              .extern SETSW
              .extern SHFTDN
              .extern SKPALC, SKPALM, SKPAL1
              .extern SRHBFI, SRHBUF
              .extern STOFLAG2
              .extern STOPSW
              .extern SUM3D5
              .extern SW, TM10, TM20
              .extern TENT35
              .extern TERR20
              .extern TERR50
              .extern TERROR
              .extern TGLSHF
              .extern TGLSHF2
              .extern TIME
              .extern TMEXIT
              .extern TMR00, TMR01
              .extern TMR00K
              .extern TMRCHK
              .extern TMREEX
              .extern TMRENT
              .extern TMRKEY
              .extern TMRRCL
              .extern TMRSHF
              .extern TMRSTS, TMRST
              .extern ENB1GOH, ENB1GO
              .extern FLTPER, FLNOFN
              .extern TMSG
              .extern TO12H
              .extern TO24H
              .extern TRUN
              .extern TXTEND, `CUREC#`, `TOREC#`, TXTE10
              .extern UNNORX, UNNOR1, UNNOR2, UNNORM
              .extern TGLS10
              .extern LB_3863
              .extern LB_32D2
              .extern PWOF10
              .extern CLRALMS2
              .extern LB_3242
              .extern LB_3260
              .extern LB_3299
              .extern LB_33E9
              .extern LB_3B14
              .extern EMDR10, EMDR15
              .extern CAT_STOP
              .extern CAT_END3
              .extern LB_38D6
              .extern LB_36B7
              .extern STOPS1
              .extern RMCK03
              .extern OFSHFT10
              .extern LB_3298
              .extern WAITK6, WAITKD
              .extern WKDAYS
              .extern WRT260
              .extern X20Q8, X20Q, X20
              .extern XTOA
              .extern XYZALM
              .extern `115860`
              .extern `36000`
              .extern `A-DHMS`
              .extern `C-YMDD`
              .extern `C=T+D`, `C=T+D0`
              .extern DDATE2
              .extern PASNER
              .extern `GTR#MC`, `GETR#M`, `GETR#`
              .extern `HM-SC`
              .extern `KEY-FC2`
              .extern `NWREC#`, UPRCAB, STRCAB, `INREC#`
              .extern `PUTR#`
              .extern `R-TO-S`, CALCRA, CALCRC
              .extern `R9=T`
              .extern `REG#`
              .extern `RTNP+2`
              .extern `SWPM&D`
              .extern `T+X`
              .extern `T=T+TP`
              .extern `TIME+1`, FTIME
              .extern `X-YMDD`, YMDDAY
              .extern `X<256`, `X<999`
              .extern LB_321D
              .extern ALM169
              .extern DSPA82
              .extern LB_563F
              .extern LB_556C
              .extern CLALMA2
              .extern SWPT2
              .extern LB_38F4
              .extern LB_3581, LB_3583
              .extern LB_333E
              .extern LB_3790
              .extern APOSNF
              .extern GETP2
              .extern ALM065
              .extern ALM070
              .extern LB_263C
              .extern LB_5A4F
              .extern RESZFL2
              .extern GETKEYX2
              .extern EMDIR2
              .extern ALM171
              .extern LB_3879
              .extern RMAD_PAGE3
