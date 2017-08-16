#!/bin/bash --login
#SBATCH --job-name=e3_GE-abaqus-mpi
#SBATCH --partition=workq
#SBATCH --account=pawsey0001
#SBATCH --cpus-per-task=16
#SBATCH --nodes=2
#SBATCH --time=01:00:00
##SBATCH --output e3_abaqus-mpi.%j.out
##SBATCH --error  e3_abaqus-mpi.%j.err

# Default loaded compiler module is gcc module
# load the necessary modules to compile with GNU
module load abaqus

# leave in, it lists the environment loaded by the modules
#module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
INPUT=e3
SRC_DIR=${SLURM_SUBMIT_DIR}
EXECUTABLE=abaqus
SCRATCH=$MYSCRATCH/run_abaqus-mpi/$SLURM_JOBID
RESULTS=$MYGROUP/abaqus-mpi-results_zeus/$SLURM_JOBID
unset SLURM_GTIDS
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

OUTPUT=abaqus_${INPUT}_mpi

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cp ${INPUT}.inp $SCRATCH

cd $SCRATCH

######################################
# create the abaqus_v6.env file
envFile=abaqus_v6.env

# The number of processors/cores per node
ncpus=`echo $SLURM_CPUS_PER_TASK`
# | cut -c1-2`
echo cpu per task $SLURM_CPUS_PER_TASK 
echo "number of cores per nodes ${ncpus}"
# total number of cores
echo "total number of nodes $SLURM_NNODES"
ncores=`expr $SLURM_NNODES \* $ncpus`
echo "total number of cores is $ncores"
# file of the node lists
node_list=ABAQUS_NODES

srun hostname | sort > $node_list
echo  'the node list is $node_list'
mp_host_list="["
for i in $(cat ${node_list}) ; do
    mp_host_list="${mp_host_list}['$i', $ncpus],"
done
echo host list ${mp_host_list}
mp_host_list=`echo ${mp_host_list}  | sed -e "s/,$//"`
mp_host_list="${mp_host_list}]"

export mp_host_list
#Write the environment variables to abaqus_v6.env
echo "import os" > ${envFile}
echo "os.environ['ABA_BATCH_OVERRIDE'] = '1'" >> ${envFile}
echo "verbose=1" >> $envFile
echo "mp_host_list=${mp_host_list}" >> ${envFile}
echo "mp_mpi_implementation=PMPI" >> ${envFile}
# 

abaqus job=$OUTPUT input=$INPUT cpus=$ncores \
 standard_parallel=all mp_mode=mpi interactive 

#############################################
# move entire scratch directory to the unique results directory
# note this can be a copy or move  
mv *.dat *.abq *.m* *.odb *.res *.p* *.s* ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo abaqus-mpi job finished at  `date`
