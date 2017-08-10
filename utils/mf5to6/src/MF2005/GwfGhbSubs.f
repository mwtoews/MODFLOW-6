      module GwfGhbSubs
        
        use GwfGhbModule, only: SGWF2GHB7PNT, SGWF2GHB7PSV
        
      contains

      SUBROUTINE GWF2GHB7AR(IN,IGRID)
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE AND READ PARAMETER DEFINITIONS FOR GHB
C     PACKAGE
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFGHBMODULE, ONLY:NBOUND,MXBND,NGHBVL,IGHBCB,IPRGHB,NPGHB,
     1                       IGHBPB,NNPGHB,GHBAUX,BNDS
      use utl7module, only: U1DREL, U2DREL, !UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, !UBDSV4, UBDSVB,
     &                      ULSTRD
C
      CHARACTER*200 LINE
      double precision :: r
C     ------------------------------------------------------------------
      ALLOCATE(NBOUND,MXBND,NGHBVL,IGHBCB,IPRGHB)
      ALLOCATE(NPGHB,IGHBPB,NNPGHB)
C
C1------IDENTIFY PACKAGE AND INITIALIZE NBOUND.
      WRITE(IOUT,1)IN
    1 FORMAT(1X,/1X,'GHB -- GENERAL-HEAD BOUNDARY PACKAGE, VERSION 7',
     1   ', 5/2/2005',/,9X,'INPUT READ FROM UNIT ',I4)
      NBOUND=0
      NNPGHB=0
C
C2------READ MAXIMUM NUMBER OF GHB'S AND UNIT OR FLAG FOR
C2------CELL-BY-CELL FLOW TERMS.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPGHB,MXPB)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(2I10)') MXACTB,IGHBCB
         LLOC=21
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXACTB,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IGHBCB,R,IOUT,IN)
      END IF
      WRITE(IOUT,3) MXACTB
    3 FORMAT(1X,'MAXIMUM OF ',I6,' ACTIVE GHB CELLS AT ONE TIME')
      IF(IGHBCB.LT.0) WRITE(IOUT,7)
    7 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
      IF(IGHBCB.GT.0) WRITE(IOUT,8) IGHBCB
    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT ',I4)
C
C3------READ AUXILIARY VARIABLES AND PRINT OPTION.
      ALLOCATE (GHBAUX(20))
      NAUX=0
      IPRGHB=1
   10 CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'AUXILIARY' .OR.
     1        LINE(ISTART:ISTOP).EQ.'AUX') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
         IF(NAUX.LT.5) THEN
            NAUX=NAUX+1
            GHBAUX(NAUX)=LINE(ISTART:ISTOP)
            WRITE(IOUT,12) GHBAUX(NAUX)
   12       FORMAT(1X,'AUXILIARY GHB VARIABLE: ',A)
         END IF
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'NOPRINT') THEN
         WRITE(IOUT,13)
   13    FORMAT(1X,'LISTS OF GENERAL-HEAD BOUNDARY CELLS WILL NOT BE',
     &          ' PRINTED')
         IPRGHB = 0
         GO TO 10
      END IF
C3A-----THERE ARE FIVE INPUT DATA VALUES PLUS ONE LOCATION FOR
C3A-----CELL-BY-CELL FLOW.
      NGHBVL=6+NAUX
C
C4------ALLOCATE SPACE FOR THE BNDS ARRAY.
      IGHBPB=MXACTB+1
      MXBND=MXACTB+MXPB
      ALLOCATE (BNDS(NGHBVL,MXBND))
C
C-------READ NAMED PARAMETERS.
      WRITE(IOUT,1000) NPGHB
 1000 FORMAT(1X,//1X,I5,' GHB parameters')
      IF(NPGHB.GT.0) THEN
        NAUX=NGHBVL-6
        LSTSUM=IGHBPB
        DO 120 K=1,NPGHB
          LSTBEG=LSTSUM
          CALL UPARLSTRP(LSTSUM,MXBND,IN,IOUT,IP,'GHB','GHB',1,
     &                  NUMINST, .true.)
          NLST=LSTSUM-LSTBEG
          IF (NUMINST.EQ.0) THEN
C5A-----READ LIST OF CELLS WITHOUT INSTANCES.
            CALL ULSTRD(NLST,BNDS,LSTBEG,NGHBVL,MXBND,1,IN,IOUT,
     &      'BOUND. NO. LAYER   ROW   COL     STAGE    STRESS FACTOR',
     &      GHBAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRGHB)
          ELSE
C5B-----READ INSTANCES
            NINLST=NLST/NUMINST
            DO 110 I=1,NUMINST
            CALL UINSRP(I,IN,IOUT,IP,IPRGHB)
            CALL ULSTRD(NINLST,BNDS,LSTBEG,NGHBVL,MXBND,1,IN,IOUT,
     &      'BOUND. NO. LAYER   ROW   COL     STAGE    STRESS FACTOR',
     &      GHBAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRGHB)
            LSTBEG=LSTBEG+NINLST
  110       CONTINUE
          END IF
  120   CONTINUE
      END IF
C
C6------RETURN
      CALL SGWF2GHB7PSV(IGRID)
      RETURN
      END SUBROUTINE GWF2GHB7AR

C*******************************************************************************

      SUBROUTINE GWF2GHB7RP(IN,IGRID)
C     ******************************************************************
C     READ GHB HEAD, CONDUCTANCE AND BOTTOM ELEVATION
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFGHBMODULE, ONLY:NBOUND,MXBND,NGHBVL,IPRGHB,NPGHB,
     1                       IGHBPB,NNPGHB,GHBAUX,BNDS
      use utl7module, only: U1DREL, U2DREL, ! UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, !UBDSV4, UBDSVB,
     &                      ULSTRD
      use SimModule, only: ustop
C     ------------------------------------------------------------------
      CALL SGWF2GHB7PNT(IGRID)
C
C1------READ ITMP (NUMBER OF GHB'S OR FLAG TO REUSE DATA) AND
C1------NUMBER OF PARAMETERS.
      IF(NPGHB.GT.0) THEN
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(2I10)') ITMP,NP
         ELSE
            READ(IN,*) ITMP,NP
         END IF
      ELSE
         NP=0
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(I10)') ITMP
         ELSE
            READ(IN,*) ITMP
         END IF
      END IF
C
C------CALCULATE SOME CONSTANTS
      NAUX=NGHBVL-6
      IOUTU = IOUT
      IF (IPRGHB.EQ.0) IOUTU=-IOUT
C
C2------DETERMINE THE NUMBER OF NON-PARAMETER GHB'S.
      IF(ITMP.LT.0) THEN
         WRITE(IOUT,7)
    7    FORMAT(1X,/1X,
     1   'REUSING NON-PARAMETER GHB CELLS FROM LAST STRESS PERIOD')
      ELSE
         NNPGHB=ITMP
      END IF
C
C3------IF THERE ARE NEW NON-PARAMETER GHB'S, READ THEM.
      MXACTB=IGHBPB-1
      IF(ITMP.GT.0) THEN
         IF(NNPGHB.GT.MXACTB) THEN
            WRITE(IOUT,99) NNPGHB,MXACTB
   99       FORMAT(1X,/1X,'THE NUMBER OF ACTIVE GHB CELLS (',I6,
     1                     ') IS GREATER THAN MXACTB(',I6,')')
            CALL USTOP(' ')
         END IF
         CALL ULSTRD(NNPGHB,BNDS,1,NGHBVL,MXBND,1,IN,IOUT,
     1      'BOUND. NO. LAYER   ROW   COL     STAGE      CONDUCTANCE',
     2      GHBAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRGHB)
      END IF
      NBOUND=NNPGHB
C
C1C-----IF THERE ARE ACTIVE GHB PARAMETERS, READ THEM AND SUBSTITUTE
      CALL PRESET('GHB')
      IF(NP.GT.0) THEN
         NREAD=NGHBVL-1
         DO 30 N=1,NP
         CALL UPARLSTSUB(IN,'GHB',IOUTU,'GHB',BNDS,NGHBVL,MXBND,NREAD,
     1                MXACTB,NBOUND,5,5,
     2      'BOUND. NO. LAYER   ROW   COL     STAGE      CONDUCTANCE',
     3            GHBAUX,20,NAUX)
   30    CONTINUE
      END IF
C
C3------PRINT NUMBER OF GHB'S IN CURRENT STRESS PERIOD.
      WRITE (IOUT,101) NBOUND
  101 FORMAT(1X,/1X,I6,' GHB CELLS')
C
C8------RETURN.
  260 RETURN
      END SUBROUTINE GWF2GHB7RP

      end module GwfGhbSubs
