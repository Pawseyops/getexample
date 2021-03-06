!# Copyright (C) 2012 Intel Corporation. All Rights Reserved.
!#
!# The source code contained or described herein and all
!# documents related to the source code ("Material") are owned by
!# Intel Corporation or its suppliers or licensors. Title to the
!# Material remains with Intel Corporation or its suppliers and
!# licensors. The Material is protected by worldwide copyright
!# laws and treaty provisions.  No part of the Material may be
!# used, copied, reproduced, modified, published, uploaded,
!# posted, transmitted, distributed,  or disclosed in any way
!# except as expressly provided in the license provided with the
!# Materials.  No license under any patent, copyright, trade
!# secret or other intellectual property right is granted to or
!# conferred upon you by disclosure or delivery of the Materials,
!# either expressly, by implication, inducement, estoppel or
!# otherwise, except as expressly provided in the license
!# provided with the Materials.
!#
!#
!#******************************************************************************
!# Content:
!#
!#  Intel(R) Fortran Composer XE 2013
!#  Example Program Text from Sample LEO_Fortran_intro
!#******************************************************************************

!* leoF06_assumed_size_array .................................................
!
! This sample demonstrates using an assumed-size array in an offload OMP
! construct, a non-OMP offload code section, and a non-offload (Host-side)
! code section.
!
! Clarifications:
!
!  1. All variables (x, res) exchanged between the Host and
!     Target CPUs are lexically visible (to the compiler) within the
!     offloaded code; therefore, none require naming in an IN/OUT/INOUT
!     clause and all are treated as INOUT by default by the compiler.
!
!  2. Dummy argument (dimSZ) declared intent(in) requires specification 
!     in an IN clause.
!
!  3. The array is large and a candidate for tailoring the exchange
!     between the Host and Target CPUs with explicit IN/OUT clauses befitting
!     of use within the offload code. (i.e., IN(array3D) )
!
!  4. Assumed size variables require specifying a length using the LENGTH 
!     modifier with the IN/INOUT/OUT clause.
!
!.............................................................................


    subroutine leoF06_assumed_sz_offld(array3D, dimSZ, res, offload_case)

    ! leoF06_assumed_sz_offld() - Offload OMP construct and non-OMP code 
    ! sections that operate on assumed-size array argument.

    ! case 1 = no offload - execute on host-CPU only
    ! case 2 = OMP OFFLOAD
    ! case 3 = OFFLOAD Begin/End

    use leoF_utils    ! Provides samples utility routines, globals,
                      ! access to OMP (omp_lib) and Intel(R) MIC
                      ! Architecture (mic_lib) APIs

    implicit none

    integer,                 intent(in)  :: dimSZ, offload_case
    integer,                 intent(out) :: res
    integer, dimension(1:*), intent(in)  :: array3D

    integer                              :: x


    res = 0

    OFFLOAD_TYPE: select case (offload_case)

    CASE (1)

       ! No OFFLOAD - host-CPU execution
       do x = 1,dimSZ
          res = res + array3D(x)
       enddo

    CASE(2)

       offload_section_id = 1         ! offload section #1

       !  Offload OMP constructs using OMP OFFLOAD directive

       !  Tailor data transfers with an IN clause to only transfer values
       !  of the array from the Host CPU to the Target CPU 
       !  *AND* dummy arguments declared intent(in) which require
       !  specification in an IN clause.

       !  Assumed-size variables require a LENGTH modifier.

       !  Use of offload_section_id and modification of offload_sections
       !  in offload_check is outside the compiler's lexical scope; therefore,
       !  use explicit IN/INOUT clauses

       !  For demonstration purposes limit # of OMP threads to 4

       !DIR$ OMP OFFLOAD target(mic) in(dimSZ)                   &
                                     in(array3D : length(dimSZ)) &
                                     inout(res)                  &
                         in(offload_section_id) inout(offload_sections)
       !$omp parallel reduction(+:res) num_threads(4)
           !$omp do
           do x = 1,dimSZ
              res = res + array3D(x)
           enddo

           ! Verify offload execution with one thread only.
           !$omp single
              call offload_check()
           !$omp end single
       !$omp end parallel 

    CASE(3)

       offload_section_id = 1         ! offload section #1

       !  Offload code block using OFFLOAD BEGIN/END directives

       !  Tailor data transfers with an IN clause to only transfer values
       !  of the array from the Host CPU to the Target CPU
       !  *AND* dummy arguments declared intent(in) which require
       !  specification in an IN clause.

       !  Assumed-size variables require a LENGTH modifier.

       !  Use of offload_section_id and modification of offload_sections
       !  in offload_check is outside the compiler's lexical scope; therefore,
       !  use explicit IN/INOUT clauses

       !DIR$ OFFLOAD BEGIN target(mic) in(dimSZ)                   &
                                       in(array3D : length(dimSZ)) &
                                       inout(res)                  &
                           in(offload_section_id) inout(offload_sections)
       do x = 1,dimSZ
          res = res + array3D(x)
       enddo

       ! Verify offload execution
       call offload_check()
       !DIR$ END OFFLOAD

    CASE DEFAULT
        call abort("*** ABORT - internal failure in leoF06_assumed_sz_offld")

    end select OFFLOAD_TYPE

    return
    end subroutine leoF06_assumed_sz_offld


    subroutine leoF06_assumed_size_array

    use leoF_utils    ! Provides samples utility routines, globals,
                      ! access to OMP (omp_lib) and Intel(R) MIC
                      ! Architecture (mic_lib) APIs

    implicit none

    character (LEN=*),parameter   :: sample_name ="leoF06_assumed_size_array"
    integer          ,parameter   :: NUM_CASES = 3
    integer          ,parameter   :: NUM_EXTENTS = 3
    integer          ,parameter   :: MAX_EXTENT = 900

    integer, dimension(NUM_EXTENTS)      :: extents
    integer                              :: i, j, k, sz, ext, off_res
    integer                              :: offload_case, sum_res
    integer, allocatable, dimension(:)   :: arrayA


    ! Setup and initialization
    num_offload_sections = 1       ! number of offload sections in sample

    call leoF_setup(sample_name)

    ! Generate array extents to test
    extents = (/(i,i=(MAX_EXTENT/NUM_EXTENTS),MAX_EXTENT, &
                     (MAX_EXTENT/NUM_EXTENTS))/)

    ! Alloc arrayA to max extent and initialize
    allocate(arrayA(MAX_EXTENT))

    arrayA = (/ (i,i=1,MAX_EXTENT) /)

    ! Loop to test all extents
    do ext = 1, NUM_EXTENTS

       sz =  extents(ext)

       sum_res = SUM( (/ (i,i=1,sz) /) )

      ! Loop over OFFLOAD cases
      ! case 1 = no offload - execute on host-CPU only)
      ! case 2 = OMP OFFLOAD
      ! case 3 = OFFLOAD Begin/End)

      do offload_case = 1, NUM_CASES

         if (verbosity >= 1) print "(4X,2(A,I0),A)", "--> Start Case #", &
                             offload_case, " [dim=", sz, "]"

         ! Offload assumed-size array
         call leoF06_assumed_sz_offld(arrayA, sz, off_res, offload_case)

         ! Check results
         call leoF06_assumed_sz_chk_results( &
                     off_res, sum_res, sz, offload_case, sample_name)

         if (verbosity >= 1) print "(4X,A,I0,/)", "--> End Case #",offload_case

       enddo
    enddo 

    ! Cleanup
    deallocate(arrayA)

    call leoF_cleanup(sample_name)

    return
    end subroutine leoF06_assumed_size_array


    subroutine leoF06_assumed_sz_chk_results( &
                      res, sum_res, sz, offload_case, sample_name)

    use leoF_utils    ! Provides samples utility routines, globals,
                      ! access to OMP (omp_lib) and Intel(R) MIC
                      ! Architecture (mic_lib) APIs

    implicit none

    integer          , intent(in)    :: res, sum_res, sz, offload_case
    character (LEN=*), intent(in)    :: sample_name

    character (LEN=15)               :: err_str

    if (verbosity >= 2) then
        print "(4X,2(A,I))", "Results: Expected sum = ",sum_res, &
                             " Actual sum = ",res 

       ! Display offload section details
       call offload_summary
    endif

    ! Validate results
    if ( offload_case > 1) then
       if ( (res == sum_res) .AND. &
             offload_verify(3) ) then
          print 2000, sample_name, offload_case, sz
       else
          if (.NOT. offload_verify(1)) then
             err_str="offload failure"
          else
             err_str="data mismatch"
          endif
          print 2001, sample_name, offload_case, sz, err_str
       endif
    else
       if (res == sum_res) then
          print 2000, sample_name, offload_case, sz
       else
          err_str="data mismatch"
          print 2001, sample_name, offload_case, sz, err_str
       endif
    endif

2000  format(4X,"PASS ",A," (Case #",I0," - [dim=",I0,"])")
2001  format(4X,"*** FAIL ",A," (Case #",I0," - [dim=",I0,"]) : ",A)

    return
    end subroutine leoF06_assumed_sz_chk_results
!*.................................................. leoF06_assumed_size_array
