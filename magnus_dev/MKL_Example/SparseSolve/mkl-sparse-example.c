/*******************************************************************************
!
!   Copyright(C) 2005-2009 Intel Corporation. All Rights Reserved.
!   The information  and  material ("Material")  provided  below  is  owned  by  Intel
!   Corporation  or its suppliers or licensors,  and  title  to such  Material remains
!   with  Intel Corporation  or  its  suppliers or licensors.  The  Material  contains
!   proprietary information of Intel or its suppliers and licensors.  The  Material is
!   protected  by  worldwide  copyright laws  and  treaty  provisions.  No part of the
!   Material  may be used, copied, reproduced, modified, published, uploaded,  posted,
!   transmitted, distributed  or disclosed  in any way without  Intel's  prior express
!   written permission.
!   No license  under any  patent,  copyright,  or  other intellectual property rights
!   is granted to or conferred upon you, either expressly, by implication, inducement,
!   estoppel  or otherwise.  Any license  under such intellectual property rights must
!   be express and approved by Intel in writing.
!
!*******************************************************************************
!  Content: Intel MKL RCI (P)CG Fortran-77 example
!
!*******************************************************************************/

#include <stdio.h>
#include "mkl_rci.h"
#include "mkl_blas.h"
#include "mkl_spblas.h"
#include "mkl_service.h"

/*---------------------------------------------------------------------------*/
/*  Example of Use RCI (Preconditioned) Conjugate Gradient Solver */
/*---------------------------------------------------------------------------*/
/*  Example program for solving symmetric positive definite system of equations.*/
/*  Simplest case: no preconditioning and no user-defined stopping tests.*/
/*---------------------------------------------------------------------------*/
int main(void)
{
/*---------------------------------------------------------------------------*/
/* Define arrays for the upper triangle of the coefficient matrix and rhs vector*/
/* Compressed sparse row storage is used for sparse representation           */
/*---------------------------------------------------------------------------*/
MKL_INT n=8, rci_request, itercount, expected_itercount=8, i;
double  rhs[8];
/* Fill all arrays containing matrix data. */
MKL_INT ia[9]={1,5,8,10,12,15,17,18,19};
MKL_INT ja[18]={1,  3,    6,7,
	    2,3,  5,
    	3,        8,
	    4,    7,
	    5,6,7,
	    6,  8,
	    7,
	    8};
double a[18]={7.E0,      1.E0,           2.E0, 7.E0,
	    -4.E0,8.E0,     2.E0,
	    1.E0,                      5.E0,
	    7.E0,      9.E0,
	    5.E0, 1.E0, 5.E0,
     -1.E0,      5.E0,
	    11.E0,
	    5.E0};

/*---------------------------------------------------------------------------*/
/* Allocate storage for the solver ?par and temporary storage tmp            */
/*---------------------------------------------------------------------------*/
/* MKL_INT length=128; */
double expected_sol[8]={1.E0, 0.E0, 1.E0, 0.E0, 1.E0, 0.E0, 1.E0, 0.E0};
/*---------------------------------------------------------------------------*/
/* Some additional variables to use with the RCI (P)CG solver                */
/*---------------------------------------------------------------------------*/
double  solution[8];
MKL_INT ipar[128];
double euclidean_norm, dpar[128],tmp[4*8];
char tr='u';
/* double eone=-1.E0; */
/* MKL_INT ione=1; */

/*---------------------------------------------------------------------------*/
/* Initialize the right hand side through matrix-vector product              */
/*---------------------------------------------------------------------------*/
mkl_dcsrsymv(&tr, &n, a, ia, ja, expected_sol, rhs);
/*---------------------------------------------------------------------------*/
/* Initialize the initial guess                                              */
/*---------------------------------------------------------------------------*/
for(i=0;i<n;i++) solution[i]=1.E0;
/*---------------------------------------------------------------------------*/
/* Initialize the solver                                                     */
/*---------------------------------------------------------------------------*/
dcg_init(&n,solution,rhs,&rci_request,ipar,dpar,tmp);
if (rci_request!=0) goto failure;
/*---------------------------------------------------------------------------*/
/* Set the desired parameters:                                               */
/* LOGICAL parameters:                                                       */
/* do residual stopping test                                                 */
/* do not request for the user defined stopping test                         */
/* DOUBLE parameters                                                         */
/* set the relative tolerance to 1.0D-5 instead of default value 1.0D-6      */
/*---------------------------------------------------------------------------*/
ipar[8]=1;
ipar[9]=0;
dpar[0]=1.E-5;
/*---------------------------------------------------------------------------*/
/* Check the correctness and consistency of the newly set parameters         */
/*---------------------------------------------------------------------------*/
dcg_check(&n,solution,rhs,&rci_request,ipar,dpar,tmp);
if (rci_request!=0) goto failure;
/*---------------------------------------------------------------------------*/
/* Compute the solution by RCI (P)CG solver without preconditioning          */
/* Reverse Communications starts here                                        */
/*---------------------------------------------------------------------------*/
rci: dcg(&n,solution,rhs,&rci_request,ipar,dpar,tmp);
/*---------------------------------------------------------------------------*/
/* If rci_request=0, then the solution was found with the required precision */
/*---------------------------------------------------------------------------*/
if (rci_request==0) goto getsln;
/*---------------------------------------------------------------------------*/
/* If rci_request=1, then compute the vector A*tmp[0]                 */
/* and put the result in vector tmp[n]                                       */
/*---------------------------------------------------------------------------*/
if (rci_request==1)
{
	          mkl_dcsrsymv(&tr, &n, a, ia, ja, tmp, &tmp[n]);
	          goto rci;
}
/*---------------------------------------------------------------------------*/
/* If rci_request=anything else, then dcg subroutine failed                  */
/* to compute the solution vector: solution[n]                               */
/*---------------------------------------------------------------------------*/
goto failure;
/*---------------------------------------------------------------------------*/
/* Reverse Communication ends here                                           */
/* Get the current iteration number into itercount                           */
/*---------------------------------------------------------------------------*/
getsln: dcg_get(&n,solution,rhs,&rci_request,ipar,dpar,tmp,&itercount);
/*---------------------------------------------------------------------------*/
/* Print solution vector: solution[n] and number of iterations: itercount    */
/*---------------------------------------------------------------------------*/
printf("The system has been solved\n");
printf("The following solution obtained\n");
for (i=0;i<n/2;i++) printf("%6.3f  ",solution[i]);
printf("\n");
for (i=n/2;i<n;i++) printf("%6.3f  ",solution[i]);
printf("\nExpected solution is\n");
for (i=0;i<n/2;i++)
  {
    printf("%6.3f  ",expected_sol[i]);
    expected_sol[i]-=solution[i];
  }
       	printf("\n");
	       for (i=n/2;i<n;i++)
  {
    printf("%6.3f  ",expected_sol[i]);
    expected_sol[i]-=solution[i];
  }
	        printf("\nNumber of iterations: %d\n",itercount);
  i=1;
  euclidean_norm=dnrm2(&n,expected_sol,&i);
  if (itercount==expected_itercount && euclidean_norm<1.0e-12)
  {
    printf("This example has successfully PASSED through all steps of computation!\n");
    return 0;
  }
  else
  {
    printf("This example may have FAILED as either the number of iterations differs\n");
    printf("from the expected number of iterations %d, or the computed solution\n", expected_itercount);
    printf("differs much from the expected solution (Euclidean norm is %e), or both.\n", euclidean_norm);
    return 1;
  }
failure: printf("This example FAILED as the solver has returned the ERROR code %d", rci_request);
        return 1;
}
