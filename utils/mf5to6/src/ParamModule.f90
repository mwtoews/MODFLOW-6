MODULE PARAMMODULE
!C  Data definitions for Named Parameters
!C  Explicitly declare all variables to enable subroutines that include
!C  this file to use the IMPLICIT NONE statement.
  PARAMETER (MXPAR=2000,MXCLST=20000,MXINST=50000)
  INTEGER,SAVE,POINTER ::ICLSUM,IPSUM,INAMLOC,NMLTAR,NZONAR,NPVAL
  double precision, SAVE, DIMENSION(:),    POINTER ::B
  INTEGER,       SAVE,    DIMENSION(:),    POINTER ::IACTIVE
  INTEGER,       SAVE,    DIMENSION(:,:),  POINTER ::IPLOC
  INTEGER,       SAVE,    DIMENSION(:,:),  POINTER ::IPCLST
  INTEGER,       SAVE,    DIMENSION(:,:,:),POINTER ::IZON
  double precision, SAVE, DIMENSION(:,:,:),POINTER ::RMLT
  CHARACTER(LEN=10),SAVE, DIMENSION(:),    POINTER ::PARNAM
  CHARACTER(LEN=4), SAVE, DIMENSION(:),    POINTER ::PARTYP
  CHARACTER(LEN=10),SAVE, DIMENSION(:),    POINTER ::ZONNAM
  CHARACTER(LEN=10),SAVE, DIMENSION(:),    POINTER ::MLTNAM
  CHARACTER(LEN=10),SAVE, DIMENSION(:),    POINTER ::INAME
  
  TYPE PARAMTYPE
    ! scalars
    INTEGER,POINTER  ::ICLSUM,IPSUM,INAMLOC,NMLTAR,NZONAR,NPVAL
    ! arrays
    double precision,  DIMENSION(:),    POINTER ::B
    INTEGER,           DIMENSION(:),    POINTER ::IACTIVE
    INTEGER,           DIMENSION(:,:),  POINTER ::IPLOC
    INTEGER,           DIMENSION(:,:),  POINTER ::IPCLST
    INTEGER,           DIMENSION(:,:,:),POINTER ::IZON
    double precision,  DIMENSION(:,:,:),POINTER ::RMLT
    CHARACTER(LEN=10), DIMENSION(:),    POINTER ::PARNAM
    CHARACTER(LEN=4),  DIMENSION(:),    POINTER ::PARTYP
    CHARACTER(LEN=10), DIMENSION(:),    POINTER ::ZONNAM
    CHARACTER(LEN=10), DIMENSION(:),    POINTER ::MLTNAM
    CHARACTER(LEN=10), DIMENSION(:),    POINTER ::INAME
  END TYPE PARAMTYPE

  TYPE(PARAMTYPE), SAVE  ::PARAMDAT(10)

contains

  subroutine AllocateParamScalars()
    implicit none
    !
    if (.not. associated(ICLSUM)) then
      allocate(ICLSUM,IPSUM,INAMLOC,NMLTAR,NZONAR,NPVAL)
    endif
    !
    return
  end subroutine AllocateParamScalars

END MODULE PARAMMODULE

