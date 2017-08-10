      module GwfEtsSubs
        
      use GWFETSMODULE, only: SGWF2ETS7PNT, SGWF2ETS7PSV
        
      contains

      SUBROUTINE GWF2ETS7AR(IN,IGRID)
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR EVAPOTRANSPIRATION SEGMENTS AND READ
C     PARAMETER DEFINITIONS
C     Modified 11/21/2001 to support parameter instances - ERB
C     Modified 8/17/2009 to support NETSOP=3 - ERB
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,IFREFM
      USE GWFETSMODULE, ONLY:NETSOP,IETSCB,NPETS,IETSPF,NETSEG,
     1                       IETS,ETSR,ETSX,ETSS,PXDP,PETM
      use utl7module, only: U1DREL, U2DREL, ! UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, ! UBDSV4, UBDSVB,
     &                      ULSTRD
      use SimModule, only: ustop
C
      CHARACTER*4 PTYP
      CHARACTER*200 LINE
      double precision :: r
C     ------------------------------------------------------------------
  500 FORMAT(1X,/
     &1X,'ETS7 -- EVAPOTRANSPIRATION SEGMENTS PACKAGE, VERSION 7,',
     &     ' 2/28/2006',/,9X,'INPUT READ FROM UNIT ',I4)
  510 FORMAT(
     &1X,I5,' SEGMENTS DEFINE EVAPOTRANSPIRATION RATE FUNCTION')
  520 FORMAT(' EVAPOTRANSPIRATION RATE FUNCTION IS LINEAR')
  530 FORMAT(
     &' ERROR: EVAPOTRANSPIRATION RATE FUNCTION MUST CONTAIN AT',/,
     &' LEAST ONE SEGMENT -- STOP EXECUTION (GWF2ETS7ALP)')
  540 FORMAT(1X,'ILLEGAL ET OPTION CODE. SIMULATION ABORTING')
  550 FORMAT(1X,'OPTION 1 -- EVAPOTRANSPIRATION FROM TOP LAYER')
  560 FORMAT(1X,'OPTION 2 -- EVAPOTRANSPIRATION FROM ONE SPECIFIED',
     &   ' NODE IN EACH VERTICAL COLUMN')
  564 FORMAT(1X,'OPTION 3 -- EVAPOTRANSPIRATION FROM UPPERMOST ACTIVE ',
     &   'CELL')
  570 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT ',I4)
  580 FORMAT(1X,I10,' ELEMENTS IN RX ARRAY ARE USED BY ETS')
  590 FORMAT(1X,I10,' ELEMENTS IN IR ARRAY ARE USED BY ETS')
C
      ALLOCATE (NETSOP,IETSCB,NPETS,IETSPF,NETSEG)
C
C1------IDENTIFY PACKAGE.
      IETSPF=20
      WRITE(IOUT,500)IN
C
C     READ COMMENT LINE(S) (ITEM 0)
      CALL URDCOM(IN,IOUT,LINE)
C
C2------READ ET OPTION (NETSOP), UNIT OR FLAG FOR CELL-BY-CELL FLOW
C       TERMS (IETSCB), NUMBER OF PARAMETERS (NPETS), AND NUMBER OF
C       SEGMENTS (NETSEG) (ITEM 1)
      IF (IFREFM.EQ.0) THEN
        READ(LINE,'(4I10)') NETSOP,IETSCB,NPETS,NETSEG
      ELSE
        LLOC=1
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NETSOP,R,IOUT,IN)
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IETSCB,R,IOUT,IN)
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NPETS,R,IOUT,IN)
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NETSEG,R,IOUT,IN)
      ENDIF
C
C3------CHECK TO SEE THAT ET OPTION IS LEGAL.
      IF (NETSOP.GE.1 .AND. NETSOP.LE.3) GO TO 10
C
C3A-----OPTION IS ILLEGAL -- PRINT A MESSAGE & ABORT SIMULATION.
      WRITE(IOUT,540)
      CALL USTOP(' ')
C
C4------OPTION IS LEGAL -- PRINT THE OPTION CODE.
   10 CONTINUE
      IF (NETSOP.EQ.1) WRITE(IOUT,550)
      IF (NETSOP.EQ.2) WRITE(IOUT,560)
      IF (NETSOP.EQ.3) WRITE(IOUT,564) ! Add option 3 ERB 5/8/2009
C
C5------IF CELL-BY-CELL FLOWS ARE TO BE SAVED, THEN PRINT UNIT NUMBER.
      IF (IETSCB.GT.0) WRITE(IOUT,570) IETSCB
C
C-----PRINT NUMBER OF PARAMETERS TO BE USED
      CALL UPARARRAL(-1,IOUT,LINE,NPETS)
C
C     PRINT MESSAGE IDENTIFYING NUMBER OF SEGMENTS IN ET VS. HEAD CURVE
      IF(NETSEG.GT.1) THEN
        WRITE(IOUT,510) NETSEG
      ELSEIF (NETSEG.EQ.1) THEN
        WRITE(IOUT,520)
      ELSE
        WRITE(IOUT,530)
        CALL USTOP(' ')
      ENDIF
C
C6------ALLOCATE SPACE FOR THE ARRAYS ETSR, ETSX, ETSS, PXDP, AND PETM.
      ALLOCATE (ETSR(NCOL,NROW))
      ALLOCATE (ETSX(NCOL,NROW))
      ALLOCATE (ETSS(NCOL,NROW))
      IF( NETSEG.GT.1) THEN
        ALLOCATE (PXDP(NCOL,NROW,NETSEG))
        ALLOCATE (PETM(NCOL,NROW,NETSEG))
      ELSE
        ALLOCATE (PXDP(1,1,1))
        ALLOCATE (PETM(1,1,1))
      END IF
C
C7------ALLOCATE SPACE FOR LAYER INDICATOR ARRAY (IETS) EVEN IF ET
C7------OPTION IS NOT 2.
      ALLOCATE (IETS(NCOL,NROW))
C
C-------READ NAMED PARAMETERS
      WRITE(IOUT,50) NPETS
   50 FORMAT(1X,//1X,I5,' Evapotranspiration segments parameters')
      IF (NPETS.GT.0) THEN
        DO100 K=1,NPETS
C         UPARARRRP READS PARAMETER NAME AND DEFINITION (ITEMS 2 AND 3)
          CALL UPARARRRP(IN,IOUT,N,0,PTYP,1,1,0)
          IF(PTYP.NE.'ETS') THEN
            WRITE(IOUT,57)
   57       FORMAT(1X,'Parameter type must be ETS')
            CALL USTOP(' ')
          ENDIF
  100   CONTINUE
      ENDIF
C
C8------RETURN
      CALL SGWF2ETS7PSV(IGRID)
      RETURN
      END

C*******************************************************************************

      SUBROUTINE GWF2ETS7RP(IN,IGRID)
C     ******************************************************************
C     READ EVAPOTRANSPIRATION DATA, AND PERFORM SUBSTITUTION USING
C     PARAMETER VALUES IF ETS PARAMETERS ARE DEFINED
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:NCOL,NROW,IOUT,DELR,DELC,IFREFM
      USE GWFETSMODULE, ONLY:NETSOP,NETSEG,NPETS,IETSPF,
     1                       IETS,ETSR,ETSX,ETSS,PXDP,PETM
      use utl7module, only: U1DREL, U2DREL, !UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, !UBDSV4, UBDSVB,
     &                      ULSTRD, u2dint
      use SimModule, only: ustop
C
      CHARACTER*24 ANAME(6)
      DATA ANAME(1) /'   ET LAYER INDEX (IETS)'/
      DATA ANAME(2) /'       ET SURFACE (ETSS)'/
      DATA ANAME(3) /' EVAPOTRANS. RATE (ETSR)'/
      DATA ANAME(4) /' EXTINCTION DEPTH (ETSX)'/
      DATA ANAME(5) /'EXTINCT. DEP. PROPORTION'/
      DATA ANAME(6) /'      ET RATE PROPORTION'/
C     ------------------------------------------------------------------
      CALL SGWF2ETS7PNT(IGRID)
C
C1------READ FLAGS SHOWING WHETHER DATA FROM PREVIOUS STRESS PERIOS ARE
C       TO BE REUSED.
      IF (NETSEG.GT.1) THEN
        IF(IFREFM.EQ.0) THEN
          READ(IN,'(5I10)') INETSS,INETSR,INETSX,INIETS,INSGDF
        ELSE
          READ(IN,*) INETSS,INETSR,INETSX,INIETS,INSGDF
        ENDIF
      ELSE
        IF(NETSOP.EQ.2) THEN
          IF(IFREFM.EQ.0) THEN
            READ(IN,'(4I10)') INETSS,INETSR,INETSX,INIETS
          ELSE
            READ(IN,*) INETSS,INETSR,INETSX,INIETS
          ENDIF
        ELSE
          IF(IFREFM.EQ.0) THEN
            READ(IN,'(3I10)') INETSS,INETSR,INETSX
          ELSE
            READ(IN,*) INETSS,INETSR,INETSX
          ENDIF
        ENDIF
      ENDIF
C
C2------TEST INETSS TO SEE WHERE SURFACE ELEVATION COMES FROM.
      IF (INETSS.LT.0) THEN
C2A------IF INETSS<0 THEN REUSE SURFACE ARRAY FROM LAST STRESS PERIOD
        WRITE(IOUT,10)
   10   FORMAT(1X,/1X,'REUSING ETSS FROM LAST STRESS PERIOD')
      ELSE
C3-------IF INETSS=>0 THEN CALL MODULE U2DREL TO READ SURFACE.
        CALL U2DREL(ETSS,ANAME(2),NROW,NCOL,0,IN,IOUT)
      ENDIF
C
C4------TEST INETSR TO SEE WHERE MAX ET RATE COMES FROM.
      IF (INETSR.LT.0) THEN
C4A-----IF INETSR<0 THEN REUSE MAX ET RATE.
        WRITE(IOUT,20)
   20   FORMAT(1X,/1X,'REUSING ETSR FROM LAST STRESS PERIOD')
      ELSE
C5------IF INETSR=>0 CALL MODULE U2DREL TO READ MAX ET RATE.
        IF(NPETS.EQ.0) THEN
          CALL U2DREL(ETSR,ANAME(3),NROW,NCOL,0,IN,IOUT)
        ELSE
C    INETSR is the number of parameters to use this stress period
          CALL PRESET('ETS')
          WRITE(IOUT,30)
   30     FORMAT(1X,///1X,
     &        'ETSR array defined by the following parameters:')
          IF (INETSR.EQ.0) THEN
            WRITE(IOUT,35)
   35       FORMAT(' ERROR: When parameters are defined for the ETS',
     &      ' Package, at least one parameter',/,' must be specified',
     &      ' each stress period -- STOP EXECUTION (GWF2ETS7RPSS)')
            CALL USTOP(' ')
          ENDIF
          CALL UPARARRSUB2(ETSR,NCOL,NROW,0,INETSR,IN,IOUT,'ETS',
     &                     ANAME(3),'ETS',IETSPF)
        ENDIF
C
C6------MULTIPLY MAX ET RATE BY CELL AREA TO GET VOLUMETRIC RATE
        DO 50 IR=1,NROW
          DO 40 IC=1,NCOL
            ETSR(IC,IR)=ETSR(IC,IR)*DELR(IC)*DELC(IR)
   40     CONTINUE
   50   CONTINUE
      ENDIF
C
C7------TEST INETSX TO SEE WHERE EXTINCTION DEPTH COMES FROM
      IF (INETSX.LT.0) THEN
C7A------IF INETSX<0 REUSE EXTINCTION DEPTH FROM LAST STRESS PERIOD
        WRITE(IOUT,60)
   60   FORMAT(1X,/1X,'REUSING ETSX FROM LAST STRESS PERIOD')
      ELSE
C8-------IF INETSX=>0 CALL MODULE U2DREL TO READ EXTINCTION DEPTH
        CALL U2DREL(ETSX,ANAME(4),NROW,NCOL,0,IN,IOUT)
      ENDIF
C
C9------IF OPTION(NETSOP) IS 2 THEN WE NEED AN INDICATOR ARRAY.
      IF (NETSOP.EQ.2) THEN
C10------IF INIETS<0 THEN REUSE LAYER INDICATOR ARRAY.
        IF (INIETS.LT.0) THEN
          WRITE(IOUT,70)
   70     FORMAT(1X,/1X,'REUSING IETS FROM LAST STRESS PERIOD')
        ELSE
C11------IF INIETS=>0 THEN CALL MODULE U2DINT TO READ INDICATOR ARRAY.
          CALL U2DINT(IETS,ANAME(1),NROW,NCOL,0,IN,IOUT)
        ENDIF
      ENDIF
C
C12------IF ET FUNCTION IS SEGMENTED PXDP AND PETM ARRAYS ARE NEEDED.
      IF (NETSEG.GT.1) THEN
C13------IF INSGDF<0 THEN REUSE PXDP AND PETM ARRAYS.
        IF (INSGDF.LT.0) THEN
          WRITE(IOUT,80)
   80     FORMAT(1X,/1X,
     &           'REUSING PXDP AND PETM FROM LAST STRESS PERIOD')
C14------IF INSGDF=>0 THEN CALL MODULE U2DREL TO READ PXDP AND PETM
C        ARRAYS.
        ELSE
          DO 90 I = 1,NETSEG-1
            WRITE(IOUT,100) I
            CALL U2DREL(PXDP(:,:,I),ANAME(5),NROW,NCOL,0,IN,IOUT)
            CALL U2DREL(PETM(:,:,I),ANAME(6),NROW,NCOL,0,IN,IOUT)
   90     CONTINUE
        ENDIF
      ENDIF
  100 FORMAT(/,' PXDP AND PETM ARRAYS FOR INTERSECTION ',I4,
     &' OF HEAD/ET RELATION:')
C
C15-----RETURN
      RETURN
      END

      end module GwfEtsSubs
