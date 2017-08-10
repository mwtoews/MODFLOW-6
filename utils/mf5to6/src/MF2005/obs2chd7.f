      MODULE OBSCHDMODULE
         INTEGER, SAVE, POINTER    ::NQCH,NQCCH,NQTCH,IUCHOBSV,IPRT
         INTEGER, SAVE, DIMENSION(:),   POINTER ::NQOBCH
         INTEGER, SAVE, DIMENSION(:),   POINTER ::NQCLCH
         INTEGER, SAVE, DIMENSION(:),   POINTER ::IOBTS
         REAL,    SAVE, DIMENSION(:),   POINTER ::FLWSIM
         REAL,    SAVE, DIMENSION(:),   POINTER ::FLWOBS
         REAL,    SAVE, DIMENSION(:),   POINTER ::TOFF
         REAL,    SAVE, DIMENSION(:),   POINTER ::OTIME
         REAL,    SAVE, DIMENSION(:,:), POINTER ::QCELL
         CHARACTER*12,SAVE,DIMENSION(:),POINTER ::OBSNAM
      TYPE OBSCHDTYPE
         INTEGER,            POINTER ::NQCH,NQCCH,NQTCH,IUCHOBSV,IPRT
         INTEGER,     DIMENSION(:),  POINTER ::NQOBCH
         INTEGER,     DIMENSION(:),  POINTER ::NQCLCH
         INTEGER,     DIMENSION(:),  POINTER ::IOBTS
         REAL,        DIMENSION(:),  POINTER ::FLWSIM
         REAL,        DIMENSION(:),  POINTER ::FLWOBS
         REAL,        DIMENSION(:),  POINTER ::TOFF
         REAL,        DIMENSION(:),  POINTER ::OTIME
         REAL,        DIMENSION(:,:),POINTER ::QCELL
         CHARACTER*12,DIMENSION(:),  POINTER ::OBSNAM
      END TYPE
      TYPE(OBSCHDTYPE), SAVE  ::OBSCHDDAT(10)
      END MODULE OBSCHDMODULE

      SUBROUTINE OBS2CHD7AR(IUCHOB,IGRID)
C     ******************************************************************
C     ALLOCATE AND READ DATA FOR FLOW OBSERVATIONS AT CONSTANT-HEAD
C     BOUNDARY CELLS
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL, ONLY: NCOL,NROW,NLAY,NPER,NSTP,PERLEN,TSMULT,ISSFLG,
     1                  IOUT,ITRSS
      USE OBSCHDMODULE
      use SimModule, only: ustop
      use utl7module, only: URDCOM, URWORD
C
      CHARACTER*200 LINE
      double precision :: dum
C     ------------------------------------------------------------------
      ALLOCATE(NQCH,NQTCH,NQCCH,IUCHOBSV,IPRT)
C
C1------INITIALIZE VARIABLEA.
      ZERO=0.0
      IERR=0
      NT=0
      NC=0
C
C2------IDENTIFY PROCESS
      WRITE(IOUT,14) IUCHOB
   14 FORMAT(/,' OBS2CHD7 -- CONSTANT-HEAD BOUNDARY FLOW OBSERVATIONS',
     &    /,' VERSION 2.0, 02/28/2006       INPUT READ FROM UNIT ',I3)
C
C3------ITEM 1
      CALL URDCOM(IUCHOB,IOUT,LINE)
      LLOC = 1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NQCH,DUM,IOUT,IUCHOB)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NQCCH,DUM,IOUT,IUCHOB)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NQTCH,DUM,IOUT,IUCHOB)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IUCHOBSV,DUM,IOUT,IUCHOB)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,IDUM,DUM,IOUT,IUCHOB)
      IPRT=1
      IF(LINE(ISTART:ISTOP).EQ.'NOPRINT') THEN
        IPRT=0
        WRITE(IOUT,*) 'NOPRINT option for CONSTANT-HEAD OBSERVATIONS'
      END IF
      WRITE (IOUT,17) NQCH, NQCCH, NQTCH
   17 FORMAT (/,
     &    ' NUMBER OF FLOW-OBSERVATION CONSTANT-HEAD-CELL GROUPS:',I5,/,
     &    '   NUMBER OF CELLS IN CONSTANT-HEAD-CELL GROUPS......:',I5,/,
     &    '   NUMBER OF CONSTANT-HEAD-CELL FLOWS................:',I5)
      IF(NQTCH.LE.0) THEN
         WRITE(IOUT,*) ' NQTCH LESS THAN OR EQUAL TO 0'
         CALL USTOP(' ')
      END IF
      IF(IUCHOBSV.GT.0) THEN
         WRITE(IOUT,21) IUCHOBSV
   21    FORMAT(1X,
     1      'CH OBSERVATIONS WILL BE SAVED ON UNIT...............:',I5)
      ELSE
         WRITE(IOUT,22)
   22    FORMAT(1X,'CH OBSERVATIONS WILL NOT BE SAVED IN A FILE')
      END IF
C
C4------ALLOCATE ARRAYS
      ALLOCATE (NQOBCH(NQCH))
      ALLOCATE (NQCLCH(NQCH))
      ALLOCATE (IOBTS(NQTCH))
      ALLOCATE (FLWSIM(NQTCH))
      ALLOCATE (FLWOBS(NQTCH))
      ALLOCATE (TOFF(NQTCH))
      ALLOCATE (OTIME(NQTCH))
      ALLOCATE (QCELL(4,NQCCH))
      ALLOCATE (OBSNAM(NQTCH))
      DO 19 N=1,NQTCH
      OTIME(N)=ZERO
      FLWSIM(N)=ZERO
   19 CONTINUE
C
C5------READ AND WRITE TIME-OFFSET MULTIPLIER FOR FLOW-OBSERVATION TIMES
      READ(IUCHOB,*) TOMULTCH
      IF(IPRT.NE.0) WRITE (IOUT,520) TOMULTCH
  520 FORMAT (/,' OBSERVED CONSTANT-HEAD-CELL FLOW DATA',/,
     &' -- TIME OFFSETS ARE MULTIPLIED BY: ',G12.5)
C
C6------LOOP THROUGH CELL GROUPS.
      DO 120 IQ = 1,NQCH
C
C7------READ ITEM 3
        READ (IUCHOB,*) NQOBCH(IQ), NQCLCH(IQ)
        IF(IPRT.NE.0) WRITE (IOUT,525) IQ, 'CHD', NQCLCH(IQ), NQOBCH(IQ)
  525   FORMAT (/,'   GROUP NUMBER: ',I3,'   BOUNDARY TYPE: ',A,
     &         '   NUMBER OF CELLS IN GROUP: ',I5,/,
     &         '   NUMBER OF FLOW OBSERVATIONS: ',I5,//,
     &         40X,'OBSERVED',/,
     &         20X,'REFER.',12X,'BOUNDARY FLOW',/,
     &      7X,'OBSERVATION',2X,'STRESS',4X,'TIME',5X,'GAIN (-) OR',/,
     &         2X,'OBS#    NAME',6X,'PERIOD   OFFSET',5X,'LOSS (+)')
C
C8------SET FLAG FOR SETTING ALL FACTORS TO 1
        IFCTFLG = 0
        IF (NQCLCH(IQ).LT.0) THEN
          IFCTFLG = 1
          NQCLCH(IQ) = -NQCLCH(IQ)
        ENDIF
C
C9------READ TIME STEPS, MEASURED FLOWS, AND WEIGHTS.
        NT1 = 1 + NT
        NT2 = NQOBCH(IQ) + NT
        DO 30 N = NT1, NT2
C
C10-----READ ITEM 4
          READ (IUCHOB,*) OBSNAM(N), IREFSP, TOFFSET, FLWOBS(N)
          IF(IPRT.NE.0) WRITE (IOUT,535) N, OBSNAM(N), IREFSP, TOFFSET,
     1                                   FLWOBS(N)
  535     FORMAT(1X,I5,1X,A12,2X,I4,2X,G11.4,1X,G11.4)
          CALL UOBSTI(OBSNAM(N),IOUT,ISSFLG,ITRSS,NPER,NSTP,IREFSP,
     &                IOBTS(N),PERLEN,TOFF(N),TOFFSET,TOMULTCH,TSMULT,1,
     &                OTIME(N))
   30   CONTINUE
C
C11-----READ LAYER, ROW, COLUMN, AND FACTOR (ITEM 5)
        NC1 = NC + 1
        NC2 = NC + NQCLCH(IQ)
        IF(IPRT.NE.0) WRITE (IOUT,540)
  540   FORMAT (/,'       LAYER  ROW  COLUMN    FACTOR')
        DO 40 L = NC1, NC2
          READ (IUCHOB,*) (QCELL(I,L),I=1,4)
          IF(QCELL(4,L).EQ.0. .OR. IFCTFLG.EQ.1) QCELL(4,L) = 1.
          IF(IPRT.NE.0) WRITE (IOUT,550) (QCELL(I,L),I=1,4)
  550     FORMAT (4X,F8.0,F6.0,F7.0,F9.2)
          K = QCELL(1,L)
          I = QCELL(2,L)
          J = QCELL(3,L)
          IF (K.LE.0 .OR. K.GT.NLAY .OR .J.LE.0 .OR. J.GT.NCOL .OR.
     &        I.LE.0 .OR. I.GT.NROW) THEN
            WRITE (IOUT,590)
  590       FORMAT (/,' ROW OR COLUMN NUMBER INVALID',
     &        ' -- STOP EXECUTION (OBS2CHD7AR)',/)
            IERR = 1
          ENDIF
   40   CONTINUE
C
C12-----UPDATE COUNTERS.
        NC = NC2
        NT = NT2
  120 CONTINUE
C
C13-----STOP IF THERE WERE ANY ERRORS WHILE READING.
      IF (IERR.GT.0) THEN
        WRITE(IOUT,620)
  620   FORMAT (/,' ERROR:  SEE ABOVE FOR ERROR MESSAGE AND "STOP',
     &        ' EXECUTION" (OBS2CHD7AR)')
        CALL USTOP(' ')
      ENDIF
C
C14-----RETURN.
      CALL SOBS2CHD7PSV(IGRID)
      RETURN
      END SUBROUTINE OBS2CHD7AR
      
      SUBROUTINE OBS2CHD7DA(IGRID)
C  Deallocate OBSCHD memory
      USE OBSCHDMODULE
C
      DEALLOCATE(NQCH)
      DEALLOCATE(NQTCH)
      DEALLOCATE(NQCCH)
      DEALLOCATE(IUCHOBSV)
      DEALLOCATE(IPRT)
      DEALLOCATE(NQOBCH)
      DEALLOCATE(NQCLCH)
      DEALLOCATE(IOBTS)
      DEALLOCATE(FLWSIM)
      DEALLOCATE(FLWOBS)
      DEALLOCATE(TOFF)
      DEALLOCATE(OTIME)
      DEALLOCATE(QCELL)
      DEALLOCATE(OBSNAM)
C
      RETURN
      END SUBROUTINE OBS2CHD7DA
      
      SUBROUTINE SOBS2CHD7PNT(IGRID)
C  Change OBSCHD data to a different grid.
      USE OBSCHDMODULE
C
      NQCH=>OBSCHDDAT(IGRID)%NQCH
      NQTCH=>OBSCHDDAT(IGRID)%NQTCH
      NQCCH=>OBSCHDDAT(IGRID)%NQCCH
      IUCHOBSV=>OBSCHDDAT(IGRID)%IUCHOBSV
      IPRT=>OBSCHDDAT(IGRID)%IPRT
      NQOBCH=>OBSCHDDAT(IGRID)%NQOBCH
      NQCLCH=>OBSCHDDAT(IGRID)%NQCLCH
      IOBTS=>OBSCHDDAT(IGRID)%IOBTS
      FLWSIM=>OBSCHDDAT(IGRID)%FLWSIM
      FLWOBS=>OBSCHDDAT(IGRID)%FLWOBS
      TOFF=>OBSCHDDAT(IGRID)%TOFF
      OTIME=>OBSCHDDAT(IGRID)%OTIME
      QCELL=>OBSCHDDAT(IGRID)%QCELL
      OBSNAM=>OBSCHDDAT(IGRID)%OBSNAM
C
      RETURN
      END SUBROUTINE SOBS2CHD7PNT
      
      SUBROUTINE SOBS2CHD7PSV(IGRID)
C  Save OBSCHD data for a grid.
      USE OBSCHDMODULE
C
      OBSCHDDAT(IGRID)%NQCH=>NQCH
      OBSCHDDAT(IGRID)%NQTCH=>NQTCH
      OBSCHDDAT(IGRID)%NQCCH=>NQCCH
      OBSCHDDAT(IGRID)%IUCHOBSV=>IUCHOBSV
      OBSCHDDAT(IGRID)%IPRT=>IPRT
      OBSCHDDAT(IGRID)%NQOBCH=>NQOBCH
      OBSCHDDAT(IGRID)%NQCLCH=>NQCLCH
      OBSCHDDAT(IGRID)%IOBTS=>IOBTS
      OBSCHDDAT(IGRID)%FLWSIM=>FLWSIM
      OBSCHDDAT(IGRID)%FLWOBS=>FLWOBS
      OBSCHDDAT(IGRID)%TOFF=>TOFF
      OBSCHDDAT(IGRID)%OTIME=>OTIME
      OBSCHDDAT(IGRID)%QCELL=>QCELL
      OBSCHDDAT(IGRID)%OBSNAM=>OBSNAM
C
      RETURN
      END SUBROUTINE SOBS2CHD7PSV
