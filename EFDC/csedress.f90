FUNCTION CSEDRESS(DENBULK,WRSPO,VDRO,VDR,VDRC,IOPT)

  ! CHANGE RECORD

  ! **  CALCULATES SURFACE EROSION RATE OF COHESIVE
  ! **  SEDIMENT AS A FUNCTION OF BED BULK DENSITY
  ! **  IOPT=1  BASED ON
  ! **
  ! **  HWANG, K. N., AND A. J. MEHTA, 1989: FINE SEDIMENT ERODIBILITY
  ! **  IN LAKE OKEECHOBEE FLORIDA. COASTAL AND OCEANOGRAPHIC ENGINEERING
  ! **  DEPARTMENT, UNIVERSITY OF FLORIDA, GAINESVILLE, FL32661
  ! **  IOPT=2  BASED ON J. M. HAMRICK'S MODIFICATION OF
  ! **
  ! **  SANFORD, L.P., AND J. P. Y. MAA, 2001: A UNIFIED EROSION FORMULATION
  ! **  FOR FINE SEDIMENT, MARINE GEOLOGY, 179, 9-23.
  !
  ! **  IOPT=4 & 5 BASED ON J. M. HAMRICK'S PARAMETERIZATION OF SEDFLUME
  !     TEST DATA
  ! **

  IMPLICIT NONE

  INTEGER :: IOPT
  REAL :: CSEDRESS,DENBULK,WRSPO,VDRO,VDR,VDRC
  REAL :: BULKDEN,TMP,TMPVAL,FACTOR

  IF( IOPT == 1 )THEN
    BULKDEN=0.001*DENBULK    ! *** TO PREVENT CORRUPTING THE DENBULK VARIABLE
    IF( BULKDEN <= 1.065 )THEN
      CSEDRESS=0.62
    ELSE
      TMP=0.198/(BULKDEN-1.0023)
      TMP=EXP(TMP)
      CSEDRESS=6.4E-4*(10.**TMP)
    ENDIF
  ELSEIF( IOPT == 2 )THEN
    CSEDRESS=WRSPO*(1.+VDRO)/(1.+VDR)
  ELSEIF( IOPT == 3 )THEN
    CSEDRESS=WRSPO*(1.+VDRO)/(1.+VDRC)
  ELSEIF( IOPT == 4 )THEN
    TMPVAL=(1.+VDRO)/(1.+VDR)
    FACTOR=EXP(-TMPVAL)
    CSEDRESS=FACTOR*WRSPO*(1.+VDRO)/(1.+VDR)
  ELSEIF( IOPT == 5 )THEN
    TMPVAL=(1.+VDRO)/(1.+VDRC)
    FACTOR=EXP(-TMPVAL)
    CSEDRESS=FACTOR*WRSPO*(1.+VDRO)/(1.+VDRC)
  ELSEIF( IOPT >= 99 )THEN
    CSEDRESS=WRSPO
  ENDIF

END FUNCTION

