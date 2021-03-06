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

!* leoF11_async ..............................................................
!
! This sample demonstrates using the OFFLOAD_TRANSFER and OFFLOAD_WAIT
! directives for memory allocation on the Target CPU and for performing
! asynchronous data transfers. 
!
!.............................................................................

    module leoF11_async_glbls

       use leoF_utils    ! Provides samples utility routines, globals,
                         ! access to OMP (omp_lib) and Intel(R) MIC
                         ! Architecture (mic_lib) APIs

       implicit none

       ! Max iterations and array size

       integer, parameter           :: MAX_iterations = 10
       integer, parameter           :: MAX_EXTENT = 25000

       ! Global variables used within offload code require declaration
       ! with an OFFLOAD attribute. Demonstrate use of !DIR$ OPTIONS below

       !DIR$ OPTIONS /offload_attribute_target=mic

       ! Data arrays
       real, allocatable, dimension(:)       :: INvec1, INvec2
       real, allocatable, dimension(:)       :: OUTvec1, OUTvec2

       ! Asynchronous offload signals
       integer                               :: sigIN1, sigIN2
       integer                               :: sigOUT1, sigOUT2

       ! SUMs
       real                                  :: Host_SUM, Target_SUM

       ! Timings : (1) = begin time, (2) = end time
       integer, dimension(2)                 :: bNe_times

       ! Target CPU id
       integer                               :: target_id

       !DIR$ END OPTIONS

       CONTAINS 

       integer function leoF11_async_get_TIME

       USE IFPORT

       integer, dimension(2)                 :: T_vals
       integer                               :: Ierr

       CALL GETTIMEOFDAY (T_vals, Ierr)

       if ( Ierr .NE. -1 ) then
          ! Return microseconds
          leoF11_async_get_TIME = T_vals(2)
       else
          leoF11_async_get_TIME = 0
       endif

       end function leoF11_async_get_TIME


       !  Decorate with ATTRIBUTES OFFLOAD to enable execution from
       !  within offloaded code

       !DIR$ ATTRIBUTES OFFLOAD : mic :: leoF11_compute
       subroutine leoF11_compute(vecX, vecY)

       !  Perform computation

       real, allocatable, dimension(:)       :: vecX, vecY
       integer                               :: i

       !  For demonstration purposes limit # of OMP threads to 4

       !$omp parallel do num_threads(4) 
          do i = 1, MAX_EXTENT
             vecY(i) = vecX(i) * vecX(i)
          end do
       !$omp end parallel do

       if (verbosity >= 3) then
          print "(4X,A,2(7X,A))", "Data sample inside compute: index", &
                          "X(index)","Y(index)"

          do i = 0, MAX_EXTENT, (MAX_EXTENT / 3)
             print "(25X,I,F,F)",i+1,vecX(i+1),vecY(i+1)
          enddo
       endif

       ! Verify offload execution
       call offload_check()

       return
       end subroutine leoF11_compute


       subroutine leoF11_async_in()

       !  Perform computation and use asynchronous offload IN data 
       !  transfers 

       real                            :: temp_SUM
       integer                         :: i

       temp_SUM = 0.0

       !  The OFFLOAD_TRANSFER directive is a stand-alone extension not
       !  associated with any statement that follows it.

       !  Set transfers in motion with an initial transfer of INvec2 and 
       !  proceed without waiting.  Data values were initialized in the
       !  caller (leoF11_asnc)

       !  Transfer of INvec2 is necessary given structure of proceeding
       !  loop where odd iterations wait on sigIN2. We must have that 
       !  signal armed for first iteration of loop to avoid deadlocking
       !  on the first iteration on the signals.

       !  alloc_if(.false.) necessary to use previous allocations on 
       !  Target CPU done in the caller (leoF11_async)

       !DIR$ OFFLOAD_TRANSFER target(mic : target_id)                  &
                                     if (target_id /= -1)              &
                                     in( INvec2 : alloc_if(.false.)    &
                                                  free_if(.false.) )   &
                                     signal(sigIN2)
       do i = 1, MAX_iterations

          offload_section_id = i         ! offload section id

          if ( MOD(i,2) == 0 ) then   !   ( MOD(i,2) == 0 )

             !  The OFFLOAD_TRANSFER directive is a stand-alone extension
             !  not associated with any statement that follows it.

             !  For even #-ed iterations less than MAX_iterations 
             !  (as per IF clause in OFFLOAD_TRANSFER statement), 
             !  initiate the transfer of INvec2 to Target CPU and proceed.

             !  The OFFLOAD_TRANSFER directive associates signal sigIN2 
             !  with the transfer

             !  alloc_if(.false.) necessary to use previous allocations on 
             !  Target CPU done in the caller (leoF11_async)


             !DIR$ OFFLOAD_TRANSFER target(mic : target_id)                 &
                                           if( (target_id /= -1) .AND.      &
                                               (i /= MAX_iterations) )      &
                                           in( INvec2 : alloc_if(.false.)   &
                                                        free_if(.false.) )  &
                                           signal(sigIN2)


             !  Wait for transfer IN of vecIN1 (via signal sigIN1) and when 
             !  ready, then offload the compute

             !  Use of offload_section_id and modification of offload_sections
             !  in offload_check (called inside leoF11_compute) is outside 
             !  the compiler's lexical scope; therefore, use explicit 
             !  IN/INOUT clauses

             !  alloc_if(.false.) necessary to use previous allocations on 
             !  Target CPU done in the caller (leoF11_async)


             !DIR$ OFFLOAD target(mic : target_id)                           &
                                           if (target_id /= -1)              &
                                           out( OUTvec1 : alloc_if(.false.)  &
                                                          free_if(.false.) ) &
                                           wait(sigIN1)                      &
                            in(offload_section_id) inout(offload_sections)
             call leoF11_compute(INvec1, OUTvec1)

             temp_SUM = temp_SUM + SUM(OUTvec1)

          else    !   ( MOD(i,2) == 0 )

             !  The OFFLOAD_TRANSFER directive is a stand-alone extension
             !  not associated with any statement that follows it.

             !  For odd #-ed iterations less than MAX_iterations 
             !  (as per IF clause in OFFLOAD_TRANSFER statement), 
             !  initiate the transfer of INvec2 to Target CPU and proceed.

             !  The OFFLOAD_TRANSFER directive associates signal sigIN1 
             !  with the transfer

             !  alloc_if(.false.) necessary to use previous allocations on 
             !  Target CPU done in the caller (leoF11_async)


             !DIR$ OFFLOAD_TRANSFER target(mic : target_id)                 &
                                    if( (target_id /= -1) .AND.             &
                                        (i /= MAX_iterations) )             &
                                    in( INvec1 : alloc_if(.false.)          &
                                                 free_if(.false.) )         &
                                    signal(sigIN1)

             !  Wait for transfer IN of vecIN2 (via signal sigIN2) and when 
             !  ready, then offload the compute

             !  Use of offload_section_id and modification of offload_sections
             !  in offload_check (called inside leoF11_compute) is outside 
             !  the compiler's lexical scope; therefore, use explicit 
             !  IN/INOUT clauses

             !  alloc_if(.false.) necessary to use previous allocations on 
             !  Target CPU done in the caller (leoF11_async)


             !DIR$ OFFLOAD target(mic : target_id)                           &
                                           if (target_id /= -1)              &
                                           out( OUTvec2 : alloc_if(.false.)  &
                                                          free_if(.false.) ) &
                                           wait(sigIN2)                      &
                            in(offload_section_id) inout(offload_sections)
             call leoF11_compute(INvec2, OUTvec2)

             temp_SUM = temp_SUM + SUM(OUTvec2)

          endif   !   ( MOD(i,2) == 0 )

       enddo      !  do i = 1, MAX_iterations

       Target_SUM = temp_SUM / MAX_iterations

       return
       end subroutine leoF11_async_in


       subroutine leoF11_async_out()

       !  Perform computation and use asynchronous offload OUT data 
       !  transfers 

       real                            :: temp_SUM
       integer                         :: i

       temp_SUM = 0.0

       !  Loop over all iterations transferring and computing using
       !  a double buffer method

       do i=1, MAX_iterations + 1 

          offload_section_id = i         ! offload section id

          if ( MOD(i,2) == 0 ) then

             if ( i < (MAX_iterations + 1) ) then

                !  For even #-ed iterations less than MAX_iterations + 1,
                !  offload the compute and leave OUTvec1 values on the 
                !  Target CPU. Then initiate an asynchronous transfer
                !  of OUTvec1 back to the host and proceed.

                !  Use of offload_section_id and modification of 
                !  offload_sections in offload_check (called inside 
                !  leoF11_compute) is outside the compiler's lexical scope;
                !  therefore, use explicit IN/INOUT clauses

                !  alloc_if(.false.) necessary to use previous allocations 
                !  on Target CPU done in the caller (leoF11_async)


                !DIR$ OFFLOAD target(mic : target_id)                        &
                                     if (target_id /= -1)                    &
                                     in( INvec1 : alloc_if(.false.)          &
                                                  free_if(.false.))          &
                                     nocopy(OUTvec1)                         &
                              in(offload_section_id) inout(offload_sections)
                call leoF11_compute(INvec1, OUTvec1)

                !  The OFFLOAD_TRANSFER directive is a stand-alone extension 
                !  not associated with any statement that follows it.

                !  The directive initiates transfer of OUTvec1 back to the
                !  host and proceeds. It associates signal sigOUT1 with 
                !  the transfer

                !  alloc_if(.false.) necessary to use previous allocations 
                !  on Target CPU done in the caller (leoF11_async)

                !DIR$ OFFLOAD_TRANSFER target(mic : target_id)            &
                                       if (target_id /= -1)               &
                                        out( OUTvec1 : alloc_if(.false.)  &
                                                       free_if(.false.) ) &
                                                       signal(sigOUT1)

             endif     ! ( i < (MAX_iterations + 1) ) 

             !  The OFFLOAD_WAIT directive is a stand-alone extension that
             !  is not associated with any statement that follows it.

             !  After all iterations are complete, perform one final wait
             !  on sigOUT2

             !DIR$ OFFLOAD_WAIT target(mic : target_id)             &
                                       if (target_id /= -1)         &
                                       wait(sigOUT2)

             temp_SUM = temp_SUM + SUM(OUTvec2)

             call leoF11_use_result(OUTvec2)

          else    !   ( MOD(i,2) == 0 ) 

             if ( i < MAX_iterations + 1) then

                !  For odd #-ed iterations less than MAX_iterations + 1,
                !  offload the compute and leave OUTvec2 values on the 
                !  Target CPU. Then initiate an asynchronous transfer
                !  of OUTvec2 back to the host and proceed.

                !  Use of offload_section_id and modification of 
                !  offload_sections in offload_check (called inside 
                !  leoF11_compute) is outside the compiler's lexical scope;
                !  therefore, use explicit IN/INOUT clauses

                !  alloc_if(.false.) necessary to use previous allocations 
                !  on Target CPU done in the caller (leoF11_async)


                !DIR$ OFFLOAD target(mic : target_id)                        &
                                     if (target_id /= -1)                    &
                                     in(INvec2 : alloc_if(.false.)           &
                                                 free_if(.false.) )          &
                                     nocopy(OUTvec2)                         &
                              in(offload_section_id) inout(offload_sections)
                call leoF11_compute(INvec2, OUTvec2)

                !  The OFFLOAD_TRANSFER directive is a stand-alone extension 
                !  not associated with any statement that follows it.

                !  The directive initiates transfer of OUTvec2 back to the
                !  host and proceeds. It associates signal sigOUT2 with
                !  the transfer

                !  alloc_if(.false.) necessary to use previous allocations 
                !  on Target CPU done in the caller (leoF11_async)


               !DIR$ OFFLOAD_TRANSFER target(mic : target_id)           &
                                      if (target_id /= -1)              &
                                      out(OUTvec2 : alloc_if(.false.)   &
                                                    free_if(.false.) )  &
                                      signal(sigOUT2)

             endif    !  ( i < MAX_iterations + 1)

             if (i > 1) then

                !  The OFFLOAD_WAIT directive is a stand-alone extension that
                !  is not associated with any statement that follows it.

                !  Do not wait for signal on first iteration to avoid 
                !  deadlocking loop waiting for a non-armed signal.


                !DIR$ OFFLOAD_WAIT target(mic : target_id)            &
                                              if (target_id /= -1)    &
                                              wait(sigOUT1)

                temp_SUM = temp_SUM + SUM(OUTvec1)

                call leoF11_use_result(OUTvec1);

             endif

          endif  !  ( MOD(i,2) == 0 )

       enddo  !  do i=1, MAX_iterations + 1 

       Target_SUM = temp_SUM / MAX_iterations

       return
       end subroutine leoF11_async_out


       subroutine leoF11_sync()

       !  Perform computations and use synchronous data transfers

       real                            :: temp_SUM
       integer                         :: i

       temp_SUM = 0.0

       do i = 1, MAX_iterations

          offload_section_id = i         ! offload section id

          if ( MOD(i,2) == 0 ) then

             !  For even #-ed iterations, offload the compute and use
             !  synchronous data transfers for INvec1 and OUTvec1

             !  Use of offload_section_id and modification of offload_sections
             !  in offload_check (called inside leoF11_compute) is outside 
             !  the compiler's lexical scope; therefore, use explicit 
             !  IN/INOUT clauses


             !DIR$ OFFLOAD target(mic : target_id)                           &
                           if (target_id /= -1)                              &
                           in(INvec1 : alloc_if(.false.) free_if(.false.))   &
                           out(OUTvec1 : alloc_if(.false.) free_if(.false.)) &
                           in(offload_section_id) inout(offload_sections)
             call leoF11_compute(INvec1, OUTvec1)

             temp_SUM = temp_SUM + SUM(OUTvec1)

          else  !  ( MOD(i,2) == 0 )

             !  For odd #-ed iterations, offload the compute and use
             !  synchronous data transfers for INvec2 and OUTvec2

             !  Use of offload_section_id and modification of offload_sections
             !  in offload_check (called inside leoF11_compute) is outside 
             !  the compiler's lexical scope; therefore, use explicit 
             !  IN/INOUT clauses


             !DIR$ OFFLOAD target(mic : target_id)                           &
                           if (target_id /= -1)                              &
                           in(INvec2 : alloc_if(.false.) free_if(.false.))   &
                           out(OUTvec2 : alloc_if(.false.) free_if(.false.)) &
                           in(offload_section_id) inout(offload_sections)
             call leoF11_compute(INvec2, OUTvec2)

             temp_SUM = temp_SUM + SUM(OUTvec2)

          endif  !  ( MOD(i,2) == 0 )

       enddo  !  do i = 1, MAX_iterations

       Target_SUM = temp_SUM / REAL(MAX_iterations)

       return
       end subroutine leoF11_sync


       subroutine leoF11_host()

       !  Perform computations on host CPU. No data transfers

       real                            :: temp_SUM
       integer                         :: i

       temp_SUM = 0.0

       do i= 1, MAX_iterations

          offload_section_id = i         ! offload section id

          if ( MOD(i,2) == 0 ) then

             !  For even #-ed iterations compute on host using 
             !  INvec1 and OUTvec1

             call leoF11_compute(INvec1, OUTvec1)

             temp_SUM = temp_SUM + SUM(OUTvec1)

          else  !  ( MOD(i,2) == 0 )

             !  For odd #-ed iterations compute on host using 
             !  INvec2 and OUTvec2

             call leoF11_compute(INvec2, OUTvec2)

             temp_SUM = temp_SUM + SUM(OUTvec2)

          endif  !  ( MOD(i,2) == 0 )

       enddo

       Target_SUM = temp_SUM / REAL(MAX_iterations)

       return
       end subroutine leoF11_host


       subroutine leoF11_init()

       integer                         :: i

       !  Initialize arrays

       INvec1 = (/ ((REAL(i) * .001),i=1, MAX_EXTENT) /)
       INvec2 = (/ ((REAL(i) * .001),i=1, MAX_EXTENT) /)

       OUTvec1 = 0.0
       OUTvec2 = 0.0

       return
       end subroutine leoF11_init


       subroutine leoF11_use_result(vecX)

       real, allocatable, dimension(:)       :: vecX

       !  Subprogram could perform other actions on results computed
       !  on Target CPU and returned to Host CPU

       return
       end subroutine leoF11_use_result

    end module leoF11_async_glbls


    subroutine leoF11_async

    !  leoF11_async() - Perform computations and uses different
    !  data transfer methods

    ! Case 1 = host, no data transfers
    ! Case 2 = synchronous data transfers
    ! Case 3 = asynchronous IN data transfers
    ! Case 4 = asynchronous OUT data transfers


    use leoF11_async_glbls    ! leoF11 specific globals. Also provides
                              ! USE leoF_utils  -   Provides samples 
                              ! utility routines, globals, access to
                              ! OMP (omp_lib) and Intel(R) MIC
                              ! Architecture (mic_lib) APIs

    implicit none

    character (LEN=*),parameter  :: sample_name = "leoF11_async"
    integer          ,parameter  :: NUM_CASES = 4

    integer                      :: offload_case


    ! Setup and initialization

    ! number of offload sections in sample
    num_offload_sections = MAX_iterations

    call leoF_setup(sample_name)

    ! MAX_EXTENT extent must be >= 4 
    if (MAX_EXTENT < 4) then
        print "(4X,3(A))", "*** FAIL ",sample_name," - value for MAX_EXTENT not usable - must be >= 4"
        return

    ! MAX_iterations must be >= 2
    else if (MAX_iterations < 2) then
        print "(4X,3(A))", "*** FAIL ",sample_name," - value for MAX_iterations not usable - must be >= 2"
        return
    endif

    ! Loop over cases
    !   Case 1 = host, no data transfers
    !   Case 2 = synchronous data transfers
    !   Case 3 = asynchronous IN data transfers
    !   Case 4 = asynchronous OUT data transfers

    do offload_case = 1, NUM_CASES

       if (verbosity >= 1) print "(4X,A,I0)", "--> Start Case #",offload_case

       ! Allocate and initialize arrays

       allocate ( INvec1(MAX_EXTENT) )
       allocate ( INvec2(MAX_EXTENT) )
       allocate ( OUTvec1(MAX_EXTENT) )
       allocate ( OUTvec2(MAX_EXTENT) )

       !  Obtain a Target CPU and capture target_id

       !DIR$ OFFLOAD begin target(mic)  inout(target_id)
#      ifdef __INTEL_OFFLOAD
          target_id = OFFLOAD_GET_DEVICE_NUMBER()
#      else
          target_id = -1
#      endif

       !DIR$ END OFFLOAD

       !  The OFFLOAD_TRANSFER directive is a stand-alone extension not
       !  associated with any statement that follows it.

       !  Use directive to allocate memory on Target CPU only and retain
       !  for the duration of the current case


       !DIR$ OFFLOAD_TRANSFER target(mic : target_id)                      &
                              if (target_id /= -1)                         &
                              nocopy( INvec1, OUTvec1, INvec2, OUTvec2 :   &
                                      alloc_if(.true.) free_if(.false.) )


       ! Initialize data values
       call leoF11_init()

       bNe_times = 0
       Target_SUM = 0.0

       OFFLOAD_TYPE: select case (offload_case)

       CASE (1)

          !  Perform computation on host, no data transfers

          !  Use of offload_section_id and modification of offload_sections
          !  in offload_check is outside the compiler's lexical scope; 
          !  therefore, use explicit IN/INOUT clauses


          bNe_times(1) = leoF11_async_get_TIME()

          call leoF11_host()

          bNe_times(2) = leoF11_async_get_TIME()

          Host_SUM = Target_SUM        !  Save as reference result 

       CASE (2)

          !  Perform computation and use synchronous data transfers

          bNe_times(1) = leoF11_async_get_TIME()

          call leoF11_sync()

          bNe_times(2) = leoF11_async_get_TIME()
         
       CASE(3)

          !  Perform computation and use asynchronous data IN transfers

          bNe_times(1) = leoF11_async_get_TIME()

          call leoF11_async_in()

          bNe_times(2) = leoF11_async_get_TIME()

       CASE(4)

          !  Perform computation and use asynchronous data OUT transfers

          bNe_times(1) = leoF11_async_get_TIME()

          call leoF11_async_out()

          bNe_times(2) = leoF11_async_get_TIME()

       CASE DEFAULT
           call abort("*** ABORT - internal failure in leoF11_async")

       end select OFFLOAD_TYPE

       ! Check results
       call leoF11_async_chk_results(offload_case, sample_name)

       if (verbosity >= 1) print "(4X,A,I0,/)", "--> End Case #",offload_case

       ! Cleanup

       !  Free allocations on the Target CPU for current case

       !DIR$ OFFLOAD_TRANSFER target(mic : target_id)                      &
                              if (target_id /= -1)                         &
                              nocopy( INvec1, OUTvec1, INvec2, OUTvec2 :   &
                                      alloc_if(.false.) free_if(.true.) )

       !  Deallocate arrays

       deallocate ( INvec1 )
       deallocate ( INvec2 )
       deallocate ( OUTvec1 )
       deallocate ( OUTvec2 )

    enddo

    ! Cleanup
    call leoF_cleanup(sample_name)

    return
    end subroutine leoF11_async


    subroutine leoF11_async_chk_results(offload_case, sample_name)

    use leoF11_async_glbls    ! leoF11 specific globals. Also provides
                              ! USE leoF_utils  -   Provides samples 
                              ! utility routines, globals, access to
                              ! OMP (omp_lib) and Intel(R) MIC
                              ! Architecture (mic_lib) APIs


    implicit none

    integer          , intent(in)  :: offload_case
    character (LEN=*), intent(in)  :: sample_name

    character (LEN=15)     :: err_str


    ! verify results   

    if (offload_case > 1) then
       if (verbosity >= 2) then
          print "(4X,2(A,F15.2))", "Results: Expected sum = ",Host_SUM, &
                                   " Actual Target_SUM = ",Target_SUM
          print "(4X,A,I)", "Elapsed time (usecs): ", &
                                     ( bNe_times(2) - bNe_times(1) )

          ! Display offload section details
          call offload_summary
       endif
    endif


    ! Validate results
    if ( offload_case > 1) then
       if ( (Host_SUM > 0.0)          .AND.    &
            (Host_SUM == Target_SUM ) .AND.    &
             offload_verify(3) ) then
          print 2000, sample_name, offload_case
       else
          if (.NOT. offload_verify(1)) then
             err_str="offload failure"
          else
             err_str="data mismatch"
          endif
          print 2001, sample_name, offload_case, err_str
       endif
    else
       if ( (Host_SUM > 0.0) .AND.    &
            (Host_SUM == Target_SUM ) ) then
          print 2000, sample_name, offload_case
        else
          err_str="data mismatch"
          print 2001, sample_name, offload_case, err_str
        endif
    endif

 2000  format(4X,"PASS ",A," (Case #",I0,")")
 2001  format(4X,"*** FAIL ",A," (Case #",I0,") : ",A)

    return

    end subroutine leoF11_async_chk_results
!*............................................................... leoF11_async
