#!/bin/bash --login
#SBATCH --job-name=GE-hello_mpi_c_gnu
#SBATCH --partition=workq
#SBATCH --account=interns2016
#SBATCH --nodes=2
#SBATCH --time=00:10:00

# to load the gcc module compiler
module load gcc

# load the necessary modules
module load mpt

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_mpi_gnu
SCRATCH=$MYSCRATCH/run_hello_mpi_c_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/hello_mpi_c_gnu_results_zeus/$SLURM_JOBID

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
echo SCRATCH is $SCRATCH

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
echo the results directory is $RESULTS

################################################
# declare the name of the output file or log file
OUTPUT=hello_mpi_c_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH

srun -n 32 -N 2 --mpi=pmi2 ./$EXECUTABLE >> ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo hello_mpi_c_gnu job finished at  `date`



