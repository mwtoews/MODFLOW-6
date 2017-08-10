      MODULE GWFBCFMODULE
       INTEGER, SAVE, POINTER ::IBCFCB,IWDFLG,IWETIT,IHDWET
       double precision, SAVE, POINTER    ::WETFCT
       INTEGER, SAVE,  POINTER,   DIMENSION(:)     ::LAYCON
       INTEGER, SAVE,  POINTER,   DIMENSION(:)     ::LAYAVG
       double precision, SAVE,     POINTER,   DIMENSION(:,:,:) ::HY
       double precision, SAVE,     POINTER,   DIMENSION(:,:,:) ::SC1
       double precision, SAVE,     POINTER,   DIMENSION(:,:,:) ::SC2
       double precision, SAVE,     POINTER,   DIMENSION(:,:,:) ::WETDRY
       double precision, SAVE,     POINTER,   DIMENSION(:,:,:) ::CVWD
       double precision, SAVE,     POINTER,   DIMENSION(:)     ::TRPY
       double precision, save, pointer, dimension(:,:,:) ::vcont=>null()
      TYPE GWFBCFTYPE
       INTEGER, POINTER  ::IBCFCB,IWDFLG,IWETIT,IHDWET
       double precision, POINTER     ::WETFCT
       INTEGER,  POINTER,   DIMENSION(:)     ::LAYCON
       INTEGER,  POINTER,   DIMENSION(:)     ::LAYAVG
       double precision,     POINTER,   DIMENSION(:,:,:) ::HY
       double precision,     POINTER,   DIMENSION(:,:,:) ::SC1
       double precision,     POINTER,   DIMENSION(:,:,:) ::SC2
       double precision,     POINTER,   DIMENSION(:,:,:) ::WETDRY
       double precision,     POINTER,   DIMENSION(:,:,:) ::CVWD
       double precision,     POINTER,   DIMENSION(:)     ::TRPY
       double precision, pointer, dimension(:,:,:) :: vcont => null()
      END TYPE
      TYPE(GWFBCFTYPE), SAVE  ::GWFBCFDAT(10)
      
      contains
      
      SUBROUTINE GWF2BCF7DA(IGRID)
      !USE GWFBCFMODULE
C
      DEALLOCATE(GWFBCFDAT(IGRID)%IBCFCB)
      DEALLOCATE(GWFBCFDAT(IGRID)%IWDFLG)
      DEALLOCATE(GWFBCFDAT(IGRID)%IWETIT)
      DEALLOCATE(GWFBCFDAT(IGRID)%IHDWET)
      DEALLOCATE(GWFBCFDAT(IGRID)%WETFCT)
      DEALLOCATE(GWFBCFDAT(IGRID)%LAYCON)
      DEALLOCATE(GWFBCFDAT(IGRID)%LAYAVG)
      DEALLOCATE(GWFBCFDAT(IGRID)%HY)
      DEALLOCATE(GWFBCFDAT(IGRID)%SC1)
      DEALLOCATE(GWFBCFDAT(IGRID)%SC2)
      DEALLOCATE(GWFBCFDAT(IGRID)%WETDRY)
      DEALLOCATE(GWFBCFDAT(IGRID)%CVWD)
      DEALLOCATE(GWFBCFDAT(IGRID)%TRPY)
      deallocate(GWFBCFDAT(igrid)%vcont)
C
      RETURN
      END SUBROUTINE GWF2BCF7DA

C     ******************************************************************

      SUBROUTINE SGWF2BCF7PNT(IGRID)
      !USE GWFBCFMODULE
C
      IBCFCB=>GWFBCFDAT(IGRID)%IBCFCB
      IWDFLG=>GWFBCFDAT(IGRID)%IWDFLG
      IWETIT=>GWFBCFDAT(IGRID)%IWETIT
      IHDWET=>GWFBCFDAT(IGRID)%IHDWET
      WETFCT=>GWFBCFDAT(IGRID)%WETFCT
      LAYCON=>GWFBCFDAT(IGRID)%LAYCON
      LAYAVG=>GWFBCFDAT(IGRID)%LAYAVG
      HY=>GWFBCFDAT(IGRID)%HY
      SC1=>GWFBCFDAT(IGRID)%SC1
      SC2=>GWFBCFDAT(IGRID)%SC2
      WETDRY=>GWFBCFDAT(IGRID)%WETDRY
      CVWD=>GWFBCFDAT(IGRID)%CVWD
      TRPY=>GWFBCFDAT(IGRID)%TRPY
      vcont=>GWFBCFDAT(igrid)%vcont
C
      RETURN
      END SUBROUTINE SGWF2BCF7PNT

C     ******************************************************************

      SUBROUTINE SGWF2BCF7PSV(IGRID)
      !USE GWFBCFMODULE
C
      GWFBCFDAT(IGRID)%IBCFCB=>IBCFCB
      GWFBCFDAT(IGRID)%IWDFLG=>IWDFLG
      GWFBCFDAT(IGRID)%IWETIT=>IWETIT
      GWFBCFDAT(IGRID)%IHDWET=>IHDWET
      GWFBCFDAT(IGRID)%WETFCT=>WETFCT
      GWFBCFDAT(IGRID)%LAYCON=>LAYCON
      GWFBCFDAT(IGRID)%LAYAVG=>LAYAVG
      GWFBCFDAT(IGRID)%HY=>HY
      GWFBCFDAT(IGRID)%SC1=>SC1
      GWFBCFDAT(IGRID)%SC2=>SC2
      GWFBCFDAT(IGRID)%WETDRY=>WETDRY
      GWFBCFDAT(IGRID)%CVWD=>CVWD
      GWFBCFDAT(IGRID)%TRPY=>TRPY
      GWFBCFDAT(igrid)%vcont=>vcont
C
      RETURN
      END SUBROUTINE SGWF2BCF7PSV
      
      END MODULE GWFBCFMODULE

