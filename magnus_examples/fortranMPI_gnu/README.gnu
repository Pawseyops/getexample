#!/bin/bash --login
# This is the README file is an executable script.
# To run type: ./README.gnu
#
# Example OBJECTIVE: to demonstrate hello_mpi.f90 example 
# on Magnus on GNU Environment.
# hello_mpi.f90 code is taken from
# https://people.sc.fsu.edu/~jburkardt/f_src/hello_mpi/hello_mpi.f90
# hello_mpi.f90 is an MPI code that runs on 2 nodes 
# with 24 MPI tasks on each node.
# To run this code, we need to specify the total number of MPI tasks
# and the number of MPI tasks per node.
# This information is located under hello_mpi_gnu.slurm
# You can edit the SLURM as: emacs hello_mpi_gnu.slurm &

# SLURM directives
# 
# Here we specify to SLURM we want 2 nodes (--nodes=2)
# To compile hello_mpi.c with GNU, we change the compiler
# from Cray to GNU as shown below:
# module swap PrgEnv-cray PrgEnv-gnu
# To launch a job, we specify to aprun 48 MPI tasks (-n 48)
# with 24 tasks per node (-N 24)
# Therefore, the aprun command looks like:
# aprun -n 48 -N 24 ./$EXECUTABLE >> ${OUTPUT}

# To compile the hello_mpi.f90 code with GNU compiler
ftn -O2 hello_mpi.f90 -o hello_mpi_gnu

# To submit the job to Magnus
sbatch hello_mpi_gnu.slurm

echo "The sbatch command returns what jobid is for this job."
echo "To check the status of your job, use the slurm command:"
echo "squeue -u $USER"
echo "Your job is deleted from the scratch."
echo "It is now moved to your group."
echo "Your results are now located in ${MYGROUP}/hello_mpifortran_results/"
echo "To change to your jobID directory, type:"
echo "cd ${MYGROUP}/hello_mpifortran_results/jobID/"
echo "To view the results, use the cat command and type:"
echo "cat hello_mpifortran_gnu.log"