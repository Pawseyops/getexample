#!/bin/bash --login
# This is the README file is an executable script.
# To run type: ./README.gnu
#
# Example OBjECTIVE: to demostrate omp_hello.c example
# on Zythos with GNU compiler.
# omp_hello.f code is taken from
# https://computing.llnl.gov/tutorials/openMP/exercise.html
# This script requests 2 nodes with 6 cores and 6 threads per node.
# To run this code, we need to edit the partition, 
# load the necessary modules, specify the number of nodes, cores
# and the total number OpenMP threads.
# This information is located under hello_omp_gnu.slurm
# You can edit the SLURM as: emacs hello_omp_gnu.slurm &

# SLURM directives
# 
# Here we specify to SLURM that we want 2 nodes (--ntasks=2)
# and 6 cores in total. (--cpus-per-task=6)
# We then modify the partition to Zythos ( --partition==zythos)
# To run this code correctly, we remove --export=NONE.
# If it is still included in the SLURM, the code does not work.
# To compile with the GNU compiler, we load the gcc module as shown below:
# module load gcc
# Then we load the other necessary modules before module listing.
# module load mpt
# We also set the number of OpenMP threads to 12 as shown:
# export OMP_NUM_THREADS=12
# To run the code, we use omplace to control thread placement with 
# the default being 6 threads per node.
# Therefore, the omplace command looks like:
# omplace -nt $OMP_NUM_THREADS ./$EXECUTABLE >> ${OUTPUT}
 
# To compile the omp_hello.c code with GNU
gcc -O2 -fopenmp omp_hello.c -o hello_omp_gnu

# To submit the job to Zythos
sbatch hello_omp_gnu.slurm

echo "The sbatch command returns what jobid is for this job."
echo "To check the status of your job, use the slurm command:"
echo "squeue -u $USER"
echo "Your job is deleted from the scratch."
echo "It is now moved to your group."
echo "Your results are now located in ${MYGROUP}/hello_results_omp_zythos/"
echo "To change to your jobID directory, type:"
echo "cd ${MYGROUP}/hello_results_omp_zythos/jobID/"
echo "To view the results, use the cat command and type:"
echo "cat hello_omp_gnu.log"