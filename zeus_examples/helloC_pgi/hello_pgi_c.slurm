#!/bin/bash --login
#SBATCH --job-name=GE-helloC_pgi
#SBATCH --partition=workq
#SBATCH --nodes=1
#SBATCH --time=00:05:00

# Default loaded compiler module is gcc module
# to swap from GNU compiler to PGI
module unload gcc
module load pgi


# leave in, it list the environment loaded by the modules

module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

EXECUTABLE=helloworld_pgi
SCRATCH=$MYSCRATCH/run_helloC_pgi/$SLURM_JOBID
RESULTS=$MYGROUP/helloC_pgi_results_zeus/$SLURM_JOBID

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

OUTPUT=helloC_pgi.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH

./$EXECUTABLE >> ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  

mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo helloC_pgi job finished at  `date`



