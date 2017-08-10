      MODULE GMGMODULE
        INTEGER,SAVE,POINTER  ::IITER,IADAMPGMG,ISM,ISC,IOUTGMG
        INTEGER,SAVE,POINTER  ::ISIZ,IPREC,IIOUT
        INTEGER,SAVE,POINTER  ::SITER,TSITER
        INTEGER,SAVE,POINTER  ::GMGID
        INTEGER,SAVE,POINTER  ::IUNITMHC
        integer,save,pointer  ::mxitergmg
        double precision,SAVE,POINTER  ::HCLOSEGMG,RCLOSEGMG,DAMPGMG
        double precision   ,SAVE,POINTER  ::DUP,DLOW,CHGLIMIT
        double precision   ,SAVE,POINTER,DIMENSION(:,:,:)::HNEWLAST
        DOUBLE PRECISION,SAVE,POINTER :: BIGHEADCHG
        DOUBLE PRECISION,SAVE,POINTER  :: RELAXGMG
      TYPE GMGTYPE
        INTEGER,POINTER  ::IITER,IADAMPGMG,ISM,ISC,IOUTGMG
        INTEGER,POINTER  ::ISIZ,IPREC,IIOUT
        INTEGER,POINTER  ::SITER,TSITER
        INTEGER,POINTER  ::GMGID
        INTEGER,POINTER  ::IUNITMHC
        integer,pointer  ::mxitergmg
        double precision   ,POINTER  ::HCLOSEGMG,RCLOSEGMG,DAMPGMG
        double precision   ,POINTER  ::DUP,DLOW,CHGLIMIT
        double precision   ,POINTER,DIMENSION(:,:,:)::HNEWLAST
        DOUBLE PRECISION,POINTER :: BIGHEADCHG
        DOUBLE PRECISION,POINTER  :: RELAXGMG
      END TYPE
      TYPE(GMGTYPE), SAVE ::GMGDAT(10)
      END MODULE GMGMODULE
C
      SUBROUTINE GMG7AR(IN,MXITER,IGRID)
C--------------------------------------------------------------------
C     READS INPUT FROM FILE TYPE GMG SPECIFIED IN NAME FILE
C     ALLOCATES GMG SOLVER
C     EXPLICIT DECLERATIONS
C--------------------------------------------------------------------
      USE GLOBAL,   ONLY:IOUT,NCOL,NROW,NLAY
      USE GMGMODULE,ONLY:IITER,IADAMPGMG,ISM,ISC,IOUTGMG,ISIZ,
     1                   IPREC,IIOUT,SITER,TSITER,GMGID,HCLOSEGMG,
     2                   RCLOSEGMG,DAMPGMG,RELAXGMG,
     3                   IUNITMHC,DUP,DLOW,CHGLIMIT,HNEWLAST,
     4                   BIGHEADCHG, mxitergmg
      use utl7module, only: URDCOM, URWORD
      use SimModule, only: ustop
      IMPLICIT NONE
      CHARACTER*200 LINE
      INTEGER IN,MXITER,IGRID,ICOL,NDUM,ISTOP,ISTART
      double precision ::    RDUM
C
C--------------------------------------------------------------------
C     ALLOCATE POINTERS
C--------------------------------------------------------------------
      ALLOCATE(IITER,IADAMPGMG,ISM,ISC,IOUTGMG,ISIZ,IPREC,IIOUT,
     1         SITER,TSITER,GMGID,IUNITMHC)
      allocate(mxitergmg)
      ALLOCATE(HCLOSEGMG,RCLOSEGMG,DAMPGMG,RELAXGMG)
      ALLOCATE(DUP,DLOW,CHGLIMIT)
      ALLOCATE(BIGHEADCHG)
C
C--------------------------------------------------------------------
C     READ INPUT FILE
C--------------------------------------------------------------------
      CALL URDCOM(IN,IOUT,LINE)
      READ(LINE,*) RCLOSEGMG,IITER,HCLOSEGMG,MXITER
      mxitergmg = MXITER
C
      CALL URDCOM(IN,IOUT,LINE)
      ICOL = 1
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,3,NDUM,DAMPGMG,IOUT,IN)
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,2,IADAMPGMG,RDUM,IOUT,IN)
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,2,IOUTGMG,RDUM,IOUT,IN)
      IUNITMHC = 0
      NDUM = -1
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,2,NDUM,RDUM,-1,IN)
      IF (NDUM>0) IUNITMHC = NDUM
C
      DUP=0.
      DLOW=0.
      CHGLIMIT=0.
      CALL URDCOM(IN,IOUT,LINE)
      IF(IADAMPGMG.EQ.0 .OR. IADAMPGMG.EQ.1) THEN
        READ(LINE,*) ISM,ISC
      ELSE IF(IADAMPGMG.EQ.2) THEN
        READ(LINE,*) ISM,ISC,DUP,DLOW,CHGLIMIT
      ELSE
        WRITE(IOUT,400)
  400   FORMAT(/,1X,'ERROR IN GMG INPUT: IADAMP MUST BE ONE OF 0, 1,',
     1    ' OR 2 (GMG1ALG)')
        CALL USTOP(' ')
      END IF
C
      IIOUT=IOUT
      IF(IOUTGMG .GT. 2) IIOUT=6
C
      SITER=0
      TSITER=0
      RELAXGMG=0.0D0
      IF(ISC .EQ. 4) THEN
        CALL URDCOM(IN,IOUT,LINE)
        READ(LINE,*) RELAXGMG
      END IF
C
      IF(DAMPGMG .LE. 0.0 .OR. DAMPGMG .GT. 1.0) DAMPGMG=1.0
C
C--------------------------------------------------------------------
C     ALLOCATE
C--------------------------------------------------------------------
      IF(IUNITMHC.GT.0 .OR. IADAMPGMG.EQ.2) THEN
        ALLOCATE(HNEWLAST(NCOL,NROW,NLAY))
      ELSE
        ALLOCATE(HNEWLAST(1,1,1))
      END IF
C
C---- CHECK FOR FORCED DOUBLE PRECISION
C
      IPREC=0
      IF(KIND(DAMPGMG) .EQ. 8) IPREC=1
C
*      CALL MF2KGMG_ALLOCATE(GMGID,NCOL,NROW,NLAY,IPREC,ISM,ISC,
*     &                      RELAXGMG,ISIZ,IERR)
*      IF(IERR .NE. 0) THEN
*        CALL USTOP('ALLOCATION ERROR IN SUBROUTINE GMG1ALG')
*      END IF
C
      WRITE(IIOUT,500) RCLOSEGMG,IITER,HCLOSEGMG,MXITER,
     &                 DAMPGMG,IADAMPGMG,IOUTGMG,
     &                 ISM,ISC,RELAXGMG
C
      IF(IADAMPGMG==1) WRITE(IIOUT,510)
      IF(IADAMPGMG==2) THEN
        WRITE(IIOUT,512)
        WRITE(IIOUT,513)DUP,DLOW,CHGLIMIT
      ENDIF
      IF(ISM .EQ. 0) WRITE(IIOUT,520)
      IF(ISM .EQ. 1) WRITE(IIOUT,525)
      IF(ISC .EQ. 0) WRITE(IIOUT,530)
      IF(ISC .EQ. 1) WRITE(IIOUT,531)
      IF(ISC .EQ. 2) WRITE(IIOUT,532)
      IF(ISC .EQ. 3) WRITE(IIOUT,533)
      IF(ISC .EQ. 4) WRITE(IIOUT,534)
      IF(IUNITMHC.GT.0) WRITE(IOUT,501) IUNITMHC
C
      WRITE(IIOUT,540) ISIZ
C
C--------------------------------------------------------------------
C     FORMAT STATEMENTS
C--------------------------------------------------------------------
  500 FORMAT(1X,'-------------------------------------------------',/,
     &       1X,'GMG -- PCG GEOMETRIC MULTI-GRID SOLUTION PACKAGE:',/,
     &       1X,'-------------------------------------------------',/,
     &       1X,'RCLOSE  = ',1P,E8.2,'; INNER CONVERGENCE CRITERION',/,
     &       1X,'IITER   = ',I8,'; MAX INNER ITERATIONS            ',/,
     &       1X,'HCLOSE  = ',1P,E8.2,'; OUTER CONVERGENCE CRITERION',/,
     &       1X,'MXIITER = ',I8,'; MAX OUTER ITERATIONS            ',/,
     &       1X,'DAMP    = ',1P,E8.2,'; DAMPING PARAMETER          ',/,
     &       1X,'IADAMP  = ',I8,'; ADAPTIVE DAMPING FLAG           ',/,
     &       1X,'IOUTGMG = ',I8,'; OUTPUT CONTROL FLAG             ',/,
     &       1X,'ISM     = ',I8,'; SMOOTHER FLAG                   ',/,
     &       1X,'ISC     = ',I8,'; COARSENING FLAG                 ',/,
     &       1X,'RELAX   = ',1P,E8.2,'; RELAXATION PARAMETER       ',/,
     &       1X,"-------------------------------------------------")
C
  501 FORMAT(1X,'Head change will be saved on unit',I5)
  510 FORMAT(1X,"COOLEY'S ADAPTIVE DAMPING METHOD IMPLEMENTED")
  512 FORMAT(1X,'RELATIVE REDUCED RESIDUAL ADAPTIVE DAMPING METHOD',
     1    ' WILL BE USED')
  513 FORMAT(5X,'WITH DUP = ',G10.3,' DLOW = ',G10.3,' AND CHGLIMIT = ',
     1     G10.3)
  520 FORMAT(1X,'ILU SMOOTHING IMPLEMENTED')
  525 FORMAT(1X,'SGS SMOOTHING IMPLEMENTED')
C
  530 FORMAT(1X,'FULL COARSENING')
  531 FORMAT(1X,'COARSENING ALONG COLUMNS AND ROWS ONLY')
  532 FORMAT(1X,'COARSENING ALONG ROWS AND LAYERS ONLY')
  533 FORMAT(1X,'COARSENING ALONG COLUMNS AND LAYERS ONLY')
  534 FORMAT(1X,'NO COARSENING')
C
  540 FORMAT(1X,'-------------------------------------------------',/,
     &       1X,I4,' MEGABYTES OF MEMORY ALLOCATED BY GMG',/,
     &       1X,'-------------------------------------------------',/)
C
      CALL GMG7PSV(IGRID)
      RETURN
      END


      SUBROUTINE GMG7DA(IGRID)
C  Deallocate GMG data
      USE GMGMODULE
      CALL GMG7PNT(IGRID)
*      CALL MF2KGMG_FREE(GMGID)
      DEALLOCATE(IITER,IADAMPGMG,ISM,ISC,IOUTGMG,ISIZ,IPREC,IIOUT,
     1           SITER,TSITER,GMGID)
      deallocate(mxitergmg)
      DEALLOCATE(HCLOSEGMG,RCLOSEGMG,DAMPGMG,RELAXGMG)
      DEALLOCATE(IUNITMHC,DUP,DLOW,CHGLIMIT,HNEWLAST,BIGHEADCHG)
C
      RETURN
      END
C
      SUBROUTINE GMG7PNT(IGRID)
C  Set pointers to GMG data for a grid
      USE GMGMODULE
C
      IITER=>GMGDAT(IGRID)%IITER
      IADAMPGMG=>GMGDAT(IGRID)%IADAMPGMG
      ISM=>GMGDAT(IGRID)%ISM
      ISC=>GMGDAT(IGRID)%ISC
      IOUTGMG=>GMGDAT(IGRID)%IOUTGMG
      ISIZ=>GMGDAT(IGRID)%ISIZ
      IPREC=>GMGDAT(IGRID)%IPREC
      IIOUT=>GMGDAT(IGRID)%IIOUT
      SITER=>GMGDAT(IGRID)%SITER
      TSITER=>GMGDAT(IGRID)%TSITER
      GMGID=>GMGDAT(IGRID)%GMGID
      HCLOSEGMG=>GMGDAT(IGRID)%HCLOSEGMG
      RCLOSEGMG=>GMGDAT(IGRID)%RCLOSEGMG
      DAMPGMG=>GMGDAT(IGRID)%DAMPGMG
      RELAXGMG=>GMGDAT(IGRID)%RELAXGMG
      IUNITMHC=>GMGDAT(IGRID)%IUNITMHC
      DUP=>GMGDAT(IGRID)%DUP
      DLOW=>GMGDAT(IGRID)%DLOW
      CHGLIMIT=>GMGDAT(IGRID)%CHGLIMIT
      HNEWLAST=>GMGDAT(IGRID)%HNEWLAST
      BIGHEADCHG=>GMGDAT(IGRID)%BIGHEADCHG
      mxitergmg => GMGDAT(igrid)%mxitergmg
C
      RETURN
      END
C
      SUBROUTINE GMG7PSV(IGRID)
C  Save pointers to GMG data
      USE GMGMODULE
C
      GMGDAT(IGRID)%IITER=>IITER
      GMGDAT(IGRID)%IADAMPGMG=>IADAMPGMG
      GMGDAT(IGRID)%ISM=>ISM
      GMGDAT(IGRID)%ISC=>ISC
      GMGDAT(IGRID)%ISIZ=>ISIZ
      GMGDAT(IGRID)%IOUTGMG=>IOUTGMG
      GMGDAT(IGRID)%IPREC=>IPREC
      GMGDAT(IGRID)%IIOUT=>IIOUT
      GMGDAT(IGRID)%SITER=>SITER
      GMGDAT(IGRID)%TSITER=>TSITER
      GMGDAT(IGRID)%GMGID=>GMGID
      GMGDAT(IGRID)%HCLOSEGMG=>HCLOSEGMG
      GMGDAT(IGRID)%RCLOSEGMG=>RCLOSEGMG
      GMGDAT(IGRID)%DAMPGMG=>DAMPGMG
      GMGDAT(IGRID)%RELAXGMG=>RELAXGMG
      GMGDAT(IGRID)%IUNITMHC=>IUNITMHC
      GMGDAT(IGRID)%DUP=>DUP
      GMGDAT(IGRID)%DLOW=>DLOW
      GMGDAT(IGRID)%CHGLIMIT=>CHGLIMIT
      GMGDAT(IGRID)%HNEWLAST=>HNEWLAST
      GMGDAT(IGRID)%BIGHEADCHG=>BIGHEADCHG
      GMGDAT(igrid)%mxitergmg => mxitergmg
C
      RETURN
      END

