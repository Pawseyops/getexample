#!/bin/bash --login
# Request 12 cores [--ntasks=2 and --cpus-per-task=6]
# Note that --ntasks is specified, not --nodes.

#SBATCH --job-name=GE-helloOmpC_gnu_zythos
#SBATCH --partition=zythos
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=6
#SBATCH --time=00:10:00
#SBATCH --account=pawsey0001

# Default loaded compiler module is gcc module.
# To compile with GNU compiler, load the gcc module in case.
module load gcc

# Load the other necessay modules
module load mpt

# leave in, it lists the environment loaded by the modules
module list
 
#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

EXECUTABLE=hello_omp_gnu
SCRATCH=$MYSCRATCH/run_helloOmpC_gnu_zythos/$SLURM_JOBID
RESULTS=$MYGROUP/helloOmpC_gnu_zythos_results/$SLURM_JOBID

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

OUTPUT=helloOmpC_gnu_zythos.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export OMP_NUM_THREADS=12
omplace -nt $OMP_NUM_THREADS ./$EXECUTABLE >> ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  

mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo helloOmpC_gnu_zythos job finished at  `date`



