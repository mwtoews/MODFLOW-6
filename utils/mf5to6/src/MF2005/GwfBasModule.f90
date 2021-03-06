MODULE GWFBASMODULE
  
  use GLOBAL, only: GLOBALDAT
  use PARAMMODULE, only: PARAMDAT
  
  ! scalars
  INTEGER, SAVE, POINTER  ::MSUM
  INTEGER, SAVE, POINTER  ::IHEDFM,IHEDUN,IDDNFM,IDDNUN,IBOUUN
  INTEGER, SAVE, POINTER  ::LBHDSV,LBDDSV,LBBOSV
  INTEGER, SAVE, POINTER  ::IBUDFL,ICBCFL,IHDDFL,IAUXSV,IBDOPT
  INTEGER, SAVE, POINTER  ::IPRTIM,IPEROC,ITSOC,ICHFLG
  INTEGER, SAVE, POINTER  ::IDDREF,IDDREFNEW
  double precision,  SAVE, POINTER  ::DELT,PERTIM,TOTIM,HNOFLO,HDRY,STOPER
  CHARACTER(LEN=20), SAVE, POINTER   ::CHEDFM,CDDNFM,CBOUFM
  ! arrays
  INTEGER,           SAVE, DIMENSION(:,:), POINTER ::IOFLG
  double precision,  SAVE, DIMENSION(:,:), POINTER ::VBVL
  CHARACTER(LEN=16), SAVE, DIMENSION(:),   POINTER ::VBNM
  
  TYPE GWFBASTYPE
    ! scalars
    INTEGER, POINTER  ::MSUM
    INTEGER, POINTER  ::IHEDFM,IHEDUN,IDDNFM,IDDNUN,IBOUUN
    INTEGER, POINTER  ::LBHDSV,LBDDSV,LBBOSV
    INTEGER, POINTER  ::IBUDFL,ICBCFL,IHDDFL,IAUXSV,IBDOPT
    INTEGER, POINTER  ::IPRTIM,IPEROC,ITSOC,ICHFLG
    INTEGER, POINTER  ::IDDREF,IDDREFNEW
    double precision,  POINTER  ::DELT,PERTIM,TOTIM,HNOFLO,HDRY,STOPER
    CHARACTER(LEN=20), POINTER   ::CHEDFM,CDDNFM,CBOUFM
    ! arrays
    INTEGER,           DIMENSION(:,:), POINTER ::IOFLG
    double precision,  DIMENSION(:,:), POINTER ::VBVL
    CHARACTER(LEN=16), DIMENSION(:),   POINTER ::VBNM
  END TYPE
  
  TYPE(GWFBASTYPE), SAVE  ::GWFBASDAT(10)
  
contains

  subroutine AllocateGwfBasScalars()
    implicit none
    !
    if (.not. associated(msum)) then
      allocate(MSUM)
      allocate(IHEDFM,IHEDUN,IDDNFM,IDDNUN,IBOUUN)
      allocate(LBHDSV,LBDDSV,LBBOSV)
      allocate(IBUDFL,ICBCFL,IHDDFL,IAUXSV,IBDOPT)
      allocate(IPRTIM,IPEROC,ITSOC,ICHFLG)
      allocate(IDDREF,IDDREFNEW)
      allocate(DELT,PERTIM,TOTIM,HNOFLO,HDRY,STOPER)
      allocate(CHEDFM,CDDNFM,CBOUFM)
    endif
    !
    return
  end subroutine AllocateGwfBasScalars
  

  SUBROUTINE GWF2BAS7DA(IGRID)
!C     DEALLOCATE GLOBAL DATA
    USE GLOBAL
    USE PARAMMODULE
!C
    DEALLOCATE(GLOBALDAT(IGRID)%NCOL)
    DEALLOCATE(GLOBALDAT(IGRID)%NROW)
    DEALLOCATE(GLOBALDAT(IGRID)%NLAY)
    DEALLOCATE(GLOBALDAT(IGRID)%NPER)
    DEALLOCATE(GLOBALDAT(IGRID)%NBOTM)
    DEALLOCATE(GLOBALDAT(IGRID)%NCNFBD)
    DEALLOCATE(GLOBALDAT(IGRID)%ITMUNI)
    DEALLOCATE(GLOBALDAT(IGRID)%LENUNI)
    DEALLOCATE(GLOBALDAT(IGRID)%IXSEC)
    DEALLOCATE(GLOBALDAT(IGRID)%ITRSS)
    DEALLOCATE(GLOBALDAT(IGRID)%INBAS)
    DEALLOCATE(GLOBALDAT(IGRID)%IFREFM)
    DEALLOCATE(GLOBALDAT(IGRID)%NODES)
    DEALLOCATE(GLOBALDAT(IGRID)%IOUT)
    DEALLOCATE(GLOBALDAT(IGRID)%MXITER)
!C
    DEALLOCATE(GLOBALDAT(IGRID)%IUNIT)
    DEALLOCATE(GLOBALDAT(IGRID)%LAYCBD)
    DEALLOCATE(GLOBALDAT(IGRID)%LAYHDT)
    DEALLOCATE(GLOBALDAT(IGRID)%LAYHDS)
    DEALLOCATE(GLOBALDAT(IGRID)%PERLEN)
    DEALLOCATE(GLOBALDAT(IGRID)%NSTP)
    DEALLOCATE(GLOBALDAT(IGRID)%TSMULT)
    DEALLOCATE(GLOBALDAT(IGRID)%ISSFLG)
    DEALLOCATE(GLOBALDAT(IGRID)%DELR)
    DEALLOCATE(GLOBALDAT(IGRID)%DELC)
    DEALLOCATE(GLOBALDAT(IGRID)%BOTM)
    DEALLOCATE(GLOBALDAT(IGRID)%LBOTM)
    DEALLOCATE(GLOBALDAT(IGRID)%HNEW)
    DEALLOCATE(GLOBALDAT(IGRID)%HOLD)
    DEALLOCATE(GLOBALDAT(IGRID)%IBOUND)
    DEALLOCATE(GLOBALDAT(IGRID)%CR)
    DEALLOCATE(GLOBALDAT(IGRID)%CC)
    DEALLOCATE(GLOBALDAT(IGRID)%CV)
    DEALLOCATE(GLOBALDAT(IGRID)%HCOF)
    DEALLOCATE(GLOBALDAT(IGRID)%RHS)
    DEALLOCATE(GLOBALDAT(IGRID)%BUFF)
    DEALLOCATE(GLOBALDAT(IGRID)%STRT)
    deallocate(globaldat(igrid)%constantdelr)
    deallocate(globaldat(igrid)%constantdelc)
    deallocate(globaldat(igrid)%cbcfilename)
    IF(.NOT.ASSOCIATED(DDREF,STRT)) DEALLOCATE(GLOBALDAT(IGRID)%DDREF)
!C
    DEALLOCATE(ICLSUM,IPSUM,INAMLOC,NMLTAR,NZONAR,NPVAL)
    DEALLOCATE (PARAMDAT(IGRID)%B)
    DEALLOCATE (PARAMDAT(IGRID)%IACTIVE)
    DEALLOCATE (PARAMDAT(IGRID)%IPLOC)
    DEALLOCATE (PARAMDAT(IGRID)%IPCLST)
    DEALLOCATE (PARAMDAT(IGRID)%PARNAM)
    DEALLOCATE (PARAMDAT(IGRID)%PARTYP)
    DEALLOCATE (PARAMDAT(IGRID)%ZONNAM)
    DEALLOCATE (PARAMDAT(IGRID)%MLTNAM)
    DEALLOCATE (PARAMDAT(IGRID)%INAME)
    DEALLOCATE (PARAMDAT(IGRID)%RMLT)
    DEALLOCATE (PARAMDAT(IGRID)%IZON)
!C
    DEALLOCATE(GWFBASDAT(IGRID)%MSUM)
    DEALLOCATE(GWFBASDAT(IGRID)%IHEDFM)
    DEALLOCATE(GWFBASDAT(IGRID)%IHEDUN)
    DEALLOCATE(GWFBASDAT(IGRID)%IDDNFM)
    DEALLOCATE(GWFBASDAT(IGRID)%IDDNUN)
    DEALLOCATE(GWFBASDAT(IGRID)%IBOUUN)
    DEALLOCATE(GWFBASDAT(IGRID)%LBHDSV)
    DEALLOCATE(GWFBASDAT(IGRID)%LBDDSV)
    DEALLOCATE(GWFBASDAT(IGRID)%LBBOSV)
    DEALLOCATE(GWFBASDAT(IGRID)%IBUDFL)
    DEALLOCATE(GWFBASDAT(IGRID)%ICBCFL)
    DEALLOCATE(GWFBASDAT(IGRID)%IHDDFL)
    DEALLOCATE(GWFBASDAT(IGRID)%IAUXSV)
    DEALLOCATE(GWFBASDAT(IGRID)%IBDOPT)
    DEALLOCATE(GWFBASDAT(IGRID)%IPRTIM)
    DEALLOCATE(GWFBASDAT(IGRID)%IPEROC)
    DEALLOCATE(GWFBASDAT(IGRID)%ITSOC)
    DEALLOCATE(GWFBASDAT(IGRID)%ICHFLG)
    DEALLOCATE(GWFBASDAT(IGRID)%IDDREF)
    DEALLOCATE(GWFBASDAT(IGRID)%IDDREFNEW)
    DEALLOCATE(GWFBASDAT(IGRID)%DELT)
    DEALLOCATE(GWFBASDAT(IGRID)%PERTIM)
    DEALLOCATE(GWFBASDAT(IGRID)%TOTIM)
    DEALLOCATE(GWFBASDAT(IGRID)%HNOFLO)
    DEALLOCATE(GWFBASDAT(IGRID)%HDRY)
    DEALLOCATE(GWFBASDAT(IGRID)%STOPER)
    DEALLOCATE(GWFBASDAT(IGRID)%CHEDFM)
    DEALLOCATE(GWFBASDAT(IGRID)%CDDNFM)
    DEALLOCATE(GWFBASDAT(IGRID)%CBOUFM)
!C
    DEALLOCATE(GWFBASDAT(IGRID)%IOFLG)
    DEALLOCATE(GWFBASDAT(IGRID)%VBVL)
    DEALLOCATE(GWFBASDAT(IGRID)%VBNM)
!C
    RETURN
  END SUBROUTINE GWF2BAS7DA

  SUBROUTINE SGWF2BAS7PSV(IGRID)
!C  Save global data for a grid.
    USE GLOBAL
    USE PARAMMODULE
!C
    GLOBALDAT(IGRID)%NCOL=>NCOL
    GLOBALDAT(IGRID)%NROW=>NROW
    GLOBALDAT(IGRID)%NLAY=>NLAY
    GLOBALDAT(IGRID)%NPER=>NPER
    GLOBALDAT(IGRID)%NBOTM=>NBOTM
    GLOBALDAT(IGRID)%NCNFBD=>NCNFBD
    GLOBALDAT(IGRID)%ITMUNI=>ITMUNI
    GLOBALDAT(IGRID)%LENUNI=>LENUNI
    GLOBALDAT(IGRID)%IXSEC=>IXSEC
    GLOBALDAT(IGRID)%ITRSS=>ITRSS
    GLOBALDAT(IGRID)%INBAS=>INBAS
    GLOBALDAT(IGRID)%IFREFM=>IFREFM
    GLOBALDAT(IGRID)%NODES=>NODES
    GLOBALDAT(IGRID)%IOUT=>IOUT
    GLOBALDAT(IGRID)%MXITER=>MXITER
!C
    GLOBALDAT(IGRID)%IUNIT=>IUNIT
    GLOBALDAT(IGRID)%LAYCBD=>LAYCBD
    GLOBALDAT(IGRID)%LAYHDT=>LAYHDT
    GLOBALDAT(IGRID)%LAYHDS=>LAYHDS
    GLOBALDAT(IGRID)%PERLEN=>PERLEN
    GLOBALDAT(IGRID)%NSTP=>NSTP
    GLOBALDAT(IGRID)%TSMULT=>TSMULT
    GLOBALDAT(IGRID)%ISSFLG=>ISSFLG
    GLOBALDAT(IGRID)%DELR=>DELR
    GLOBALDAT(IGRID)%DELC=>DELC
    GLOBALDAT(IGRID)%BOTM=>BOTM
    GLOBALDAT(IGRID)%LBOTM=>LBOTM
    GLOBALDAT(IGRID)%HNEW=>HNEW
    GLOBALDAT(IGRID)%HOLD=>HOLD
    GLOBALDAT(IGRID)%IBOUND=>IBOUND
    GLOBALDAT(IGRID)%CR=>CR
    GLOBALDAT(IGRID)%CC=>CC
    GLOBALDAT(IGRID)%CV=>CV
    GLOBALDAT(IGRID)%HCOF=>HCOF
    GLOBALDAT(IGRID)%RHS=>RHS
    GLOBALDAT(IGRID)%BUFF=>BUFF
    GLOBALDAT(IGRID)%STRT=>STRT
    GLOBALDAT(IGRID)%DDREF=>DDREF
    globaldat(igrid)%constantdelr => constantdelr
    globaldat(igrid)%constantdelc => constantdelc
    globaldat(igrid)%cbcfilename => cbcfilename
!C
    PARAMDAT(IGRID)%ICLSUM=>ICLSUM
    PARAMDAT(IGRID)%IPSUM=>IPSUM
    PARAMDAT(IGRID)%INAMLOC=>INAMLOC
    PARAMDAT(IGRID)%NMLTAR=>NMLTAR
    PARAMDAT(IGRID)%NZONAR=>NZONAR
    PARAMDAT(IGRID)%NPVAL=>NPVAL
!C
    PARAMDAT(IGRID)%B=>B
    PARAMDAT(IGRID)%IACTIVE=>IACTIVE
    PARAMDAT(IGRID)%IPLOC=>IPLOC
    PARAMDAT(IGRID)%IPCLST=>IPCLST
    PARAMDAT(IGRID)%IZON=>IZON
    PARAMDAT(IGRID)%RMLT=>RMLT
    PARAMDAT(IGRID)%PARNAM=>PARNAM
    PARAMDAT(IGRID)%PARTYP=>PARTYP
    PARAMDAT(IGRID)%ZONNAM=>ZONNAM
    PARAMDAT(IGRID)%MLTNAM=>MLTNAM
    PARAMDAT(IGRID)%INAME=>INAME
!C
    GWFBASDAT(IGRID)%MSUM=>MSUM
    GWFBASDAT(IGRID)%IHEDFM=>IHEDFM
    GWFBASDAT(IGRID)%IHEDUN=>IHEDUN
    GWFBASDAT(IGRID)%IDDNFM=>IDDNFM
    GWFBASDAT(IGRID)%IDDNUN=>IDDNUN
    GWFBASDAT(IGRID)%IBOUUN=>IBOUUN
    GWFBASDAT(IGRID)%LBHDSV=>LBHDSV
    GWFBASDAT(IGRID)%LBDDSV=>LBDDSV
    GWFBASDAT(IGRID)%LBBOSV=>LBBOSV
    GWFBASDAT(IGRID)%IBUDFL=>IBUDFL
    GWFBASDAT(IGRID)%ICBCFL=>ICBCFL
    GWFBASDAT(IGRID)%IHDDFL=>IHDDFL
    GWFBASDAT(IGRID)%IAUXSV=>IAUXSV
    GWFBASDAT(IGRID)%IBDOPT=>IBDOPT
    GWFBASDAT(IGRID)%IPRTIM=>IPRTIM
    GWFBASDAT(IGRID)%IPEROC=>IPEROC
    GWFBASDAT(IGRID)%ITSOC=>ITSOC
    GWFBASDAT(IGRID)%ICHFLG=>ICHFLG
    GWFBASDAT(IGRID)%IDDREF=>IDDREF
    GWFBASDAT(IGRID)%IDDREFNEW=>IDDREFNEW
    GWFBASDAT(IGRID)%DELT=>DELT
    GWFBASDAT(IGRID)%PERTIM=>PERTIM
    GWFBASDAT(IGRID)%TOTIM=>TOTIM
    GWFBASDAT(IGRID)%HNOFLO=>HNOFLO
    GWFBASDAT(IGRID)%HDRY=>HDRY
    GWFBASDAT(IGRID)%STOPER=>STOPER
    GWFBASDAT(IGRID)%CHEDFM=>CHEDFM
    GWFBASDAT(IGRID)%CDDNFM=>CDDNFM
    GWFBASDAT(IGRID)%CBOUFM=>CBOUFM
!C
    GWFBASDAT(IGRID)%IOFLG=>IOFLG
    GWFBASDAT(IGRID)%VBVL=>VBVL
    GWFBASDAT(IGRID)%VBNM=>VBNM
!C
    RETURN
  END SUBROUTINE SGWF2BAS7PSV

  SUBROUTINE SGWF2BAS7PNT(IGRID)
!C  Change global data to a different grid.
    USE GLOBAL
    USE PARAMMODULE
!C
    NCOL=>GLOBALDAT(IGRID)%NCOL
    NROW=>GLOBALDAT(IGRID)%NROW
    NLAY=>GLOBALDAT(IGRID)%NLAY
    NPER=>GLOBALDAT(IGRID)%NPER
    NBOTM=>GLOBALDAT(IGRID)%NBOTM
    NCNFBD=>GLOBALDAT(IGRID)%NCNFBD
    ITMUNI=>GLOBALDAT(IGRID)%ITMUNI
    LENUNI=>GLOBALDAT(IGRID)%LENUNI
    IXSEC=>GLOBALDAT(IGRID)%IXSEC
    ITRSS=>GLOBALDAT(IGRID)%ITRSS
    INBAS=>GLOBALDAT(IGRID)%INBAS
    IFREFM=>GLOBALDAT(IGRID)%IFREFM
    NODES=>GLOBALDAT(IGRID)%NODES
    IOUT=>GLOBALDAT(IGRID)%IOUT
    MXITER=>GLOBALDAT(IGRID)%MXITER
!C
    IUNIT=>GLOBALDAT(IGRID)%IUNIT
    LAYCBD=>GLOBALDAT(IGRID)%LAYCBD
    LAYHDT=>GLOBALDAT(IGRID)%LAYHDT
    LAYHDS=>GLOBALDAT(IGRID)%LAYHDS
    PERLEN=>GLOBALDAT(IGRID)%PERLEN
    NSTP=>GLOBALDAT(IGRID)%NSTP
    TSMULT=>GLOBALDAT(IGRID)%TSMULT
    ISSFLG=>GLOBALDAT(IGRID)%ISSFLG
    DELR=>GLOBALDAT(IGRID)%DELR
    DELC=>GLOBALDAT(IGRID)%DELC
    BOTM=>GLOBALDAT(IGRID)%BOTM
    LBOTM=>GLOBALDAT(IGRID)%LBOTM
    HNEW=>GLOBALDAT(IGRID)%HNEW
    HOLD=>GLOBALDAT(IGRID)%HOLD
    IBOUND=>GLOBALDAT(IGRID)%IBOUND
    CR=>GLOBALDAT(IGRID)%CR
    CC=>GLOBALDAT(IGRID)%CC
    CV=>GLOBALDAT(IGRID)%CV
    HCOF=>GLOBALDAT(IGRID)%HCOF
    RHS=>GLOBALDAT(IGRID)%RHS
    BUFF=>GLOBALDAT(IGRID)%BUFF
    STRT=>GLOBALDAT(IGRID)%STRT
    DDREF=>GLOBALDAT(IGRID)%DDREF
    constantdelr => globaldat(igrid)%constantdelr
    constantdelc => globaldat(igrid)%constantdelc
    cbcfilename => globaldat(igrid)%cbcfilename
!C
    ICLSUM=>PARAMDAT(IGRID)%ICLSUM
    IPSUM=>PARAMDAT(IGRID)%IPSUM
    INAMLOC=>PARAMDAT(IGRID)%INAMLOC
    NMLTAR=>PARAMDAT(IGRID)%NMLTAR
    NZONAR=>PARAMDAT(IGRID)%NZONAR
    NPVAL=>PARAMDAT(IGRID)%NPVAL
!C
    B=>PARAMDAT(IGRID)%B
    IACTIVE=>PARAMDAT(IGRID)%IACTIVE
    IPLOC=>PARAMDAT(IGRID)%IPLOC
    IPCLST=>PARAMDAT(IGRID)%IPCLST
    IZON=>PARAMDAT(IGRID)%IZON
    RMLT=>PARAMDAT(IGRID)%RMLT
    PARNAM=>PARAMDAT(IGRID)%PARNAM
    PARTYP=>PARAMDAT(IGRID)%PARTYP
    ZONNAM=>PARAMDAT(IGRID)%ZONNAM
    MLTNAM=>PARAMDAT(IGRID)%MLTNAM
    INAME=>PARAMDAT(IGRID)%INAME
!C
    MSUM=>GWFBASDAT(IGRID)%MSUM
    IHEDFM=>GWFBASDAT(IGRID)%IHEDFM
    IHEDUN=>GWFBASDAT(IGRID)%IHEDUN
    IDDNFM=>GWFBASDAT(IGRID)%IDDNFM
    IDDNUN=>GWFBASDAT(IGRID)%IDDNUN
    IBOUUN=>GWFBASDAT(IGRID)%IBOUUN
    LBHDSV=>GWFBASDAT(IGRID)%LBHDSV
    LBDDSV=>GWFBASDAT(IGRID)%LBDDSV
    LBBOSV=>GWFBASDAT(IGRID)%LBBOSV
    IBUDFL=>GWFBASDAT(IGRID)%IBUDFL
    ICBCFL=>GWFBASDAT(IGRID)%ICBCFL
    IHDDFL=>GWFBASDAT(IGRID)%IHDDFL
    IAUXSV=>GWFBASDAT(IGRID)%IAUXSV
    IBDOPT=>GWFBASDAT(IGRID)%IBDOPT
    IPRTIM=>GWFBASDAT(IGRID)%IPRTIM
    IPEROC=>GWFBASDAT(IGRID)%IPEROC
    ITSOC=>GWFBASDAT(IGRID)%ITSOC
    ICHFLG=>GWFBASDAT(IGRID)%ICHFLG
    IDDREF=>GWFBASDAT(IGRID)%IDDREF
    IDDREFNEW=>GWFBASDAT(IGRID)%IDDREFNEW
    DELT=>GWFBASDAT(IGRID)%DELT
    PERTIM=>GWFBASDAT(IGRID)%PERTIM
    TOTIM=>GWFBASDAT(IGRID)%TOTIM
    HNOFLO=>GWFBASDAT(IGRID)%HNOFLO
    HDRY=>GWFBASDAT(IGRID)%HDRY
    STOPER=>GWFBASDAT(IGRID)%STOPER
    CHEDFM=>GWFBASDAT(IGRID)%CHEDFM
    CDDNFM=>GWFBASDAT(IGRID)%CDDNFM
    CBOUFM=>GWFBASDAT(IGRID)%CBOUFM
!C
    IOFLG=>GWFBASDAT(IGRID)%IOFLG
    VBVL=>GWFBASDAT(IGRID)%VBVL
    VBNM=>GWFBASDAT(IGRID)%VBNM
!C
    RETURN
  END SUBROUTINE SGWF2BAS7PNT
  
  function FindHighestActiveLayer(irow,jcol) result (klay)
    use GLOBAL, only: NROW, NCOL, NLAY, IBOUND
    implicit none
    ! dummy
    integer, intent(in) :: irow, jcol
    integer :: klay
    ! local 
    integer :: k
    !
    klay = 0
    do k=1,NLAY
      if (IBOUND(jcol, irow, k) > 0) then
        klay = k
        exit
      endif
    enddo
    !
    return
  end function FindHighestActiveLayer
  
END MODULE GWFBASMODULE
