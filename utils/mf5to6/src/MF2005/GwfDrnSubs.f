      module GwfDrnSubs
        
        use GwfDrnModule, only: SGWF2DRN7PNT, SGWF2DRN7PSV
        
      contains

      SUBROUTINE GWF2DRN7AR(IN,IGRID)
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR DRAINS AND READ PARAMETER DEFINITIONS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFDRNMODULE, ONLY:NDRAIN,MXDRN,NDRNVL,IDRNCB,IPRDRN,NPDRN,
     1                       IDRNPB,NNPDRN,DRNAUX,DRAI
      use utl7module, only: U1DREL, U2DREL, ! UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, ! UBDSV4, UBDSVB,
     &                      ULSTRD
      CHARACTER*200 LINE
      double precision :: r
C     ------------------------------------------------------------------
      ALLOCATE(NDRAIN,MXDRN,NDRNVL,IDRNCB,IPRDRN)
      ALLOCATE(NPDRN,IDRNPB,NNPDRN)
C
C1------IDENTIFY PACKAGE AND INITIALIZE NDRAIN.
      WRITE(IOUT,1)IN
    1 FORMAT(1X,/1X,'DRN -- DRAIN PACKAGE, VERSION 7, 5/2/2005',
     1' INPUT READ FROM UNIT ',I4)
      NDRAIN=0
      NNPDRN=0
C
C2------READ MAXIMUM NUMBER OF DRAINS AND UNIT OR FLAG FOR
C2------CELL-BY-CELL FLOW TERMS.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPDRN,MXPD)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(2I10)') MXACTD,IDRNCB
         LLOC=21
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXACTD,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IDRNCB,R,IOUT,IN)
      END IF
      WRITE(IOUT,3) MXACTD
    3 FORMAT(1X,'MAXIMUM OF ',I6,' ACTIVE DRAINS AT ONE TIME')
      IF(IDRNCB.LT.0) WRITE(IOUT,7)
    7 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
         IF(IDRNCB.GT.0) WRITE(IOUT,8) IDRNCB
    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT ',I4)
C
C3------READ AUXILIARY VARIABLES AND CBC ALLOCATION OPTION.
      ALLOCATE (DRNAUX(20))
      NAUX=0
      IPRDRN=1
   10 CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'AUXILIARY' .OR.
     1        LINE(ISTART:ISTOP).EQ.'AUX') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
         IF(NAUX.LT.20) THEN
            NAUX=NAUX+1
            DRNAUX(NAUX)=LINE(ISTART:ISTOP)
            WRITE(IOUT,12) DRNAUX(NAUX)
   12       FORMAT(1X,'AUXILIARY DRAIN VARIABLE: ',A)
         END IF
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'NOPRINT') THEN
         WRITE(IOUT,13)
   13    FORMAT(1X,'LISTS OF DRAIN CELLS WILL NOT BE PRINTED')
         IPRDRN = 0
         GO TO 10
      END IF
C3A-----THERE ARE FIVE INPUT DATA VALUES PLUS ONE LOCATION FOR
C3A-----CELL-BY-CELL FLOW.
      NDRNVL=6+NAUX
C
C4------ALLOCATE SPACE FOR DRAIN ARRAYs.
      IDRNPB=MXACTD+1
      MXDRN=MXACTD+MXPD
      ALLOCATE (DRAI(NDRNVL,MXDRN))
C
C5------READ NAMED PARAMETERS.
      WRITE(IOUT,1000) NPDRN
 1000 FORMAT(1X,//1X,I5,' Drain parameters')
      IF(NPDRN.GT.0) THEN
        LSTSUM=IDRNPB
        DO 120 K=1,NPDRN
          LSTBEG=LSTSUM
          CALL UPARLSTRP(LSTSUM,MXDRN,IN,IOUT,IP,'DRN','DRN',1,
     &                   NUMINST, .true.)
          NLST=LSTSUM-LSTBEG
          IF(NUMINST.EQ.0) THEN
C5A-----READ PARAMETER WITHOUT INSTANCES
            CALL ULSTRD(NLST,DRAI,LSTBEG,NDRNVL,MXDRN,1,IN,IOUT,
     &      'DRAIN NO.  LAYER   ROW   COL     DRAIN EL.  STRESS FACTOR',
     &        DRNAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRDRN)
          ELSE
C5B-----READ INSTANCES
            NINLST=NLST/NUMINST
            DO 110 I=1,NUMINST
            CALL UINSRP(I,IN,IOUT,IP,IPRDRN)
            CALL ULSTRD(NINLST,DRAI,LSTBEG,NDRNVL,MXDRN,1,IN,IOUT,
     &      'DRAIN NO.  LAYER   ROW   COL     DRAIN EL.  STRESS FACTOR',
     &        DRNAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRDRN)
            LSTBEG=LSTBEG+NINLST
  110       CONTINUE
          END IF
  120   CONTINUE
      END IF
C
C6------RETURN
      CALL SGWF2DRN7PSV(IGRID)
      RETURN
      END SUBROUTINE GWF2DRN7AR

C*******************************************************************************

      SUBROUTINE GWF2DRN7RP(IN,IGRID)
C     ******************************************************************
C     READ DRAIN HEAD, CONDUCTANCE AND BOTTOM ELEVATION
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFDRNMODULE, ONLY:NDRAIN,MXDRN,NDRNVL,IPRDRN,NPDRN,
     1                       IDRNPB,NNPDRN,DRNAUX,DRAI
      use utl7module, only: U1DREL, U2DREL, ! UBDSV1, UBDSV2, UBDSVA,
     &                      urword, URDCOM, ! UBDSV4, UBDSVB,
     &                      ULSTRD
      use SimModule, only: ustop
C     ------------------------------------------------------------------
      CALL SGWF2DRN7PNT(IGRID)
C
C1------READ ITMP (NUMBER OF DRAINS OR FLAG TO REUSE DATA) AND
C1------NUMBER OF PARAMETERS.
      IF(NPDRN.GT.0) THEN
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
      NAUX=NDRNVL-6
      IOUTU = IOUT
      IF(IPRDRN.EQ.0) IOUTU=-IOUT
C
C2------DETERMINE THE NUMBER OF NON-PARAMETER DRAINS.
      IF(ITMP.LT.0) THEN
         WRITE(IOUT,7)
    7    FORMAT(1X,/1X,
     1        'REUSING NON-PARAMETER DRAINS FROM LAST STRESS PERIOD')
      ELSE
         NNPDRN=ITMP
      END IF
C
C3------IF THERE ARE NEW NON-PARAMETER DRAINS, READ THEM.
      MXACTD=IDRNPB-1
      IF(ITMP.GT.0) THEN
         IF(NNPDRN.GT.MXACTD) THEN
            WRITE(IOUT,99) NNPDRN,MXACTD
   99       FORMAT(1X,/1X,'THE NUMBER OF ACTIVE DRAINS (',I6,
     1                     ') IS GREATER THAN MXACTD(',I6,')')
            CALL USTOP(' ')
         END IF
         CALL ULSTRD(NNPDRN,DRAI,1,NDRNVL,MXDRN,1,IN,IOUT,
     1     'DRAIN NO.  LAYER   ROW   COL     DRAIN EL.  CONDUCTANCE',
     2     DRNAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,IPRDRN)
      END IF
      NDRAIN=NNPDRN
C
C1C-----IF THERE ARE ACTIVE DRN PARAMETERS, READ THEM AND SUBSTITUTE
      CALL PRESET('DRN')
      IF(NP.GT.0) THEN
         NREAD=NDRNVL-1
         DO 30 N=1,NP
         CALL UPARLSTSUB(IN,'DRN',IOUTU,'DRN',DRAI,NDRNVL,MXDRN,NREAD,
     1                MXACTD,NDRAIN,5,5,
     2     'DRAIN NO.  LAYER   ROW   COL     DRAIN EL.  CONDUCTANCE',
     3            DRNAUX,20,NAUX)
   30    CONTINUE
      END IF
C
C3------PRINT NUMBER OF DRAINS IN CURRENT STRESS PERIOD.
      WRITE (IOUT,101) NDRAIN
  101 FORMAT(1X,/1X,I6,' DRAINS')
C
C8------RETURN.
  260 RETURN
      END SUBROUTINE GWF2DRN7RP

      end module GwfDrnSubs
      
