#!/bin/bash --login
#SBATCH --job-name=copy_ftp
#SBATCH --partition=copyq
#SBATCH --ntasks=1
#SBATCH --cluster=zeus
#SBATCH --time=02:00:00
#SBATCH --export=NONE

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

DATA_FILE=bcsstk30.mtx.gz
DATA_DEST=$MYGROUP/Harwell_Boeing_Matrix_ftp/

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $DATA_DEST ]; then 
    mkdir -p $DATA_DEST 
fi
echo the results directory is $DATA_DEST

#################################################

cd ${DATA_DEST}

#############################################
#   Copy $DATA_FILE files to $DATA_DEST
#   then change directory to $DATA_DEST
ftp ftp://math.nist.gov/pub/MatrixMarket2/Harwell-Boeing/bcsstruc5/bcsstk30.mtx.gz

cd $HOME

echo copyq_wget job finished at  `date`



