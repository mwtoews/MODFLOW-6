      module GwfBasOcSubsModule

        use utl7module, only: U1DREL, U2DREL, USTOPx, URDCOM, URWORD,
     &                        upcase, ulaprwc, u2dint
        use GwfBasModule, only: SGWF2BAS7PNT

        private
        public :: GWF2BAS7OC 

      contains

      SUBROUTINE GWF2BAS7OC(KSTP,KPER,ICNVG,INOC,IGRID,UseTSDefaults)
C     ******************************************************************
C     OUTPUT CONTROLLER FOR HEAD, DRAWDOWN, AND BUDGET
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,      ONLY:IOUT,NLAY,NSTP,IXSEC,IFREFM
      USE GWFBASMODULE,ONLY:IHDDFL,IBUDFL,ICBCFL,IPEROC,ITSOC,IBDOPT,
     1                      IOFLG
C
C     ------------------------------------------------------------------
      logical, intent(inout) :: UseTSDefaults
      CALL SGWF2BAS7PNT(IGRID)
C
C1------TEST UNIT NUMBER (INOC (INOC=IUNIT(12))) TO SEE IF
C1------OUTPUT CONTROL IS ACTIVE.  IF NOT, SET DEFAULTS AND RETURN.
      IF(INOC.LE.0) THEN
         IHDDFL=0
         IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP(KPER))IHDDFL=1
         IBUDFL=0
         IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP(KPER))IBUDFL=1
         ICBCFL=0
         UseTSDefaults = .true.
         GO TO 1000    ! RETURN
      END IF
      UseTSDefaults = .false.
C
C2------OUTPUT CONTROL IS ACTIVE.  IF IPEROC >= 0, READ OUTPUT FLAGS
C2------USING ALPHABETIC INPUT STRUCTURE.
      IF(IPEROC.GE.0) THEN
         CALL SGWF2BAS7N(KPER,KSTP,INOC,IOUT,NLAY)
         GO TO 600
      END IF
C
C3------READ AND PRINT OUTPUT FLAGS AND CODE FOR DEFINING IOFLG USING
C3------THE ORIGINAL NUMERIC INPUT STRUCTURE.
      IF(IFREFM.EQ.0) THEN
         READ(INOC,'(4I10)') INCODE,IHDDFL,IBUDFL,ICBCFL
      ELSE
         READ(INOC,*) INCODE,IHDDFL,IBUDFL,ICBCFL
      END IF
      WRITE(IOUT,3) IHDDFL,IBUDFL,ICBCFL
    3 FORMAT(1X,/1X,'HEAD/DRAWDOWN PRINTOUT FLAG =',I2,
     1    5X,'TOTAL BUDGET PRINTOUT FLAG =',I2,
     2   /1X,'CELL-BY-CELL FLOW TERM FLAG =',I2)
      IF(ICBCFL.NE.0) ICBCFL=IBDOPT
C
C4------DECODE INCODE TO DETERMINE HOW TO SET FLAGS IN IOFLG.
      IF(INCODE.LT.0) THEN
C
C5------INCODE <0, USE IOFLG FROM LAST TIME STEP.
        WRITE(IOUT,101)
  101   FORMAT(1X,'REUSING PREVIOUS VALUES OF IOFLG')
      ELSE IF(INCODE.EQ.0) THEN
C
C6------INCODE=0, READ IOFLG FOR LAYER 1 AND ASSIGN SAME TO ALL LAYERS
        IF(IFREFM.EQ.0) THEN
           READ(INOC,'(4I10)') (IOFLG(1,M),M=1,4)
        ELSE
           READ(INOC,*) (IOFLG(1,M),M=1,4)
        END IF
        IOFLG(1,5)=0
        DO 210 K=1,NLAY
        IOFLG(K,1)=IOFLG(1,1)
        IOFLG(K,2)=IOFLG(1,2)
        IOFLG(K,3)=IOFLG(1,3)
        IOFLG(K,4)=IOFLG(1,4)
        IOFLG(K,5)=IOFLG(1,5)
  210   CONTINUE
        WRITE(IOUT,211) (IOFLG(1,M),M=1,4)
  211   FORMAT(1X,/1X,'OUTPUT FLAGS FOR ALL LAYERS ARE THE SAME:'/
     1     1X,'  HEAD    DRAWDOWN  HEAD  DRAWDOWN'/
     2     1X,'PRINTOUT  PRINTOUT  SAVE    SAVE'/
     3     1X,34('-')/1X,I5,I10,I8,I8)
      ELSE
C
C7------INCODE>0, READ IOFLG IN ENTIRETY -- IF CROSS SECTION, READ ONLY
C7------ONE VALUE.
        IF(IXSEC.EQ.0) THEN
           DO 301 K=1,NLAY
           IF(IFREFM.EQ.0) THEN
              READ(INOC,'(4I10)') (IOFLG(K,M),M=1,4)
           ELSE
              READ(INOC,*) (IOFLG(K,M),M=1,4)
           END IF
           IOFLG(K,5)=0
  301      CONTINUE
           WRITE(IOUT,302) 'OUTPUT FLAGS FOR EACH LAYER:','LAYER'
  302      FORMAT(1X,/1X,A,/
     1     1X,'         HEAD    DRAWDOWN  HEAD  DRAWDOWN'/
     2     1X,A,'  PRINTOUT  PRINTOUT  SAVE    SAVE'/
     3     1X,41('-'))
           WRITE(IOUT,303) (K,(IOFLG(K,M),M=1,4),K=1,NLAY)
  303      FORMAT(1X,I4,I8,I10,I8,I8)
        ELSE
           IF(IFREFM.EQ.0) THEN
              READ(INOC,'(4I10)') (IOFLG(1,M),M=1,4)
           ELSE
              READ(INOC,*) (IOFLG(1,M),M=1,4)
           END IF
           WRITE(IOUT,302) 'OUTPUT FLAGS FOR CROSS SECTION:','     '
           WRITE(IOUT,304) (IOFLG(1,M),M=1,4)
  304      FORMAT(1X,I12,I10,I8,I8)
        END IF
      END IF
C
C8------THE LAST STEP IN A STRESS PERIOD AND STEPS WHERE ITERATIVE
C8------PROCEDURE FAILED TO CONVERGE GET A VOLUMETRIC BUDGET.
  600 IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP(KPER)) IBUDFL=1
C
C9------RETURN
 1000 RETURN
C
      END SUBROUTINE GWF2BAS7OC

C###############################################################################

C###############################################################################

      SUBROUTINE SGWF2BAS7N(KPER,KSTP,INOC,IOUT,NLAY)
C     ******************************************************************
C     SET OUTPUT FLAGS USING ALPHABETIC OUTPUT CONTROL INPUT STRUCTURE
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GWFBASMODULE, ONLY: IOFLG,IHDDFL,IBUDFL,ICBCFL,IPEROC,
     1                        ITSOC,IBDOPT,IDDREF,IDDREFNEW
C
      CHARACTER*200 LINE
      double precision :: r
C     ------------------------------------------------------------------
C
C1------ERROR IF OUTPUT CONTROL TIME STEP PRECEDES CURRENT SIMULATION
C1------TIME STEP.
      IF((IPEROC.LT.KPER).OR.(IPEROC.EQ.KPER .AND. ITSOC.LT.KSTP)) THEN
         WRITE(IOUT,5) IPEROC,ITSOC,KPER,KSTP
    5    FORMAT(1X,/1X,'OUTPUT CONTROL WAS SPECIFIED FOR A NONEXISTENT',
     1   ' TIME STEP',/
     2   1X,'OR OUTPUT CONTROL DATA ARE NOT ENTERED IN ASCENDING ORDER',
     3   /1X,'OUTPUT CONTROL STRESS PERIOD ',I4,'   TIME STEP',I5,/
     4   1X,'MODEL STRESS PERIOD ',I4,'   TIME STEP',I5,/
     5   1X,'APPLYING THE SPECIFIED OUTPUT CONTROL TO THE CURRENT TIME',
     6   ' STEP')
         IPEROC=KPER
         ITSOC=KSTP
      END IF
C
C2------CLEAR I/O FLAGS.
      IHDDFL=0
      IBUDFL=0
      ICBCFL=0
      DO 10 I=1,5
      DO 10 K=1,NLAY
      IOFLG(K,I)=0
10    CONTINUE
C
C3------IF OUTPUT CONTROL TIME STEP DOES NOT MATCH SIMULATION TIME STEP,
C3------WRITE MESSAGE THAT THERE IS NO OUTPUT CONTROL THIS TIME STEP,
C3------AND RETURN.
      IF(IPEROC.NE.KPER .OR. ITSOC.NE.KSTP) THEN
         WRITE(IOUT,11) KPER,KSTP
11       FORMAT(1X,/1X,'NO OUTPUT CONTROL FOR STRESS PERIOD ',I4,
     1              '   TIME STEP',I5)
         RETURN
      END IF
C
C4------OUTPUT CONTROL TIME STEP MATCHES SIMULATION TIME STEP.
      IDDREF=IDDREFNEW
      WRITE(IOUT,12) IPEROC,ITSOC
12    FORMAT(1X,/1X,'OUTPUT CONTROL FOR STRESS PERIOD ',I4,
     1              '   TIME STEP',I5)
      IF(IDDREFNEW.NE.0) WRITE(IOUT,52)
   52      FORMAT(1X,'Drawdown Reference will be reset at the',
     1               ' end of this time step')
C
C4A-----OUTPUT CONTROL MATCHES SIMULATION TIME.  READ NEXT OUTPUT
C4A-----RECORD; SKIP ANY BLANK LINES.
50    READ(INOC,'(A)',END=1000) LINE
      IF(LINE.EQ.' ') GO TO 50
C
C4A1----LOOK FOR "PERIOD", WHICH TERMINATES OUTPUT CONTROL FOR CURRENT
C4A1----TIME STEP.  IF FOUND, DECODE TIME STEP FOR NEXT OUTPUT.
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INOC)
      IF(LINE(ISTART:ISTOP).EQ.'PERIOD') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IPEROC,R,IOUT,INOC)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INOC)
         IF(LINE(ISTART:ISTOP).NE.'STEP') GO TO 2000
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,ITSOC,R,IOUT,INOC)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INOC)
         IF(LINE(ISTART:ISTOP).EQ.'DDREFERENCE') THEN
           IDDREFNEW=1
         ELSE
           IDDREFNEW=0
         END IF
         RETURN
C
C4A2----LOOK FOR "PRINT", WHICH MAY REFER TO "BUDGET", "HEAD", OR
C4A2----"DRAWDOWN".
      ELSE IF(LINE(ISTART:ISTOP).EQ.'PRINT') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INOC)
         IF(LINE(ISTART:ISTOP).EQ.'BUDGET') THEN
            WRITE(IOUT,53)
53          FORMAT(4X,'PRINT BUDGET')
            IBUDFL=1
         ELSE IF(LINE(ISTART:ISTOP).EQ.'HEAD') THEN
            CALL SGWF2BAS7L(1,LINE,LLOC,IOFLG,NLAY,IOUT,'PRINT HEAD',
     1              INOC)
            IHDDFL=1
         ELSE IF(LINE(ISTART:ISTOP).EQ.'DRAWDOWN') THEN
            CALL SGWF2BAS7L(2,LINE,LLOC,IOFLG,NLAY,IOUT,
     1              'PRINT DRAWDOWN',INOC)
            IHDDFL=1
         ELSE
            GO TO 2000
         END IF
C
C4A3----LOOK FOR "SAVE", WHICH MAY REFER TO "BUDGET", "HEAD",
C4A3----"DRAWDOWN", OR "IBOUND".
      ELSE IF(LINE(ISTART:ISTOP).EQ.'SAVE') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INOC)
         IF(LINE(ISTART:ISTOP).EQ.'BUDGET') THEN
            WRITE(IOUT,57)
57          FORMAT(4X,'SAVE BUDGET')
            ICBCFL=IBDOPT
         ELSE IF(LINE(ISTART:ISTOP).EQ.'HEAD') THEN
            CALL SGWF2BAS7L(3,LINE,LLOC,IOFLG,NLAY,IOUT,'SAVE HEAD',
     &                      INOC)
            IHDDFL=1
         ELSE IF(LINE(ISTART:ISTOP).EQ.'DRAWDOWN') THEN
            CALL SGWF2BAS7L(4,LINE,LLOC,IOFLG,NLAY,IOUT,'SAVE DRAWDOWN',
     1          INOC)
            IHDDFL=1
         ELSE IF(LINE(ISTART:ISTOP).EQ.'IBOUND') THEN
            CALL SGWF2BAS7L(5,LINE,LLOC,IOFLG,NLAY,IOUT,'SAVE IBOUND',
     1                     INOC)
            IHDDFL=1
         ELSE
            GO TO 2000
         END IF
C
C4A4----WHEN NO KNOWN ALPHABETIC WORDS ARE FOUND, THERE IS AN ERROR.
      ELSE
         GO TO 2000
C
C4B-----AFTER SUCCESSFULLY DECODING ONE RECORD, READ ANOTHER.
      END IF
      GO TO 50
C
C5------END OF FILE WHILE READING AN OUTPUT CONTROL RECORD, SO THERE
C5------WILL BE NO FURTHER OUTPUT.  SET IPEROC AND ITSOC HIGH ENOUGH
C5------THAT THE MODEL TIME WILL NEVER MATCH THEM.
1000  IPEROC=9999
      ITSOC=9999
      RETURN
C
C6------ERROR DECODING ALPHABETIC INPUT STRUCTURE.
2000  WRITE(IOUT,2001) LINE
2001  FORMAT(1X,/1X,'ERROR READING OUTPUT CONTROL INPUT DATA:'/1X,A80)
      CALL USTOPx(' ')
      END SUBROUTINE SGWF2BAS7N

C###############################################################################

      SUBROUTINE SGWF2BAS7L(IPOS,LINE,LLOC,IOFLG,NLAY,IOUT,LABEL,INOC)
C     ******************************************************************
C     WHEN USING ALPHABETIC OUTPUT CONTROL, DECODE LAYER
C     NUMBERS FOR PRINTING OR SAVING HEAD OR DRAWDOWN
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION IOFLG(NLAY,5)
      CHARACTER*200 LINE
      CHARACTER*(*) LABEL
      DIMENSION LAYER(999)
      double precision :: r
C     ------------------------------------------------------------------
C
C1------INITIALIZE COUNTER FOR NUMBER OF LAYERS FOR WHICH OUTPUT IS
C1------SPECIFIED.
      NSET=0
C
C2------CHECK FOR A VALID LAYER NUMBER.  WHEN FOUND, SET FLAG AND
C2------REPEAT.
10    CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,L,R,-1,INOC)
      IF(L.GT.0 .AND. L.LE.NLAY) THEN
         NSET=NSET+1
         LAYER(NSET)=L
         IOFLG(L,IPOS)=1
         GO TO 10
      END IF
C
C3------DONE CHECKING FOR LAYER NUMBERS.  IF NO LAYER NUMBERS WERE
C3------FOUND, SET FLAGS FOR ALL LAYERS.
      IF(NSET.EQ.0) THEN
         DO 110 K=1,NLAY
         IOFLG(K,IPOS)=1
110      CONTINUE
         WRITE(IOUT,111) LABEL
111      FORMAT(4X,A,' FOR ALL LAYERS')
C
C4------IF ONE OR MORE LAYER NUMBERS WERE FOUND, PRINT THE NUMBERS.
      ELSE
         WRITE(IOUT,112) LABEL,(LAYER(M),M=1,NSET)
112      FORMAT(4X,A,' FOR LAYERS:',(1X,15I3))
      END IF
C
C5------RETURN.
      RETURN
      END SUBROUTINE SGWF2BAS7L

      end module GwfBasOcSubsModule
