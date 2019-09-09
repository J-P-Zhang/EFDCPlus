FUNCTION FSEDMODE(WS,USTOT,USGRN,RSNDM,ISNDM1,ISNDM2,IMODE)

  ! *** FSEDMODE SETS BEDLOAD (IMODE=1) AND SUSPENDED LOAD (IMODE=2)
  ! *** TRANSPORT FRACTIONS (DIMENSIONLESS)
  
  ! ***  WS
  ! ***  USTOT  - HYDRODYNAMIC SHEAR VELOCITY (M/S)
  ! ***  USGRN  - GRAIN SHEAR VELOCITY (M/S)
  ! ***  RSNDM  - VALUE OF USTAR/WSET FOR BINARY SWITCH BETWEEN BEDLOAD AND SUSPENDED LOAD (DIMENSIONLESS)

  IMPLICIT NONE

  INTEGER :: ISNDM1,ISNDM2,IMODE
  REAL   :: FSEDMODE,WS,USTOT,USGRN,RSNDM,US,USDWS,TMPVAL

  IF( WS == 0. )THEN
    FSEDMODE=0.
    RETURN
  ENDIF

  ! *** CHOOSE BETWEEEN TOTAL STRESS SHEAR VELOCITY AND GRAIN STRESS
  ! *** SHEAR VELOCITY
  IF( ISNDM2 == 0 )THEN
    US=USTOT
  ELSE
    US=USGRN
  ENDIF
  USDWS = US/WS

  ! *** CHOOSE BETWEEN MODE OPTIONS

  ! *** ISNDM1=0 SET BOTH BEDLOAD AND SUSPENDED LOAD FRACTIONS TO 1.0
  IF( ISNDM1 == 0 ) FSEDMODE=1.0

  ! *** ISNDM1=1 SET BEDLOAD FRACTION TO 1. USE BINARY RELATIONSHIP FOR SUSPENDED
  IF( ISNDM1 == 1 )THEN
      FSEDMODE=0.
    IF( IMODE == 1 )THEN
      FSEDMODE=1.0
    ELSE
      IF( USDWS >= RSNDM)FSEDMODE=1.
    END IF
  END IF

  ! *** ISNDM1=2 SET BEDLOAD FRACTION TO 1, USE LINEAR RELATIONSHIP FOR SUSPENDED
  IF( ISNDM1 == 2 )THEN
    IF( IMODE == 1 )THEN
      FSEDMODE=1.0
    ELSE
      TMPVAL=((USDWS)-0.4)/9.6
      TMPVAL=MIN(TMPVAL,1.0)
      TMPVAL=MAX(TMPVAL,0.0)
        FSEDMODE=TMPVAL
    END IF
  END IF

  ! *** ISNDM1=3 USE BINARY RELATIONSHIP FOR BEDLOAD AND SUSPENDED LOAD
  IF( ISNDM1 == 3 )THEN
      FSEDMODE=0.
    IF( IMODE == 1 )THEN
      IF( USDWS < RSNDM)FSEDMODE=1.
    ELSE
      IF( USDWS >= RSNDM)FSEDMODE=1.
    END IF
  END IF

  ! *** ISNDM1=4 USE LINEAR RELATIONSHIP FOR BEDLOAD AND SUSPENDED LOAD
  IF( ISNDM1 == 4 )THEN
    TMPVAL=((USDWS)-0.4)/9.6
    TMPVAL=MIN(TMPVAL,1.0)
    TMPVAL=MAX(TMPVAL,0.0)
    IF( IMODE == 1 )THEN
      FSEDMODE=1.-TMPVAL
    ELSE
      FSEDMODE=TMPVAL
    END IF
  END IF

END FUNCTION
