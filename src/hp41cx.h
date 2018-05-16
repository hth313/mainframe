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

              .extern `115860`
              .extern `36000`
              .extern `A-DHMS`
              .extern ACKALM
              .extern ACT120
              .extern ACT125
              .extern ACT170
              .extern ADATE
              .extern ADJ100
              .extern ADR608
              .extern ADRENT
              .extern ADVAD1
              .extern ADVADR
              .extern ADVREB
              .extern ADVREC
              .extern ALEN
              .extern ALM065
              .extern ALM070
              .extern ALM116
              .extern ALM135
              .extern ALM169
              .extern ALM171
              .extern ALM185
              .extern ALM200
              .extern ALM210
              .extern ALM230
              .extern ALMBST
              .extern ALMCAT
              .extern ALMNOW
              .extern ALMSST
              .extern ALNAM2
              .extern ANUM2
              .extern APCH10
              .extern APEREX
              .extern APERMG
              .extern APOS10
              .extern APOSNF
              .extern APPCHR
              .extern APPREC
              .extern APRC10
              .extern ARCLRC
              .extern AROT2
              .extern ASROOM2
              .extern ATD120
              .extern ATD125
              .extern ATIME
              .extern ATIME24
              .extern BEEP2
              .extern BEEP2K
              .extern BEEPK
              .extern BEEPKP
              .extern BEEPNK
              .extern BEPI
              .extern `BIN-D3`
              .extern `BIN-D`
              .extern BYTLFT
              .extern `C-YMDD`
              .extern `C=T+D0`
              .extern `C=T+D`
              .extern CALCRA
              .extern CALCRC
              .extern CAT2CX
              .extern CAT2CX_10
              .extern CAT2CX_20
              .extern CAT2_
              .extern CAT_END3
              .extern CAT_STOP
              .extern CHECK
              .extern CHECKX
              .extern CHKALM
              .extern CHKBUF
              .extern CHKLB
              .extern CHKLB2
              .extern CHKXM
              .extern CLALMA2
              .extern CLALMX2
              .extern CLK12
              .extern CLK24
              .extern CLKDSP
              .extern CLKEYS2
              .extern CLKOFF
              .extern CLKT
              .extern CLKTD
              .extern CLOCK
              .extern CLOCK2
              .extern CLRAL0
              .extern CLRALD
              .extern CLRALM
              .extern CLRALMS2
              .extern CLRALS
              .extern CLRALW
              .extern CLRFL
              .extern CLRFL
              .extern CLRFLG
              .extern CLRGX2
              .extern CNTBY7
              .extern CNTBYE
              .extern CORRECT
              .extern CRFLAS
              .extern CRFLD
              .extern `CUR#`
              .extern `CUREC#`
              .extern CURFL
              .extern CURFLD
              .extern CURFLR
              .extern CURFLT
              .extern CXCAT
              .extern DATE
              .extern DATECK
              .extern DATEIN
              .extern DAYMD
              .extern DAYMDF
              .extern DDATE2
              .extern DDAYS2
              .extern DELCHR
              .extern DELREC
              .extern DIFF
              .extern DISERR
              .extern DLRC30
              .extern DLRC50
              .extern DMY
              .extern DSA2ND
              .extern DSAMS0
              .extern DSAMSG
              .extern DSPA82
              .extern DSPDT
              .extern DSPDTA
              .extern DSPINT
              .extern DSPTIM
              .extern DSPTM
              .extern DSPTMD
              .extern DSPTMM
              .extern DSPTMP
              .extern DSPTMR
              .extern DSTMDA
              .extern DSWEEK
              .extern DSWEKA
              .extern DSWKNO
              .extern DUPFER
              .extern ED
              .extern ED2
              .extern EFLS02
              .extern EFLSCH
              .extern EMDIR
              .extern EMDIR2
              .extern EMDIRX2
              .extern EMDR10
              .extern EMDR15
              .extern EMROOM
              .extern EMROOM2
              .extern ENB1GO
              .extern ENB1GOH
              .extern END2CX
              .extern ENRGAD
              .extern ENTMR
              .extern ENTMR
              .extern ENTMRS
              .extern EOFL
              .extern FAHED
              .extern FILNER
              .extern FLNOFN
              .extern FLSHAB
              .extern FLSHAC
              .extern FLSHAP
              .extern FLTPER
              .extern FNDEOB
              .extern FNDMSG
              .extern FNDPIL
              .extern FSCHP
              .extern FSCHT
              .extern FTIME
              .extern GDHMS
              .extern GETAF
              .extern GETAS
              .extern GETAS2
              .extern GETKEY2
              .extern GETKEYX
              .extern GETKEYX2
              .extern `GETM.X`
              .extern GETMR
              .extern GETMRC
              .extern GETMXP
              .extern GETP
              .extern GETP2
              .extern GETR
              .extern `GETR#M`
              .extern `GETR#`
              .extern GETREC
              .extern GETRX
              .extern GETSUB
              .extern GETXX
              .extern GFLG31_2
              .extern GTALBL
              .extern GTFLNA
              .extern GTFRA
              .extern GTFRAB
              .extern GTIND2
              .extern GTINDX
              .extern GTMR30
              .extern GTPRAD
              .extern GTPRNA
              .extern `GTR#MC`
              .extern GTRC05
              .extern `HM-SC`
              .extern HMSEC1
              .extern HMSS20
              .extern HMSS40
              .extern HMSSCB
              .extern HMSSEC
              .extern HWSTS
              .extern IDVD
              .extern IDVD4
              .extern IGDHMS
              .extern INCR20
              .extern INITM1
              .extern INITMM
              .extern INITMR
              .extern `INREC#`
              .extern INSCHR
              .extern INSREC
              .extern INTVAL
              .extern ITMRST
              .extern `KEY-FC2`
              .extern KEYCHK
              .extern LB_263C
              .extern LB_3194
              .extern LB_321D
              .extern LB_3242
              .extern LB_325C
              .extern LB_3260
              .extern LB_3298
              .extern LB_3299
              .extern LB_32C5
              .extern LB_32D2
              .extern LB_333E
              .extern LB_33E9
              .extern LB_33EE
              .extern LB_33F5
              .extern LB_3581
              .extern LB_3583
              .extern LB_3698
              .extern LB_36B7
              .extern LB_3790
              .extern LB_3837
              .extern LB_3863
              .extern LB_386F
              .extern LB_3879
              .extern LB_38D6
              .extern LB_38F4
              .extern LB_3B10
              .extern LB_3B14
              .extern LB_556C
              .extern LB_563F
              .extern LB_5A4F
              .extern LSWK00
              .extern LSWK80
              .extern LSWK90
              .extern M306
              .extern MDY
              .extern NDAYS
              .extern NEWLOC
              .extern NEWLSK
              .extern `NEWM.X`
              .extern NOREGCX
              .extern NORM
              .extern NORMC
              .extern NORMEX
              .extern NOROOM
              .extern NO_ROOM
              .extern `NWREC#`
              .extern NXCH30
              .extern NXCHR
              .extern NXREG
              .extern NXTALM
              .extern NXTMDL
              .extern OFSHFT10
              .extern PAKEXM
              .extern PASN10
              .extern PASNER
              .extern PCLPS2
              .extern POSA2
              .extern POSFL
              .extern PSIZ10_2
              .extern PUFLSB
              .extern PUGA10
              .extern PUGALM
              .extern PURFL
              .extern PUTAPH
              .extern `PUTR#`
              .extern PWOF00
              .extern PWOF10
              .extern `R-TO-S`
              .extern `R9=T`
              .extern RCLAF
              .extern RCLALM2
              .extern RCLP30
              .extern RCLPT
              .extern RCLPTA
              .extern RCLSW
              .extern `REG#`
              .extern REGMOV
              .extern REGSWP
              .extern RESZFL
              .extern RESZFL2
              .extern RFLSCH
              .extern RGMV
              .extern RMAD_PAGE3
              .extern RMCK03
              .extern RMCK10_B1
              .extern RMRT01
              .extern RMRT02
              .extern RNGERR
              .extern RP330
              .extern RSTALM
              .extern RSTKBT
              .extern RSTKCA
              .extern `RTNP+2`
              .extern RUNST2
              .extern RUNSW
              .extern SAPHS5
              .extern SAPHSB
              .extern SAVEAS
              .extern SAVEAS2
              .extern SAVEP
              .extern SAVEP2
              .extern SAVER
              .extern SAVERX
              .extern SAVEX
              .extern SDATE
              .extern SDHMSC
              .extern SDHMSK
              .extern SEEKP2
              .extern SEKPT
              .extern SEKPTA
              .extern SETAF
              .extern SETAF0
              .extern SETIME
              .extern SETSW
              .extern SHFTDN
              .extern SKPAL1
              .extern SKPALC
              .extern SKPALM
              .extern SRHBFI
              .extern SRHBUF
              .extern STOFLAG2
              .extern STOPS1
              .extern STOPSW
              .extern STRCAB
              .extern SUM3D5
              .extern SW
              .extern `SWPM&D`
              .extern SWPT2
              .extern `T+X`
              .extern `T=T+TP`
              .extern TENT35
              .extern TERR20
              .extern TERR50
              .extern TERROR
              .extern TGLS10
              .extern TGLSHF
              .extern TGLSHF2
              .extern TIME
              .extern `TIME+1`
              .extern TM10
              .extern TM20
              .extern TMEXIT
              .extern TMR00
              .extern TMR00K
              .extern TMR01
              .extern TMRCHK
              .extern TMREEX
              .extern TMRENT
              .extern TMRKEY
              .extern TMRRCL
              .extern TMRSHF
              .extern TMRST
              .extern TMRSTS
              .extern TMSG
              .extern TO12H
              .extern TO24H
              .extern TOBNK1
              .extern `TOREC#`
              .extern TRUN
              .extern TXTE10
              .extern TXTEND
              .extern UNNOR1
              .extern UNNOR2
              .extern UNNORM
              .extern UNNORX
              .extern UPRCAB
              .extern WAITK6
              .extern WAITKD
              .extern WKDAYS
              .extern WRT260
              .extern `X-YMDD`
              .extern `X<256`
              .extern `X<999`
              .extern `X<=NN? 2`
              .extern `X<NN? 2`
              .extern `X=NN? 2`
              .extern `X>=NN? 2`
              .extern `X>NN? 2`
              .extern `X≠NN? 2`
              .extern X20
              .extern X20Q
              .extern X20Q8
              .extern XPOAFN2
              .extern XPOANF2
              .extern XTOA
              .extern XYZALM
              .extern YMDDAY
