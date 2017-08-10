module ObsWriterModule

  use ConstantsModule,    only: LENOBSNAME, LENOBSTYPE, &
                                LINELENGTH, DZERO, MAXCHARLEN, &
                                DHALF
  use ConstantsPHMFModule, only: FCINPUT, LENOBSNAMENEW
  use ConverterCommonModule, only: SupportPreproc
  use DnmDis3dModule,     only: Dis3dType
  use DnmDisBaseModule,   only: DisBaseType
  use FileListModule,     only: FileListType
  use FileTypeModule,     only: FileType
  use FileWriterModule,   only: FileWriterType
  use GLOBAL,             only: IUNIT, NLAY, NROW, NCOL, IOUT, DELC, DELR
  use InputOutputModule,  only: openfile, GetUnit
  use ListModule,         only: ListType
  use MultiLayerObs,      only: LayerObsType, MLObsType, ConstructLayerObs, &
                                ConstructMLObs, AddLayerObsToList, &
                                AddMLObsToList, GetLayerObsFromList, &
                                GetMLObsFromList
  use OBSBASMODULE,       only: ITS, nhed=>NH, MAXM, MOBS, IUHOBSV, IDRY, &
                                JDRY, IPRT, HOBDRY, NDER, MLAY, IOFF, &
                                JOFF, IHOBWET, TOFF, ROFF, COFF, &
                                otimehd=>OTIME, hobsname=>OBSNAM, &
                                irefspd, nlayer, PR
  use OBSCHDMODULE,       only: NQCH, NQCCH, NQTCH, NQOBCH, NQCLCH, &
                                otimech=>OTIME, qcellch=>QCELL
  use OBSDRNMODULE,       only: NQDR, NQCDR, NQTDR, NQOBDR, NQCLDR, &
                                otimedr=>OTIME, qcelldr=>QCELL, IUDROBSV
  use OBSGHBMODULE,       only: NQGB, NQCGB, NQTGB, NQOBGB, NQCLGB, &
                                otimegb=>OTIME, qcellgb=>QCELL, IUGBOBSV
  use OBSRIVMODULE,       only: NQRV, NQCRV, NQTRV, NQOBRV, NQCLRV, &
                                otimerv=>OTIME, qcellrv=>QCELL, IURVOBSV
  use PreprocModule,      only: PreprocType
  use SimModule,          only: store_error, store_note, store_warning, ustop
  use StressPeriodModule, only: StressPeriodType
  use UtilitiesModule,    only: get_extension
  use utl7module,         only: assign_ncharsizes_flow, build_obsname

  implicit none

  type, extends(FileWriterType) :: ObsWriterType
    character(len=6) :: Precis = 'double'
    integer          :: NumDigits = 7
    integer          :: IuObs = 0
    integer          :: IuMlPostObs = 0
    ! Model-level variables
    character(len=LINELENGTH) :: basename = ''
    type(FileListType), pointer :: Mf6Files => null()
    ! For PreHeadsMF capability
    double precision :: hdry
    character(len=MAXCHARLEN) :: DisFileName = ''
    ! PreHeadsMfFile is a PreHeadsMF input file to be generated by ObsWriter
    ! and can be run by invoking this%preproc%Run() or by running PreHeadsMF.
    character(len=MAXCHARLEN) :: PreHeadsMfFile = ''
    ! PhmfObsFileName goes into PreHeadsMF input as MFOBSFILE and is
    ! an EXTERNAL file referenced in the main head obs input file.
    character(len=MAXCHARLEN) :: PhmfObsFileName = ''
    ! PomfFileName goes into PreHeadsMF input as POSTOBSFILE; it
    ! can be used by PostObsMF after MF6 is run.
    character(len=MAXCHARLEN) :: PomfFileName = ''
    ! ObsOutputBasename goes into PreHeadsMF input as obs_output_base_name;
    ! it is used as the basis for names of various .csv and .bsv files.
    character(len=MAXCHARLEN) :: ObsOutputBasename = ''
    character(len=MAXCHARLEN) :: MlPostObsFileName = ''
    character(len=MAXCHARLEN) :: MfOutputCsvFileName = ''
    character(len=6) :: Source = ' '
    type(PreprocType) :: Preproc
    type(StressPeriodType), dimension(:), pointer :: StressPeriods => null()
    type(ListType) :: MLObsList
    double precision, dimension(:), pointer :: delc => null()
    double precision, dimension(:), pointer :: delr => null()
  contains
    ! Public procedures
    procedure, public :: InitializeObs
    procedure, public :: SetDisFileName
    procedure, public :: SetHdry
    procedure, public :: SetStressPeriods
    procedure, public :: WriteContinuous
    procedure, public :: WriteObsFile
    procedure, public :: write_ml_postobs_file
    ! Private procedures
    procedure, private :: calc_grid_coords
    procedure, private :: WriteObsOptions
    procedure, private :: write_preheadsmf_file
    procedure, private :: write_preheadsmf_options
    procedure, private :: write_ml_postobs_input_files
    procedure, private :: write_ml_postobs_options
    procedure, private :: write_ml_postobs_input
  end type ObsWriterType

contains

  subroutine InitializeObs(this, basename, modifier)
    implicit none
    ! dummy
    class(ObsWriterType), intent(inout) :: this
    character(len=*), intent(in) :: basename
    character(len=*), optional, intent(in) :: modifier
    ! local
    character(len=4) :: ftype
    character(len=LINELENGTH) :: fname
    !
    this%basename = basename
    this%PkgType = ''
    ftype = 'OBS6'
    fname = trim(basename)
    if (present(modifier)) then
      fname = trim(fname) // '.' // trim(modifier)
    endif
    fname = trim(fname) // '.obs'
    ! Invoke superclass initializer
    call this%FileWriterType%InitializeFile(fname, ftype)
    this%FileWriterType%fileobj%FCode = FCINPUT
    this%IuObs = this%FileWriterType%fileobj%IUnit
    !
    return
  end subroutine InitializeObs

  subroutine SetDisFileName(this, disfilename)
    ! dummy
    class(ObsWriterType) :: this
    character(len=*), intent(in) :: disfilename
    !
    this%DisFilename = disfilename
    !
    return
  end subroutine SetDisFileName

  subroutine SetHdry(this, hdry)
    ! dummy
    class(ObsWriterType) :: this
    double precision, intent(in) :: hdry
    !
    this%hdry  = hdry
    !
    return
  end subroutine SetHdry

  subroutine SetStressPeriods(this, StressPeriods)
    class(ObsWriterType) :: this
    type(StressPeriodType), dimension(:), pointer, intent(inout) :: StressPeriods
    !
    this%StressPeriods => StressPeriods
    !
    return
  end subroutine SetStressPeriods

  subroutine WriteObsFile(this, igrid)
    implicit none
    ! dummy
    class(ObsWriterType) :: this
    integer, intent(in)  :: igrid
    ! local
    integer :: iunew, iuob, iuobs
    logical :: needPreproc
    ! formats
    1 format()
    10 format(a,2x,a)
    20 format(2x,a,2x,a)
    !
    this%delc => DELC
    this%delr => DELR
    !
    select type(this)
    type is (ObsWriterType)
      ! Read the HOB input file here to know if Preproc (PreHeadsMF) needs to be activated.
      iuob = iunit(28)  ! HOB input unit
! probably incorrect      this%IuObs = iuob
      call OBS2BAS7AR(iuob, igrid, needPreproc)
      if (SupportPreproc .and. needPreproc) then
        this%Preproc%Active = .true.
        !
        ! Find lower left corner of grid and assign YoriginLL
        call this%Preproc%find_lower_left()
        !
        ! Write a PreHeadsMF input file.
        ! Ned todo: (1) Uncomment following line (that invokes write_preheadsmf_file) after 2016 GW workshop;
        !           (2) Finish code that writes preheadsmf (.phmf) file
        !               --it doesn't handle multilayer obs correctly now;
        !           (3) Write code to create/modify mf6 obs input file to include head obs for adjacent cells.
        !           (4) Maybe write code to create a batch file to run preheadsmf, mf6, and postobsmf.
        call this%write_preheadsmf_file()
      endif
    end select
    !
    call this%WriteObsOptions()
    !
    ! Write a single block if needed for PreHeadsMF
    if (this%Preproc%Active) then
      iunew = this%fileobj%IUnit
      write(iunew,1)
      write(iunew,10)'# Head observations that require interpolation'
      write(iunew,10)'BEGIN SINGLE FILEOUT', trim(this%ObsOutputBasename) // '.csv'
      write(iunew,20)'OPEN/CLOSE',trim(this%PhmfObsFileName)
      write(iunew,10)'END SINGLE'
    endif

    !
    ! Write continuous blocks
    iuobs = this%IuObs
    if (iuobs > 0) then
      call this%WriteContinuous(igrid)
    endif
    !
    return
  end subroutine WriteObsFile

  subroutine write_preheadsmf_file(this)
    ! Write a PreHeadsMF input file for head obs with ROFF or COFF not equal to zero.
    ! dummy
    class(ObsWriterType) :: this
    ! local
    integer :: i, iuphmf, irow, jcol, layer, k
    integer :: nlayobs ! # layers for current observation
    integer :: kmobs   ! Counter for multilayer observations
    double precision :: obstime, rof, cof, xgrid, ygrid, weight
    character(len=LENOBSNAMENEW) :: obsnamebase, obsnametemp
    type(LayerObsType), pointer :: layobs => null()
    type(MLObsType), pointer :: mlobs => null()
    ! formats
    1 format()
    5 format(a)
    10 format(a,2x,a)
    ! For grid coordinates field, allow for 100,000,000 cm plus sign
    20 format(2x,a,2x,g18.11,2(2x,f12.1),2x,i0)
    30 format(a,'_L',i0)
    !
    this%PhmfObsFileName = trim(this%basename) // '.phmf.obs'
    this%PomfFileName = trim(this%basename) // '.pomf'
    this%PreHeadsMfFile = trim(this%basename) // '.phmf'
    this%ObsOutputBasename = trim(this%basename) // '.proc.heds'
    call openfile(iuphmf, iout, this%PreHeadsMfFile, 'PHMF', filstat_opt='REPLACE')
    !
    ! Write options block
    call this%write_preheadsmf_options(iuphmf)
    !
    ! Write a SINGLE block for all obs with ROFF or COFF not equal to zero.
    write(iuphmf,1)
    write(iuphmf,10)'BEGIN SINGLE ', trim(this%ObsOutputBasename)
    !
    kmobs = 0
    do i=1,nhed
      rof = roff(i)
      cof = coff(i)
      layer = NDER(1,i)
      if (layer < 0) kmobs = kmobs + 1
      if (rof == DZERO .and. cof == DZERO) then
        ! No need for interpolation
        cycle
      endif
      ! Get X and Y grid coordinates
      irow = NDER(2,i)
      jcol = NDER(3,i)
      call this%calc_grid_coords(irow, jcol, rof, cof, xgrid, ygrid)
      obsnamebase = hobsname(i)
      obstime = otimehd(i)
      if (layer < 0) then
        nlayobs = -layer
        call ConstructMLObs(mlobs, obsnamebase)
        call AddMLObsToList(this%MLObsList, mlobs)
        do k=1,nlayobs
          layer = mlay(k,kmobs)
          weight = pr(k,kmobs)
          write(obsnametemp,30)trim(obsnamebase),layer
          write(iuphmf,20)trim(obsnametemp), obstime, xgrid, ygrid, layer
          call ConstructLayerObs(layobs, obsnametemp, layer, weight)
          call AddLayerObsToList(mlobs%LayerObsList,layobs)
        enddo
      else
        write(iuphmf,20)trim(obsnamebase), obstime, xgrid, ygrid, layer
      endif
    enddo
    !
    write(iuphmf,5)'END SINGLE'
    !
    ! Close the PreHeadsMF input file.
    close(iuphmf)
    !
    return
  end subroutine write_preheadsmf_file

  subroutine calc_grid_coords(this, irow, jcol, rof, cof, xgrid, ygrid)
    ! Calculate X and Y grid coordinates from row and column indices
    ! and roff and coff, relative to outside corner of cell at row 1,
    ! column 1.  This makes all Y values negative.
    ! dummy
    class(ObsWriterType) :: this
    integer, intent(in) :: irow, jcol
    double precision, intent(in) :: rof, cof
    double precision, intent(out) :: xgrid, ygrid
    ! local
    integer :: i, j
    !
    ! X direction (delr, jcol, and cof)
    xgrid = DZERO
    do j=1,jcol-1
      xgrid = xgrid + this%delr(j)
    enddo
    xgrid = xgrid + DHALF * this%delr(jcol)
    xgrid = xgrid + cof * this%delr(jcol)
    !
    ! Y direction (delc, irow, and rof)
    ygrid = DZERO
    do i=1,irow-1
      ygrid = ygrid - this%delc(i)
    enddo
    ygrid = ygrid - DHALF * this%delc(irow)
    ygrid = ygrid - rof * this%delc(irow)
    !
    return
  end subroutine calc_grid_coords

  subroutine write_preheadsmf_options(this, iuphmf)
    ! dummy
    class(ObsWriterType) :: this
    integer, intent(in) :: iuphmf
    ! formats
    10 format(a)
    15 format(2x,a)
    20 format(2x,a,2x,a)
    30 format(2x,a,2x,i0)
    40 format(2x,a,2x,g14.7)
    !
    write(iuphmf,10)'BEGIN OPTIONS'
    write(iuphmf,20)'DIS  FILEIN', trim(this%DisFileName)
    write(iuphmf,20)'MFOBSFILE  FILEOUT', trim(this%PhmfObsFileName)
    write(iuphmf,20)'POSTOBSFILE  FILEOUT', trim(this%PomfFileName)
!    write(iuphmf,20)'PRECISION', trim(this%Precis)
!need to write XORIGIN and YORIGIN with appropriate values for lower left corner of grid
    write(iuphmf,40)'XORIGIN', this%Preproc%XoriginLL
    !write(iuphmf,40)'YORIGIN', this%Preproc%dis%Yorigin
    write(iuphmf,40)'YORIGIN', this%Preproc%YoriginLL
    write(iuphmf,30)'DIGITS', this%NumDigits
    write(iuphmf,15)'VERBOSE'
    write(iuphmf,15)'OMITOPTIONS'
    write(iuphmf,10)'END OPTIONS'
    !
    return
  end subroutine write_preheadsmf_options

  subroutine WriteObsOptions(this)
    implicit none
    ! dummy
    class(ObsWriterType) :: this
    ! local
    integer :: iu
    ! formats
    20 format(2x,a,2x,a)
    30 format()
    40 format(2x,a)
    50 format(2x,a,2x,i0)
    60 format(a)
    !
    iu = this%fileobj%IUnit
    !write(iu,30)
    write(iu,60)'BEGIN Options'
    write(iu,40)'PRINT_INPUT'
    write(iu,50)'DIGITS',this%NumDigits
    !
    write(iu,60)'END Options'
    !
    return
  end subroutine WriteObsOptions

  subroutine WriteContinuous(this, igrid)
    implicit none
    ! dummy
    class(ObsWriterType) :: this
    integer, intent(in) :: igrid
    ! local
    integer :: i, ihed, iu, iuob, ml
    integer :: ilay, irow, icol
    integer :: mlayer
    integer :: ncharid, ncharlay
    double precision :: weight
    logical :: killonfailure, singlelayer, &
               colcentered, rowcentered
    character(len=LENOBSNAME) :: oname, onameml, onametemp
    character(len=LINELENGTH) :: outfilename
    character(len=LENOBSTYPE) :: otype
    character(len=*), parameter :: fmtaxi = '(a,1x,i0)'
!    character(len=*), parameter :: fmtxataxg3xi = &
!                                   '(2x,a,t30,a,2x,g15.8,3(2x,i0))'
    character(len=*), parameter :: fmtxata3xi = &
                                   '(2x,a,t30,a,3(2x,i0))'
    type(LayerObsType), pointer :: layobs => null()
    type(MLObsType), pointer :: mlobs => null()
    ! formats
    1 format()
    10 format(a,1x,a)
    !
    otype = 'HEAD'
    iu = this%fileobj%IUnit
    killonfailure = .false.
    iuob = iunit(28)  ! HOB input unit
    if (nhed<=0) return
    call assign_ncharsizes_hed(ncharid, ncharlay)
    outfilename = trim(this%basename) // '.hobs_out.csv'
    this%MfOutputCsvFileName = outfilename
    !
    write(iu,1)
    write(iu,10)'#','Head observations'
    write(iu,10)'BEGIN CONTINUOUS FILEOUT',trim(outfilename)
    !
    ihed = 0
    ml = 0
    headloop: do ihed=1,nhed
      ! Determine if observation is single-layer or multi-layer.
      if (nlayer(ihed) == 1) then
        ! observation is single-layer
        singlelayer = .true.
      else
        ! observation is multi-layer
        singlelayer = .false.
        ml = ml + 1
      endif
      !
      ! Determine if observation location is centered in cell or offcenter.
      if (this%Preproc%Active) then
        rowcentered = (roff(ihed) == DZERO)
        colcentered = (coff(ihed) == DZERO)
      else
        ! If heads preprocessor is not active, just treat obs location as
        ! being at cell center.
        rowcentered = .true.
        colcentered = .true.
      endif
      !
      ! Write lines to CONTINUOUS block only for centered observation location;
      ! PreHeadsMF will handle offset observations.
      if (rowcentered .and. colcentered) then
        ! Obs location is centered.
        ilay = NDER(1,ihed)
        irow = NDER(2,ihed)
        icol = NDER(3,ihed)
        !
        ! Check to see if this cell has already been handled/written.
        ! If so, skip it.
        if (ihed > 1) then
          do i=1,ihed-1
            if (ilay == nder(1,i) .and. irow == nder(2,i)   &
                .and. icol == nder(3,i)) then
              cycle headloop
            endif
          enddo
        endif
        !
        ! Assign observation name (or name base
        ! for multi-layer observation).
        oname = hobsname(ihed)
        if (singlelayer) then
          ! Obs is single-layer.
          ! No additional observation locations are needed.
          ! Go ahead and write line for one observation.
          write(iu,fmtxata3xi)trim(oname),trim(otype),ilay, &
                      irow,icol
        else
          ! Obs is multi-layer.
          ! Write obs line for each layer.
          call ConstructMLObs(mlobs, oname)
          call AddMLObsToList(this%MLObsList, mlobs)
          onametemp = trim(oname) // '_L'
          do i=1,nlayer(ihed)
            mlayer = MLAY(i,ml)
            weight = PR(i,ml)
            onameml = build_obsname(onametemp,mlayer,ncharlay)
            write(iu,fmtxata3xi)trim(onameml),trim(otype), &
                        mlayer,irow,icol
            call ConstructLayerObs(layobs, onameml, mlayer, weight)
            call AddLayerObsToList(mlobs%LayerObsList,layobs)
          enddo
        endif
      endif
    enddo headloop
    !
    write(iu,10)'END','CONTINUOUS'
    !
    return
  end subroutine WriteContinuous

  subroutine assign_ncharsizes_hed(ncharid, ncharlay)
    implicit none
    ! dummy
    integer, intent(inout) :: ncharid
    integer, intent(inout) :: ncharlay
    ! local
    integer :: lenmax=20
    character(len=LINELENGTH) :: msg_multilayer
    !
    ! Assign sizes for head observations
    if (mobs > 0) then
      ! At least one multi-layer head observation is defined.
      ! Assign ncharlay based on NLAY
      select case (nlay)
      case (1:9)
        ncharlay = 1
      case (10:99)
        ncharlay = 2
      case (100:999)
        ncharlay = 3
      case default
        ncharlay = 3
        msg_multilayer = 'NLAY is too large to support multi-layer ' &
                          // 'head observations for cells in layer > 999.'
        call store_warning(msg_multilayer)
      end select
      !
      ! Allow for leading "H", possible two characters used
      ! for offset indicator, and "_L" to lead layer number.
      ncharid = lenmax - 5 - ncharlay
    else
      ! No need to allow characters for layer number in obs names,
      ! but allow for leading "H" and possible two character used
      ! for offset indicator.
      ncharid = lenmax - 3
      ncharlay = 0
    endif
    !
    return
  end subroutine assign_ncharsizes_hed

  subroutine write_ml_postobs_file(this)
    ! Write all blocks of a multilayer PostObsMF input file
    ! dummy
    class(ObsWriterType) :: this
    ! local
    integer :: iu
    ! formats
    1 format()
    10 format(a,1x,a,1x,a)
    15 format(a,1x,a)
    20 format(2x,a)
    !
    this%MlPostObsFileName = trim(this%basename) // '.mlpo'
    this%IuMlPostObs = GetUnit()
    iu = this%IuMlPostObs
    call openfile(iu,0,this%MlPostObsFileName,'MLPO',filstat_opt='REPLACE')
    !
    ! Write Options block
    call this%write_ml_postobs_options()
    !
    ! Write Input_Files block
    call this%write_ml_postobs_input_files()
    !
    ! Write SINGLE block
    call this%write_ml_postobs_input()
    !
    return
  end subroutine write_ml_postobs_file

  subroutine write_ml_postobs_options(this)
    ! dummy
    class(ObsWriterType), intent(inout) :: this
    ! local
    integer :: iu
    ! formats
    10 format(a,1x,a)
    20 format(2x,a)
    30 format(2x,a,2x,a)
    40 format(2x,a,2x,i0)
    !
    iu = this%IuMlPostObs
    !
    ! Write BEGIN line
    write(iu,10)'BEGIN', 'OPTIONS'
    !
!    write(iu,30)'PRECISION', prec(this%Preproc%IPrecision)
    write(iu,40)'DIGITS', this%Preproc%Idigits
    !
    ! Write END line
    write(iu,10)'END', 'OPTIONS'
    !
    return
  end subroutine write_ml_postobs_options

  subroutine write_ml_postobs_input_files(this)
    ! dummy
    class(ObsWriterType), intent(inout) :: this
    ! local
    integer :: i, iu, n
    character(len=MAXCHARLEN) :: fname
    ! formats
    1 format()
    10 format(a,1x,a)
    20 format(2x,a,2x,a)
    !
    iu = this%IuMlPostObs
    write(iu,1)
    !
    ! Write BEGIN line
    write(iu,10)'BEGIN', 'INPUT_FILES'
    !
    fname = this%MfOutputCsvFileName
    write(iu,20)'SINGLE', trim(fname)
    n = size(this%Preproc%PostObsOutputCsvFiles)
    do i=1,n
      fname = this%Preproc%PostObsOutputCsvFiles(i)
      write(iu,20)'SINGLE', trim(fname)
    enddo
    !
    ! Write END line
    write(iu,10)'END', 'INPUT_FILES'
    !
    return
  end subroutine write_ml_postobs_input_files

  subroutine write_ml_postobs_input(this)
    ! dummy
    class(ObsWriterType) :: this
    ! local
    integer :: i, iu, j, nlayers, nobs
    character(len=MAXCHARLEN) :: fname
    type(MLObsType), pointer :: mlobs => null()
    type(LayerObsType), pointer :: layob => null()
    ! formats
    1 format()
    10 format(a,1x,a,1x,a)
    12 format(a,1x,a,1x,a,2x,'BINARY')
    15 format(a,1x,a)
    20 format(2x,a,2x,a)
    30 format(4x,a,2x,G14.7)
    !
    ! Write BEGIN line
    iu = this%IuMlPostObs
    write(iu,1)
    fname = trim(this%MlPostObsFileName) // '.post.csv'
    write(iu,10)'BEGIN', 'SINGLE FILEOUT', trim(fname)
    !
    ! Write observation information
    nobs = this%MLObsList%Count()
    do i=1,nobs
      mlobs => GetMLObsFromList(this%MLObsList, i)
      call mlobs%CheckWeightSum()
      ! Write NEW line
      write(iu,20)'NEW',trim(mlobs%mlobsname)
      ! Write source line for each layer
      nlayers = mlobs%LayerObsList%Count()
      do j=1,nlayers
        layob => GetLayerObsFromList(mlobs%LayerObsList, j)
        write(iu,30)trim(layob%lobsname), layob%weight
      enddo
    enddo
    !
    ! Write END line
    write(iu,15)'END','SINGLE'
    !
    return
  end subroutine write_ml_postobs_input

end module ObsWriterModule
