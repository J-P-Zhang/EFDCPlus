SUBROUTINE WQAGR(IWQTAGR)

  ! *** RWQAGR 

  ! READ IN SPATIALLY AND/OR TEMPORALLY VARYING PARAMETERS FOR ALGAL
  ! GROWTH, RESP. & PREDATION RATES, AND BASE LIGHT EXTINCT. COEFF.
  ! (UNIT INWQAGR).

  ! CHANGE RECORD  
  !  2011-08   PMC - THIS NEVER WORKED FOR TIME VARYING GROWTH RATES.
  !                  NEEDS TO BE FIXED!

  USE GLOBAL


  IMPLICIT NONE

  INTEGER :: IWQTAGR,I,M,MM

  CHARACTER TITLE(3)*79, AGRCONT*3
  WRITE(*,'(A)')' WQ: '//AGRFN
  OPEN(1,FILE=AGRFN,STATUS='UNKNOWN')
  OPEN(2,FILE=OUTDIR//'WQ3D.OUT',STATUS='UNKNOWN',POSITION='APPEND')

  IF( IWQTAGR == 0 )THEN
    READ(1,50) (TITLE(M),M=1,3)
    WRITE(2,999)
    WRITE(2,50) (TITLE(M),M=1,3)
  ENDIF
  WRITE(2,60)'* ALGAL KINETIC VALUE AT', IWQTAGR, &
      ' TH DAY FROM MODEL START'
  READ(1,999)
  READ(1,50) TITLE(1)
  WRITE(2,50) TITLE(1)
  DO I=1,IWQZ
  !
  !        READ(1,51) MM,WQPMC(I),WQPMD(I),WQPMG(I),WQBMRC(I),
  !
    READ(1,*) MM, WQPMC(I),WQPMD(I),WQPMG(I),WQPMM(I),WQBMRC(I), &
        WQBMRD(I),WQBMRG(I),WQBMRM(I),WQPRRC(I),WQPRRD(I), &
        WQPRRG(I),WQPRRM(I),WQKEB(I)
    WRITE(2,51) MM, WQPMC(I),WQPMD(I),WQPMG(I),WQPMM(I),WQBMRC(I), &
        WQBMRD(I),WQBMRG(I),WQBMRM(I),WQPRRC(I),WQPRRD(I), &
        WQPRRG(I),WQPRRM(I),WQKEB(I)
  ENDDO
  READ(1,52) IWQTAGR, AGRCONT
  WRITE(2,52) IWQTAGR, AGRCONT
  IF( AGRCONT == 'END' )THEN
    CLOSE(1)
    IWQAGR = 0
  ENDIF
  CLOSE(2)
    999 FORMAT(1X)
     50 FORMAT(A79)
     51 FORMAT(I8, 14F8.3)
     52 FORMAT(I7, 1X, A3)
     60 FORMAT(/, A24, I5, A24)
  RETURN

END

