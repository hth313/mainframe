;;; LEGAL appears to be a directive that says I know what
;;; I am doing with carry here. Not implemented by asnut,
;;; so we just accept it.

#define legal

;;; Printer entry points
PRT1:         .equlab 0X6FED
PRT2:         .equlab 0X6FEB
PRT3:         .equlab 0X6FE9
PRT4:         .equlab 0X6FE7
PRT5:         .equlab 0X6FE5
PRT6:         .equlab 0X6FE3
PRT7:         .equlab 0X6FE1
PRT8:         .equlab 0X6FDF
PRT9:         .equlab 0X6FDD
PRT10:        .equlab 0X6FDB
PRT11:        .equlab 0X6FD9
PRT12:        .equlab 0X6FD7
PRT13:        .equlab 0X6FD5
PRT14:        .equlab 0X6FD3
PRT15:        .equlab 0X6FD1

xdef          .macro X
              .con  .low10 \X
              .endm

              .extern ABS, ACOS, AD1_10, AD2_10, AD2_13, ADDONE, ADRFCH, ADVNCE
              .extern AFORMT, AGTO, ALCL00, ALPDEF, ANNOUT, ANN_14, AOFF, AON
              .extern ALLOK
              .extern APND10, APNDDG, APNDNW, APND_, ARCL, ARGOUT, ASCLCD, ASCLCA
              .extern ASHF, ASIN, ASN, ASRCH, ASTO, ATAN, AVAILA, AVIEW, AXEQ
              .extern BAKAPH, BCDBIN, BEEP, BLINK, BLINK1, BRT100, BST, BSTCAT
              .extern BSTEP, BSTEPA, BIND25
              .extern CALDSP, CAT, CAT3, CF, CHKADR, CHKRPC, CHK_NO_S
              .extern CHK_NO_S2, CHS, CLA, CLCTMG, CLDSP, CLLCDE, CLP, CLR
              .extern CLREG, CLRPGM, CLRSB2, CLRSB3, CLSIG, CLST, CLX
              .extern CLRLCD
              .extern CNTLOP, COLDST, COPY, COS, CPGMHD
              .extern DAT106, DAT231, DAT320, DATENT, DATOFF, DCPL00, DCPLRT
              .extern DCRT10, DEC, DECAD, DECADA, DECMPL, DEG, DEL, DELETE
              .extern DELLIN, DELNNN, DERUN, DF060, DF150, DFILLF, DFKBCK
              .extern DIGENT
              .extern DFRST8, DFRST9, DGENS8, DIGST_, DIV120, DIV15, DIVIDE
              .extern DRSY05, DRSY25, DRSY50, DRSY51, DSE, DSPCRG, DTOR
              .extern DV1_10, DV2_10, DV2_10, DV2_13, D_R
              .extern ENCP00, END, END2, END3, ENG, ENLCD, ENTER, ERR0
              .extern ERR120, ERRAD, ERRDE, ERRIGN, ERRNE, ERROF, ERROR, EXP10
              .extern EXSCR, E_TO_X, E_TO_X_MINUS_1
              .extern FACT, FC, FC_C, FIX, FIXEND, FLINK, FLINKA, FLINKP
              .extern FNDEND
              .extern FORMAT, FRAC, FS, FSTIN, FS_C, FILLXL, CPGM10
              .extern GCPKC, GENLNK, GENNUM, GETLIN, GETPC, GETPCA, GRAD
              .extern GT3DBT, GTACOD, GTAINC, GTBYT, GTBYTA, GTBYTO, GTFEND
              .extern GCPKC0
              .extern RMAD25
              .extern GTLINK, GTLNKA, GTO, GTOL, GTONN, GTO_5, GTRMAD
              .extern HMS_H, HMS_MINUS, HMS_PLUS, H_HMS
              .extern INBYT, INBYT0, INCAD, INCAD2, INCADA, INCADP, INCGT2
              .extern INSLIN, INSSUB, INT, INTARG, INTFRC, IORUN, ISG
              .extern KEYOP
              .extern LASTX, LBL, LDSST0, LEFTJ, LINNUM, LN, LN10, LN1_PLUS_X
              .extern LOAD3, LOG
              .extern MASK, MEAN, MEMCHK, MEMLFT, MESSL, MINUS, MOD, MOD10
              .extern MODE, MP1_10, MP2_10, MP2_13, MSG, MSGA, MSGAD, MSGDE
              .extern MSGDLY, MSGE, MSGML, MSGNE, MSGNL, MSGNO, MSGOF, MSGPR
              .extern MSGRAM, MSGROM, MSGTA, MSGWR, MSGYES, MULTIPLY
              .extern NAM44_, NAME4A, NAME4D, NBYTA0, NBYTAB, NEXT1, NFRC
              .extern NFRENT, NFRKB, NFRKB1, NFRNC, NFRPR, NFRPU, NFRSIG
              .extern NFRST_PLUS, NFRX, NFRXY, NLT020, NM44_5
              .extern NOREG9, NULTST, NULT_3, NWGOOS, NXBYT3, NXBYTA, NXBYTO
              .extern NXL3B2, NXLDEL, NXLSST, NXLTX, NXTBYT
              .extern OCT, OFF, OFSHFT, ONE_BY_X, ONE_BY_X10, ONE_BY_X13
              .extern OPROMT, OVFL10
              .extern P6RTN, PACH4, PACK, PACKE, PACKN, PARS56, PARSE, PATCH1
              .extern PATCH6, PCT, PCTCH, PGMAON, PI, PI_BY_2, PKIOAS, PLUS
              .extern POWER_OF_TEN, PROMF1, PROMF2, PROMPT, PSE, PSESTP
              .extern PTBYTA, PTBYTM, PTLINK, PUTPC, PUTPCD, PUTPCL, PUTPCX
              .extern P_R
              .extern PCTOC
              .extern RMCK10
              .extern GOTINT
              .extern SIZSUB
              .extern PROMFC
              .extern GENN55
              .extern MSG105
              .extern QUTCX
              .extern SARO55
              .extern PARS59
              .extern PARS70
              .extern GTCNTR
              .extern DRSY30
              .extern APPEND
              .extern ERR110
              .extern ERRSUB
              .extern GENN55
              .extern MPY150
              .extern RSTSQ
              .extern STMSGF
              .extern QUTCAT
              .extern RAD, RAK60, RCL, RCSCR, RCSCR_, RDN, RFDS55, RG9LCD
              .extern RMCK05, RND, ROLBAK, ROLLUP, ROMCHK, ROMH05, ROMH35
              .extern ROMHED, ROW0, ROW11, ROW12, ROW940, RST05, RSTANN, RSTKB
              .extern RSTMS0, RSTMS1, RSTSEQ, RTJLBL, RTN, RTN30, RTOD, RUN
              .extern RUNING, RUNNK, RUN_STOP, R_D, R_P, R_SCAT, R_SUB
              .extern SAVRTN, SCI, SCROL0, SD, SEARCH, SEPXY, SETSST, SF
              .extern SHF10, SHF40, SHIFT, SIGMA, SIGMA_MINUS, SIGMA_PLUS
              .extern SIGN, SIGREG, SIN, SINFR, SIZE, SKPDEL, SKPLIN, SQR10
              .extern SKP, NOSKP
              .extern SQR13, SQRT, SRBMAP, SST, SSTCAT,STAYON, STBT10, STBT30
              .extern STBT31, STDEV, STFLGS, STO, STOLCC, STOP, STOPS, STOPSB
              .extern STORFC, STOST0, STO_DIVIDE, STO_MINUS, STO_MULTIPLY
              .extern STO_PLUS, STSCR, STSCR_, SUBONE, SUMCHK
              .extern TAN, TBITMA, TBITMP, TEN_TO_X, TEXT, TGSHF1, TOGSHF
              .extern TONE, TONE7X, TONSTF, TOOCT, TOPOL, TOREC, TRC10, TRG100
              .extern TRGSET, TSTMAP, TXTLB1, TXTLBL, TXTROM, TXTSTR
              .extern UPLINK
              .extern VIEW
              .extern WKUP10
              .extern XARCL, XASHF, XASN, XASTO, XAVIEW
              .extern XBAR, XBEEP, XBST
              .extern XCAT, XCF, XCLSIG, XCLX1, XCOPY, XCUTB1, XCUTE
              .extern XDEG, XDELET, XDSE
              .extern XECROM,XEQ
              .extern XFS, XFT100, XGA00, XGI, XGI57, XGOIND, XGRAD, XGT, XGTO
              .extern XISG, XLN1_PLUS_X, XNNROW
              .extern XPACK, XPRMPT
              .extern XRAD, XRDN, XRND, XROLLUP
              .extern XROM, XROMNF, XROW1, XRS45, XRTN, XR_S
              .extern XSCI, XSF, XSGREG, XSIGN, XSIZE, XSST, XSTYON
              .extern XTOHRS, XTONE, XVIEW, XXEQ
              .extern XX_EQ_0, XX_EQ_Y, XX_GT_0, XX_GT_Y, XX_LE_0A, XX_LE_Y
              .extern XX_LT_0, XX_LT_Y, XX_NE_0, XX_NE_Y, XY_TO_X, X_BY_Y13
              .extern X_EQ_0, X_EQ_Y, X_GT_0, X_GT_Y, X_LE_0, X_LE_Y, X_LT_0
              .extern X_LT_Y, X_NE_0, X_NE_Y, X_TO_2, X_XCHNG, X_XCHNG_Y
              .extern Y_TO_X
