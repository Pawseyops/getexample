#!/bin/bash --login
# This is the README file is an executable script.
# To run type: ./README.gnu
#
# Example OBjECTIVE: to demostrate hello_mpi.f90 example
# on Zythos
# This code is an MPI example that requests 24 cores [--ntasks=4 and
# --cpus-per-task=6]
# Note that --ntasks is specified, not --nodes.
# MPI tasks running on each node.
# This example is taken from:
# https://people.sc.fsu.edu/~jburkardt/f_src/hello_mpi/hello_mpi.html
# To run this code, we need to edit the partition, 
# load the necessary modules
# and specify the total number of MPI tasks.
# This information is located under hello_world_mpi_gnu.slurm
# You can edit the SLURM as: emacs hello_world_mpi_gnu.slurm &

# SLURM directives
# 
# Here we specify to SLURM we want 4 natasks (--ntasks=4)
# Then, we modify the partition to --partition==zythos
# To run this code correctly on Zythos, we need to remove --export=NONE
# If it is still included in the SLURM, the code does not compile.
# To compile the code with gnu load gcc 
# We then load the necessary modules before module listing.
# module load mpt
# 
# Therefore, the mpirun command looks like:
# mpirun -np 24 ./$EXECUTABLE >> ${OUTPUT}
 
# To compile the hello_mpi.f90 code

mpif90 -fopenmp -O2 hello_mpi.f90 -o hello_mpi_gnu

# The code can also be compiled by:
# gfortran -fopenmp -O2 hello_mpi.f90 -o hello_mpi_gnu

# To submit the job to Zeus
sbatch hello_world_mpi_gnu.slurm

echo "The sbatch command returns what jobid is for this job."
echo "To check the status of your job, use the slurm command:"
echo "squeue -u $USER"
echo "Your job is deleted from the scratch."
echo "It is now moved to your group."
echo "Your results are now located in ${MYGROUP}/hello_mpi_gnu_results_zeus/"
echo "To change to your jobID directory, type:"
echo "cd ${MYGROUP}/hello_mpi_gnu_results_zeus/jobID/"
echo "To view the results, use the cat command and type:"
echo "cat hello_mpi_gnu.log"
