      MODULE GWFLPFMODULE
        
        public
        
        INTEGER, SAVE,   POINTER ::ILPFCB,IWDFLG,IWETIT,IHDWET
        INTEGER, SAVE,   POINTER ::ISFAC,ICONCV,ITHFLG,NOCVCO,NOVFC
        double precision,    SAVE,   POINTER ::WETFCT
        INTEGER, SAVE,   POINTER, DIMENSION(:)     ::LAYTYP
        INTEGER, SAVE,   POINTER, DIMENSION(:)     ::LAYAVG
        double precision,    SAVE,   POINTER, DIMENSION(:)     ::CHANI
        INTEGER, SAVE,   POINTER, DIMENSION(:)     ::LAYVKA
        INTEGER, SAVE,   POINTER, DIMENSION(:)     ::LAYWET
        INTEGER, SAVE,   POINTER, DIMENSION(:)     ::LAYSTRT
        INTEGER, SAVE,   POINTER, DIMENSION(:,:)   ::LAYFLG
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::VKA
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::VKCB
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::SC1
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::SC2
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::HANI
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::WETDRY
        double precision,    SAVE,   POINTER, DIMENSION(:,:,:) ::HK
      TYPE GWFLPFTYPE
        INTEGER, POINTER ::ILPFCB,IWDFLG,IWETIT,IHDWET
        INTEGER, POINTER ::ISFAC,ICONCV,ITHFLG,NOCVCO,NOVFC
        double precision, POINTER    ::WETFCT
        INTEGER,   POINTER, DIMENSION(:)     ::LAYTYP
        INTEGER,   POINTER, DIMENSION(:)     ::LAYAVG
        double precision,      POINTER, DIMENSION(:)     ::CHANI
        INTEGER,   POINTER, DIMENSION(:)     ::LAYVKA
        INTEGER,   POINTER, DIMENSION(:)     ::LAYWET
        INTEGER,   POINTER, DIMENSION(:)     ::LAYSTRT
        INTEGER,   POINTER, DIMENSION(:,:)   ::LAYFLG
        double precision,      POINTER, DIMENSION(:,:,:) ::VKA
        double precision,      POINTER, DIMENSION(:,:,:) ::VKCB
        double precision,      POINTER, DIMENSION(:,:,:) ::SC1
        double precision,      POINTER, DIMENSION(:,:,:) ::SC2
        double precision,      POINTER, DIMENSION(:,:,:) ::HANI
        double precision,      POINTER, DIMENSION(:,:,:) ::WETDRY
        double precision,      POINTER, DIMENSION(:,:,:) ::HK
      END TYPE
      TYPE(GWFLPFTYPE) GWFLPFDAT(10)
      
      contains
      
      SUBROUTINE GWF2LPF7DA(IGRID)
C  Deallocate LPF DATA
      !USE GWFLPFMODULE
C
        DEALLOCATE(GWFLPFDAT(IGRID)%ILPFCB)
        DEALLOCATE(GWFLPFDAT(IGRID)%IWDFLG)
        DEALLOCATE(GWFLPFDAT(IGRID)%IWETIT)
        DEALLOCATE(GWFLPFDAT(IGRID)%IHDWET)
        DEALLOCATE(GWFLPFDAT(IGRID)%ISFAC)
        DEALLOCATE(GWFLPFDAT(IGRID)%ICONCV)
        DEALLOCATE(GWFLPFDAT(IGRID)%ITHFLG)
        DEALLOCATE(GWFLPFDAT(IGRID)%NOCVCO)
        DEALLOCATE(GWFLPFDAT(IGRID)%NOVFC)
        DEALLOCATE(GWFLPFDAT(IGRID)%WETFCT)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYTYP)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYAVG)
        DEALLOCATE(GWFLPFDAT(IGRID)%CHANI)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYVKA)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYWET)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYSTRT)
        DEALLOCATE(GWFLPFDAT(IGRID)%LAYFLG)
        DEALLOCATE(GWFLPFDAT(IGRID)%VKA)
        DEALLOCATE(GWFLPFDAT(IGRID)%VKCB)
        DEALLOCATE(GWFLPFDAT(IGRID)%SC1)
        DEALLOCATE(GWFLPFDAT(IGRID)%SC2)
        DEALLOCATE(GWFLPFDAT(IGRID)%HANI)
        DEALLOCATE(GWFLPFDAT(IGRID)%WETDRY)
        DEALLOCATE(GWFLPFDAT(IGRID)%HK)
C
      RETURN
      END SUBROUTINE GWF2LPF7DA

!***********************************************************************

      SUBROUTINE SGWF2LPF7PNT(IGRID)
C  Point to LPF data for a grid.
      !USE GWFLPFMODULE
C
        ILPFCB=>GWFLPFDAT(IGRID)%ILPFCB
        IWDFLG=>GWFLPFDAT(IGRID)%IWDFLG
        IWETIT=>GWFLPFDAT(IGRID)%IWETIT
        IHDWET=>GWFLPFDAT(IGRID)%IHDWET
        ISFAC=>GWFLPFDAT(IGRID)%ISFAC
        ICONCV=>GWFLPFDAT(IGRID)%ICONCV
        ITHFLG=>GWFLPFDAT(IGRID)%ITHFLG
        NOCVCO=>GWFLPFDAT(IGRID)%NOCVCO
        NOVFC=>GWFLPFDAT(IGRID)%NOVFC
        WETFCT=>GWFLPFDAT(IGRID)%WETFCT
        LAYTYP=>GWFLPFDAT(IGRID)%LAYTYP
        LAYAVG=>GWFLPFDAT(IGRID)%LAYAVG
        CHANI=>GWFLPFDAT(IGRID)%CHANI
        LAYVKA=>GWFLPFDAT(IGRID)%LAYVKA
        LAYWET=>GWFLPFDAT(IGRID)%LAYWET
        LAYSTRT=>GWFLPFDAT(IGRID)%LAYSTRT
        LAYFLG=>GWFLPFDAT(IGRID)%LAYFLG
        VKA=>GWFLPFDAT(IGRID)%VKA
        VKCB=>GWFLPFDAT(IGRID)%VKCB
        SC1=>GWFLPFDAT(IGRID)%SC1
        SC2=>GWFLPFDAT(IGRID)%SC2
        HANI=>GWFLPFDAT(IGRID)%HANI
        WETDRY=>GWFLPFDAT(IGRID)%WETDRY
        HK=>GWFLPFDAT(IGRID)%HK
C
      RETURN
      END SUBROUTINE SGWF2LPF7PNT

!***********************************************************************

      SUBROUTINE GWF2LPF7PSV(IGRID)
C  Save LPF data for a grid.
      !USE GWFLPFMODULE
C
        GWFLPFDAT(IGRID)%ILPFCB=>ILPFCB
        GWFLPFDAT(IGRID)%IWDFLG=>IWDFLG
        GWFLPFDAT(IGRID)%IWETIT=>IWETIT
        GWFLPFDAT(IGRID)%IHDWET=>IHDWET
        GWFLPFDAT(IGRID)%ISFAC=>ISFAC
        GWFLPFDAT(IGRID)%ICONCV=>ICONCV
        GWFLPFDAT(IGRID)%ITHFLG=>ITHFLG
        GWFLPFDAT(IGRID)%NOCVCO=>NOCVCO
        GWFLPFDAT(IGRID)%NOVFC=>NOVFC
        GWFLPFDAT(IGRID)%WETFCT=>WETFCT
        GWFLPFDAT(IGRID)%LAYTYP=>LAYTYP
        GWFLPFDAT(IGRID)%LAYAVG=>LAYAVG
        GWFLPFDAT(IGRID)%CHANI=>CHANI
        GWFLPFDAT(IGRID)%LAYVKA=>LAYVKA
        GWFLPFDAT(IGRID)%LAYWET=>LAYWET
        GWFLPFDAT(IGRID)%LAYSTRT=>LAYSTRT
        GWFLPFDAT(IGRID)%LAYFLG=>LAYFLG
        GWFLPFDAT(IGRID)%VKA=>VKA
        GWFLPFDAT(IGRID)%VKCB=>VKCB
        GWFLPFDAT(IGRID)%SC1=>SC1
        GWFLPFDAT(IGRID)%SC2=>SC2
        GWFLPFDAT(IGRID)%HANI=>HANI
        GWFLPFDAT(IGRID)%WETDRY=>WETDRY
        GWFLPFDAT(IGRID)%HK=>HK
C
      RETURN
      END SUBROUTINE GWF2LPF7PSV
      
      END MODULE GWFLPFMODULE

