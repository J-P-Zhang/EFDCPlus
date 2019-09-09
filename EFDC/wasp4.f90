SUBROUTINE WASP4

  ! CHANGE RECORD
  ! **  SUBROUTINE WASPOUT WRITES OUTPUT FILES PROVIDING ADVECTIVE AND
  ! **  DIFFUSIVE TRANSPORT FIELDS FOR THE WASP4  WATER QUALITY MODEL
  !
  USE GLOBAL
  
  IMPLICIT NONE
  
  INTEGER :: LCLTM2,LTYPE,KWASP,LT,LBELOW,I,J,L,K,NTEX,NORSH,NORSV,NORS,KMUL,LWASPW
  INTEGER :: LW,LSLT,LWASPS,LS,KMUL1,KMUL2,NBRK,NINQ,NOQSH,NOQSV,NOQS,LL,NBRKQ,KCLC,KL
  INTEGER :: M,NJUN,NCHNH,NCHNV,NCHN,ISTMP,NODYN,LCHN,LDTM,LUTM,LCELL,IZERO,NSTEP,LN,LE1
  
  INTEGER(IK4),SAVE,ALLOCATABLE,DIMENSION(:) :: LDTMP
  INTEGER(IK4),SAVE,ALLOCATABLE,DIMENSION(:) :: LUTMP
  
  REAL    :: SVPT,SCALR,VOLUME,UNITY,ADDLW,ADDLS,ADDL,TSTOP,TSTART,TSMALL,D1,T1,D2,T2,D3,T3,D4
  REAL    :: T4,D5,T5,D6,T6,TZERO,RMNDUM,RLENTH,WIDTH,RZERO,VOLUM,QIN,FLOWXI,FLOWYI,FLOWZI
  REAL    :: FLOWXO,FLOWYO,FLOWZO,QQSUM,DEPTH,VELX,VELY,VELZ,VELMAG,FLOWX,FLOWY,FLOWZ
  
  REAL(RK4),   SAVE,ALLOCATABLE,DIMENSION(:) :: QTMP
  

  IF(  .NOT. ALLOCATED(LDTMP) )THEN
    ALLOCATE(LDTMP(KCM*LCM))
    ALLOCATE(LUTMP(KCM*LCM))
    ALLOCATE(QTMP(KCM*LCM))
    LDTMP=0
    LUTMP=0
    QTMP=0.0
  ENDIF
  !
  ! **  WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! **  THE VALUE OF X IN THE F10.X FORMATS MAY NEED TO BE CHANGED
  ! **  FROM PROBLEM TO PROBLEM.  A PRELIMINARY RUN USING E10.3
  ! **  CAN BE USED TO SPEED THE ADJUSTMENT
  ! **  READ CONTROL DATA FOR WRITING TO WASP COMPATIABLE FILES
  !
  SVPT=1.
  IF( NTSMMT < NTSPTC)SVPT=0.
  IF( JSWASP == 1 )THEN
    WRITE(*,'(A)')'READING EFDC.WSP'
    OPEN(1,FILE='EFDC.WSP',STATUS='UNKNOWN')
    READ(1,1)
    READ(1,1)
    READ(1,*) IVOPT,IBEDV,SCALV,CONVV,VMULT,VEXP,DMULT,DEXP
    READ(1,1)
    READ(1,1)
    READ(1,*) NRFLD,SCALR,CONVR
    READ(1,1)
    READ(1,1)
    READ(1,*) IQOPT,NFIELD,SCALQ,CONVQ
    READ(1,1)
    READ(1,1)
    READ(1,*) DEPSED
    CLOSE(1)
  ENDIF
      1 FORMAT (80X)
  !
  ! **  WRITE HORIZONTAL POSITION AND LAYER FILE WASPP.OUT
  ! **  WRITE INITIAL VOLUME FILE WASPC.OUT
  ! **  FILE WASPC.OUT IS CONSISTENT WITH DATA GROUP C SPECIFICATIONS
  ! **  ON PAGE 172 OF THE WASP4 MANUAL PB88-185095, JAN 1988
  ! **  FILE WASPP.OUT DEFINES THE LAYER (1 IS SURFACE WATER LAYER, WITH
  ! **  LAYER NUMBERING INCREASING WITH DEPTH IN WATER COLUMN) AND
  ! **  HORIZONTAL POSITIONS IN LON,LAT OR UTME, UTMN OF THE WATER
  ! **  QUALITY (LONG TERM TRANSPORT) CELLS OR SEGEMENTS
  !
  IF( JSWASP == 1 )THEN
    OPEN(90,FILE=OUTDIR//'WASPP.OUT',STATUS='UNKNOWN')
    OPEN(93,FILE=OUTDIR//'WASPC.OUT',STATUS='UNKNOWN')
    CLOSE(90,STATUS='DELETE')
    CLOSE(93,STATUS='DELETE')
    OPEN(90,FILE=OUTDIR//'WASPP.OUT',STATUS='UNKNOWN')
    OPEN(93,FILE=OUTDIR//'WASPC.OUT',STATUS='UNKNOWN')
  !
  !       IVOPT=2
  !       IBEDV=0
  !
    WRITE(93,1031)IVOPT,IBEDV
  !
  !       SCALV=1.
  !       CONVV=1.
  !
    WRITE(93,1032)SCALV,CONVV
  !
  !       VMULT=0.
  !       VEXP=0.
  !       DMULT=0.
  !       DEXP=0.
  !
    LCLTM2=LCLT-2
    LWASP=0
    IF( KC > 1 )THEN
      LTYPE=1
      KWASP=1
      DO LT=2,LALT
        LWASP=LWASP+1
        LBELOW=LWASP+LCLTM2
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        VOLUME=DXYP(L)*HLPF(L)*DZC(L,KC)
        WRITE(90,1001)LWASP,KWASP,I,J,DLON(L),DLAT(L)
        WRITE(93,1033)LWASP,LBELOW,LTYPE,VOLUME,VMULT,VEXP, &
            DMULT,DEXP
      ENDDO
      LTYPE=2
      DO K=KS,2,-1
        KWASP=KC-K+1
        DO LT=2,LALT
          LWASP=LWASP+1
          LBELOW=LWASP+LCLTM2
          I=ILLT(LT)
          J=JLLT(LT)
          L=LIJ(I,J)
          VOLUME=DXYP(L)*HLPF(L)*DZC(L,K)
          WRITE(90,1001)LWASP,KWASP,I,J,DLON(L),DLAT(L)
          WRITE(93,1033)LWASP,LBELOW,LTYPE,VOLUME,VMULT,VEXP, &
              DMULT,DEXP
        ENDDO
      ENDDO
    ENDIF
    LTYPE=2
    IF( KC == 1 ) LTYPE=1
    KWASP=KC
    DO LT=2,LALT
      LWASP=LWASP+1
  !
  !        LBELOW=0
  !
      LBELOW=LWASP+LCLTM2
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      VOLUME=DXYP(L)*HLPF(L)*DZC(L,KSZ(L))
      WRITE(90,1001)LWASP,KWASP,I,J,DLON(L),DLAT(L)
      WRITE(93,1033)LWASP,LBELOW,LTYPE,VOLUME,VMULT,VEXP, &
          DMULT,DEXP
    ENDDO
    LTYPE=3
    KWASP=KC+1
    DO LT=2,LALT
      LWASP=LWASP+1
      LBELOW=0
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      VOLUME=DXYP(L)*DEPSED
      WRITE(90,1001)LWASP,KWASP,I,J,DLON(L),DLAT(L)
      WRITE(93,1033)LWASP,LBELOW,LTYPE,VOLUME,VMULT,VEXP, &
          DMULT,DEXP
    ENDDO
    CLOSE(90)
    CLOSE(93)
  ENDIF
   1001 FORMAT(4I5,2F10.4)
   1031 FORMAT(2I5)
   1032 FORMAT(2F10.4)
   1033 FORMAT(3I10,5E10.3)
  !
  ! **  WRITE DIFFUSIVE AND DISPERSIVE TRANSPORT FILE WASPB.OUT
  ! **  FILE WASPB.OUT IS CONSISTENT WITH DATA GROUP B SPECIFICATIONS
  ! **  ON PAGE 170 OF THE WASP4 MANUAL PB88-185095, JAN 1988
  !
  IF( JSWASP == 1 )THEN
    OPEN(91,FILE=OUTDIR//'WASPB.OUT',STATUS='UNKNOWN')
    CLOSE(91,STATUS='DELETE')
    OPEN(91,FILE=OUTDIR//'WASPB.OUT',STATUS='UNKNOWN')
  !
  !       NRFLD=1
  !
    WRITE(91,1011)NRFLD
    NTEX=NTS/NTSMMT
  !
  !       SCALR=1.
  !       CONVR=1.
  !
    WRITE(91,1012)NTEX,SCALR,CONVR
    CLOSE(91)
  ENDIF
  OPEN(91,FILE=OUTDIR//'WASPB.OUT',POSITION='APPEND' &
         ,STATUS='UNKNOWN')
  LCLTM2=LCLT-2
  NORSH=0
  NORSV=0
  DO LT=2,LALT
    I=ILLT(LT)
    J=JLLT(LT)
    L=LIJ(I,J)
    NORSH=NORSH+INT(SUB(L))+INT(SVB(L))
    NORSV=NORSV+INT(SPB(L))
  ENDDO
  NORS=KC*NORSH+KS*NORSV
  WRITE(91,1013)NORS
  UNITY=1.
  DO K=KC,1,-1
    KMUL=KC-K
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SUB(L) == 1. )THEN
        LWASP=LT-1+KMUL*LCLTM2
        LWASPW=LWASP-1
        LW=LWC(L)
        ADDLW=DYU(L)*AHULPF(L,K)*DZC(L,K)*0.5*(HLPF(L) &
            +HLPF(LW))*DXIU(L)
        WRITE(91,1014)ADDLW,UNITY,LWASPW,LWASP
      ENDIF
    ENDDO
  ENDDO
  UNITY=1.
  DO K=KC,1,-1
    KMUL=KC-K
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SVB(L) == 1. )THEN
        LWASP=LT-1+KMUL*LCLTM2
        LSLT=LSCLT(LT)
        LWASPS=LSLT-1+KMUL*LCLTM2
        LS=LSC(L)
        ADDLS=DXV(L)*AHVLPF(L,K)*DZC(L,K)*0.5*(HLPF(L) &
            +HLPF(LS))*DYIV(L)
        WRITE(91,1014)ADDLS,UNITY,LWASPS,LWASP
      ENDIF
    ENDDO
  ENDDO
  IF( KC > 1 )THEN
    UNITY=1.
    DO K=KS,1,-1
      KMUL1=KS-K
      KMUL2=KMUL1+1
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        IF( SPB(L) == 1. )THEN
          LWASP=LT-1+KMUL1*LCLTM2
          LBELOW=LT-1+KMUL2*LCLTM2
          ADDL=DXYP(L)*ABLPF(L,K)*DZIG(L,K)
          WRITE(91,1014)ADDL,UNITY,LWASP,LBELOW
        ENDIF
      ENDDO
    ENDDO
  ENDIF
  NBRK=6
  WRITE(91,1015)NBRK
  IF( ISDYNSTP == 0 )THEN
    TSTOP=DT*FLOAT(N)+TCON*TBEGIN
    TSTART=TSTOP-DT*FLOAT(NTSMMT)
  ELSE
    TSTOP=TENDRNSEC
    TSTART=TSTOP-DT*FLOAT(NTSMMT)
  ENDIF
  TSTOP=TSTOP/86400.
  TSTART=TSTART/86400.
  TSMALL=1.E-5
  D1=0.
  T1=0.-2*TSMALL
  D2=0.
  T2=TSTART-TSMALL
  D3=1.
  T3=TSTART+TSMALL
  D4=1.
  T4=TSTOP-TSMALL
  D5=0.
  T5=TSTOP+TSMALL
  D6=0.
  T6=2*TSMALL+(DT*FLOAT(NTS)+TBEGIN*TCON)/86400.
  WRITE(91,1016)D1,T1,D2,T2,D3,T3,D4,T4
  WRITE(91,1016)D5,T5,D6,T6
  CLOSE(91)
   1011 FORMAT(I5)
   1012 FORMAT(I5,2F10.4)
   1013 FORMAT(I5)
   1014 FORMAT(2E10.3,2I5)
   1015 FORMAT(I5)
   1016 FORMAT(4(2F10.5))
   1017 FORMAT(16I5)
  !
  ! **  WRITE ADVECTIVE TRANSPORT FILE WASPD.OUT
  ! **  FILE WASPD.OUT IS CONSISTENT WITH DATA GROUP D.1 SPECIFICATIONS
  ! **  ON PAGE 174 OF THE WASP4 MANUAL PB88-185095, JAN 1988
  !
  IF( JSWASP == 1 )THEN
    OPEN(92,FILE=OUTDIR//'WASPD.OUT',STATUS='UNKNOWN')
    CLOSE(92,STATUS='DELETE')
    OPEN(92,FILE=OUTDIR//'WASPD.OUT',STATUS='UNKNOWN')
  !
  !       IQOPT=1
  !       NFIELD=1
  !
    WRITE(92,1021)IQOPT,NFIELD
    NINQ=NTS/NTSMMT
  !
  !       SCALQ=1
  !       CONVQ=1
  !
    WRITE(92,1022)NINQ,SCALQ,CONVQ
    CLOSE(92)
  ENDIF
  OPEN(92,FILE=OUTDIR//'WASPD.OUT',POSITION='APPEND' &
         ,STATUS='UNKNOWN')
  LCLTM2=LCLT-2
  NOQSH=0
  NOQSV=0
  DO LT=2,LALT
    I=ILLT(LT)
    J=JLLT(LT)
    L=LIJ(I,J)
    NOQSH=NOQSH+INT(SUB(L))+INT(SVB(L))
    NOQSV=NOQSV+INT(SWB(L))
  ENDDO
  NOQS=KC*NOQSH+KS*NOQSV
  WRITE(92,1023)NOQS
  LL=0
  DO K=KC,1,-1
    KMUL=KC-K
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SUB(L) == 1. )THEN
        LL=LL+1
        LDTMP(LL)=LT-1+KMUL*LCLTM2
        LUTMP(LL)=LDTMP(LL)-1
        QTMP(LL)=DYU(L)*(UHLPF(L,K)+SVPT*UVPT(L,K))*DZC(L,K)
      ENDIF
    ENDDO
  ENDDO
  DO L=1,LL,4
    LE1=LEC(LEC(L))
    WRITE(92,1024)QTMP(L),  LUTMP(L),  LDTMP(L), &
        QTMP(LEC(L)),LUTMP(LEC(L)),LDTMP(LEC(L)), &
        QTMP(LE1),LUTMP(LE1),LDTMP(LE1), &
        QTMP(LEC(LE1)),LUTMP(LEC(LE1)),LDTMP(LEC(LE1))
  ENDDO
  LL=0
  DO K=KC,1,-1
    KMUL=KC-K
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SVB(L) == 1. )THEN
        LL=LL+1
        LSLT=LSCLT(LT)
        LDTMP(LL)=LT-1+KMUL*LCLTM2
        LUTMP(LL)=LSLT-1+KMUL*LCLTM2
        QTMP(LL)=DXV(L)*(VHLPF(L,K)+SVPT*VVPT(L,K))*DZC(L,K)
      ENDIF
    ENDDO
  ENDDO
  DO L=1,LL,4
    LE1=LEC(LEC(L))
    WRITE(92,1024)QTMP(L),  LUTMP(L),  LDTMP(L), &
        QTMP(LEC(L)),LUTMP(LEC(L)),LDTMP(LEC(L)), &
        QTMP(LE1),LUTMP(LE1),LDTMP(LE1), &
        QTMP(LEC(LE1)),LUTMP(LEC(LE1)),LDTMP(LEC(LE1))
  ENDDO
  IF( KC > 1 )THEN
    LL=0
    DO K=KS,1,-1
      KMUL1=KS-K
      KMUL2=KMUL1+1
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        IF( SWB(L) == 1. )THEN
          LL=LL+1
          LUTMP(LL)=LT-1+KMUL1*LCLTM2
          LDTMP(LL)=LT-1+KMUL2*LCLTM2
          QTMP(LL)=-DXYP(L)*(WLPF(L,K)+SVPT*WVPT(L,K))
        ENDIF
      ENDDO
    ENDDO
  ENDIF
  IF( KC > 1 )THEN
    DO L=1,LL,4
      LE1=LEC(LEC(L))
      WRITE(92,1024) QTMP(L),  LUTMP(L),  LDTMP(L), &
          QTMP(LEC(L)),LUTMP(LEC(L)),LDTMP(LEC(L)), &
          QTMP(LE1),LUTMP(LE1),LDTMP(LE1), &
          QTMP(LEC(LE1)),LUTMP(LEC(LE1)),LDTMP(LEC(LE1))
    ENDDO
  ENDIF
  NBRKQ=6
  WRITE(92,1025)NBRKQ
  WRITE(92,1026)D1,T1,D2,T2,D3,T3,D4,T4
  WRITE(92,1026)D5,T5,D6,T6
  CLOSE(92)
   1021 FORMAT(2I5)
   1022 FORMAT(I5,2F10.4)
   1023 FORMAT(I5)
   1024 FORMAT(4(E10.3,2I5))
   1025 FORMAT(I5)
   1026 FORMAT(4(2F10.5))
  !
  ! **  WRITE TO DYNHYD.HYD EMULATION FILES WASPDH.OUT AND WASPDHU.OUT
  !
  IF( JSWASP == 1 )THEN
    OPEN(90,FILE=OUTDIR//'WASPDHD.OUT',STATUS='UNKNOWN')
    OPEN(94,FILE=OUTDIR//'WASPDH.OUT',STATUS='UNKNOWN')
    OPEN(95,FILE=OUTDIR//'WASPDHU.OUT',STATUS='UNKNOWN', &
        FORM='UNFORMATTED')
    CLOSE(90,STATUS='DELETE')
    CLOSE(94,STATUS='DELETE')
    CLOSE(95,STATUS='DELETE')
    OPEN(90,FILE=OUTDIR//'WASPDHD.OUT',STATUS='UNKNOWN')
    OPEN(94,FILE=OUTDIR//'WASPDH.OUT',STATUS='UNKNOWN')
    OPEN(95,FILE=OUTDIR//'WASPDHU.OUT',STATUS='UNKNOWN', &
        FORM='UNFORMATTED')
    KCLC=KC*LCLT
    LCLTM2=LCLT-2
    DO KL=1,KCLC
      NCHNC(KL)=0
    ENDDO
    DO M=1,10
      DO KL=1,KCLC
        LCHNC(KL,M)=0
      ENDDO
    ENDDO
    NJUN=KC*(LCLT-2)
    NCHNH=0
    NCHNV=0
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      NCHNH=NCHNH+INT(SUB(L))+INT(SVB(L))
      NCHNV=NCHNV+INT(SWB(L))
    ENDDO
    NCHN=KC*NCHNH+KS*NCHNV
    ISTMP=0
    NODYN=NFLTMT
    TZERO=TBEGIN*TCON/86400.
    WRITE(90,901)NJUN,NCHN
    WRITE(94,941)NJUN,NCHN,DT,ISTMP,NTS,ISTMP,NODYN,TZERO
    WRITE(95)NJUN,NCHN,DT,ISTMP,NTS,ISTMP,NODYN,TZERO
  !
  ! **  CHANNEL DATA
  !
    RMNDUM=0.
    LCHN=0
    DO K=KC,1,-1
      KMUL=KC-K
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        IF( SUB(L) == 1. )THEN
          LDTM=LT-1+KMUL*LCLTM2
          LUTM=LDTM-1
          RLENTH=DXU(L)
          WIDTH=DYU(L)
          LCHN=LCHN+1
          NCHNC(LDTM)=NCHNC(LDTM)+1
          NCHNC(LUTM)=NCHNC(LUTM)+1
          LCHNC(LDTM,NCHNC(LDTM))=LCHN
          LCHNC(LUTM,NCHNC(LUTM))=LCHN
          WRITE(90,902)LCHN,RLENTH,WIDTH,RMNDUM,LUTM,LDTM
          WRITE(94,942)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
          WRITE(95)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
        ENDIF
      ENDDO
    ENDDO
    DO K=KC,1,-1
      KMUL=KC-K
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        IF( SVB(L) == 1. )THEN
          LSLT=LSCLT(LT)
          LDTM=LT-1+KMUL*LCLTM2
          LUTM=LSLT-1+KMUL*LCLTM2
          RLENTH=DYV(L)
          WIDTH=DXV(L)
          LCHN=LCHN+1
          NCHNC(LDTM)=NCHNC(LDTM)+1
          NCHNC(LUTM)=NCHNC(LUTM)+1
          LCHNC(LDTM,NCHNC(LDTM))=LCHN
          LCHNC(LUTM,NCHNC(LUTM))=LCHN
          WRITE(90,902)LCHN,RLENTH,WIDTH,RMNDUM,LUTM,LDTM
          WRITE(94,942)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
          WRITE(95)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
        ENDIF
      ENDDO
    ENDDO
    IF( KC > 1 )THEN
      DO K=KS,1,-1
        KMUL1=KS-K
        KMUL2=KMUL1+1
        DO LT=2,LALT
          I=ILLT(LT)
          J=JLLT(LT)
          L=LIJ(I,J)
          IF( SWB(L) == 1. )THEN
            LUTM=LT-1+KMUL1*LCLTM2
            LDTM=LT-1+KMUL2*LCLTM2
            RLENTH=HLPF(L)*DZG(L,K)
            WIDTH=SQRT(DXYP(L))
            LCHN=LCHN+1
            NCHNC(LDTM)=NCHNC(LDTM)+1
            NCHNC(LUTM)=NCHNC(LUTM)+1
            LCHNC(LDTM,NCHNC(LDTM))=LCHN
            LCHNC(LUTM,NCHNC(LUTM))=LCHN
            WRITE(90,902)LCHN,RLENTH,WIDTH,RMNDUM,LUTM,LDTM
            WRITE(94,942)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
            WRITE(95)RLENTH,WIDTH,RMNDUM,LUTM,LDTM
          ENDIF
        ENDDO
      ENDDO
    ENDIF
  !
  ! **  JUNCTION DATA
  !
    DO K=KC,1,-1
      KMUL=KC-K
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        LCELL=LT-1+KMUL*LCLTM2
        WRITE(90,904)LCELL,DXYP(L),(LCHNC(LCELL,M),M=1,10)
        WRITE(94,944)DXYP(L),(LCHNC(LCELL,M),M=1,10)
        WRITE(95)DXYP(L),(LCHNC(LCELL,M),M=1,10)
      ENDDO
    ENDDO
    CLOSE(90)
    CLOSE(94)
    CLOSE(95)
  ENDIF
  !
  ! **  WRITE TIME STEP, VOLUME AND FLOW DATA
  !
  OPEN(94,FILE=OUTDIR//'WASPDH.OUT',POSITION='APPEND' &
         ,STATUS='UNKNOWN')
  OPEN(95,FILE=OUTDIR//'WASPDHU.OUT',POSITION='APPEND' &
         ,STATUS='UNKNOWN', FORM='UNFORMATTED')
  LCLTM2=LCLT-2
  IZERO=0
  RZERO=0
  NSTEP=N-NTSMMT
  WRITE(94,945)NSTEP
  DO K=KC,1,-1
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      LN=LNC(L)
      VOLUM=DXYP(L)*HLPF(L)*DZC(L,K)
      QIN=QSUMELPF(L)*DZC(L,K)
      FLOWXI=DYU(L)*(UHLPF(L,K)+SVPT*UVPT(L,K))*DZC(L,K)
      FLOWYI=DXV(L)*(VHLPF(L,K)+SVPT*VVPT(L,K))*DZC(L,K)
      FLOWZI=DXYP(L)*(WLPF(L,K-1)+SVPT*WVPT(L,K-1))
      FLOWXO=DYU(LEC(L))*(UHLPF(LEC(L),K)+SVPT*UVPT(LEC(L),K))*DZC(L,K)
      FLOWYO=DXV(LN)*(VHLPF(LN,K)+SVPT*VVPT(LN,K))*DZC(L,K)
      FLOWZO=DXYP(L)*(WLPF(L,K)+SVPT*WVPT(L,K))
      QQSUM=QIN+FLOWXI+FLOWYI+FLOWZI-FLOWXO-FLOWYO-FLOWZO
      DEPTH=HLPF(L)*DZC(L,K)
      VELX=0.5*(UHLPF(L,K)+SVPT*UVPT(L,K) &
          +UHLPF(LEC(L),K)+SVPT*UVPT(LEC(L),K))/HLPF(L)
      VELY=0.5*(VHLPF(L,K)+SVPT*VVPT(L,K) &
          +VHLPF(LN,K)+SVPT*VVPT(LN,K))/HLPF(L)
      VELZ=0.5*(WLPF(L,K-1)+SVPT*WVPT(L,K-1) &
          +WLPF(L,K)+SVPT*WVPT(L,K))
      VELMAG=SQRT(VELX*VELX+VELY*VELY+VELZ*VELZ)
      WRITE(94,946)VOLUM,QIN,QSUM,DEPTH,VELMAG
      WRITE(95)VOLUM,QIN,QQSUM,DEPTH,VELMAG
    ENDDO
  ENDDO
  DO K=KC,1,-1
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SUB(L) == 1. )THEN
        FLOWX=DYU(L)*(UHLPF(L,K)+SVPT*UVPT(L,K))*DZC(L,K)
        WRITE(94,946)FLOWX
        WRITE(95)FLOWX
      ENDIF
    ENDDO
  ENDDO
  DO K=KC,1,-1
    DO LT=2,LALT
      I=ILLT(LT)
      J=JLLT(LT)
      L=LIJ(I,J)
      IF( SVB(L) == 1. )THEN
        FLOWY=DXV(L)*(VHLPF(L,K)+SVPT*VVPT(L,K))*DZC(L,K)
        WRITE(94,946)FLOWY
        WRITE(95)FLOWY
      ENDIF
    ENDDO
  ENDDO
  IF( KC > 1 )THEN
    DO K=KS,1,-1
      DO LT=2,LALT
        I=ILLT(LT)
        J=JLLT(LT)
        L=LIJ(I,J)
        IF( SWB(L) == 1. )THEN
          FLOWZ=-DXYP(L)*(WLPF(L,K)+SVPT*WVPT(L,K))
          WRITE(94,946)FLOWZ
          WRITE(95)FLOWZ
        ENDIF
      ENDDO
    ENDDO
  ENDIF
  CLOSE(94)
  CLOSE(95)
    901 FORMAT(2I5,E12.4,4I5,E12.4)
    902 FORMAT(I5,2X,3E12.4,2I5)
    903 FORMAT(3E12.4,2I5)
    904 FORMAT(I5,2X,E12.4,10I5)
    905 FORMAT(I5)
    906 FORMAT(5E12.4)
    941 FORMAT(2I5,E12.4,4I5,E12.4)
    942 FORMAT(3E12.4,2I5)
    943 FORMAT(3E12.4,2I5)
    944 FORMAT(E12.4,10I5)
    945 FORMAT(I5)
    946 FORMAT(5E12.4)
  JSWASP=0
  RETURN
END

