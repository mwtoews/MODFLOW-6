      MODULE GWFHFBMODULE
        INTEGER, POINTER  ::MXHFB,NHFB,IPRHFB,NHFBNP,NPHFB,IHFBPB,
     &                      NumHFBs
        REAL,    DIMENSION(:,:), POINTER   ::HFB
      TYPE GWFHFBTYPE
        INTEGER, POINTER  ::MXHFB,NHFB,IPRHFB,NHFBNP,NPHFB,IHFBPB,
     &                      NumHFBs
        REAL,    DIMENSION(:,:), POINTER   ::HFB
      END TYPE
      TYPE(GWFHFBTYPE), SAVE    ::GWFHFBDAT(10)
      END MODULE GWFHFBMODULE


