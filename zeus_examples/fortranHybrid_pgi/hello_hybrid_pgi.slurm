#!/bin/bash --login
#SBATCH --job-name=GE-fortranHybrid_pgi
#SBATCH --partition=workq
#SBATCH --account=interns2016
#SBATCH --nodes=2
#SBATCH --time=00:10:00

# To compile with PGI compiler, unload the gcc module
# and load the pgi module
module unload gcc
module load pgi

# Load the other necessary modules
module load mpt

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_hybrid_pgi
SCRATCH=$MYSCRATCH/run_fortranHybrid_pgi/$SLURM_JOBID
RESULTS=$MYGROUP/fortranHybrid_pgi_results_zeus/$SLURM_JOBID

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
OUTPUT=fortranHybrid_pgi.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export OMP_NUM_THREADS=16

srun --mpi=pmi2 -n 2 -N 2 ./$EXECUTABLE >> ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo fortranHybrid_pgi job finished at  `date`
