#!/bin/bash --login 
# test plink slurm job scipt
#SBATCH --job-name=plink_job-packing
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:30:00
#SBATCH --partition=workq

# Load the environment module
# leave in, it list the environment loaded by the modules
module load plink/1.07

exec=plink

###############################################
#  Define local variable associated with this job
#
tctx=TCTX_1
start_segment=0
DATA_DIR=${SLURM_SUBMIT_DIR}/plink-data
JOBID=$SLURM_JOBID


###############################################
# Creates a unique directory in your GROUP directory 
# for the results of this job
RESULTS=$MYGROUP/bio_results/test_${exec}/${JOBID}

if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
echo the results directory is $RESULTS

###############################################

for segment in $(seq ${start_segment} 55)
#for ((i=0;i<=upper_for1;i=i+50000));
do 

###############################################
# Creates a unique directory in the SCRATCH directory 
# for this job to run in.

SCRATCH=/$MYSCRATCH/run_plink/${JOBID}/${segment}

if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH  
fi
echo SCRATCH is $SCRATCH

###############################################
# Change to the Current Directory
cd $SLURM_SUBMIT_DIR

###############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH


cp -r $DATA_DIR/lng_genome $SCRATCH/.
cp $DATA_DIR/Namefiles.txt $SCRATCH/.
cp $DATA_DIR/TCTX_Full_SansNonPosB.txt $SCRATCH/.
cp $DATA_DIR/3093_TCTX.txt $SCRATCH/.
cp $DATA_DIR/${tctx}/TCTX_ENO2_Reg_Split_$segment.txt $SCRATCH/.

cd $SCRATCH

# Tell me the Start Time
echo Start time is `date`
start="$(date +%s)"

#############################################
# Run the Program
srun --exclusive -n 1  plink --noweb --assoc --bfile  lng_genome/lng_genome --pheno TCTX_ENO2_Reg_Split_$segment.txt --all-pheno  --out TCTX_${segment}_out &

stop="$(date +%s)" 
finish=$(( $stop-$start )) 

echo $exec_script, ${JOBID} , $finish   

#############################################
#    copy segment subdirectory to the unique results dir
# note this can be a copy or move  

cp -r ../${segment} ${RESULTS}/.


#############################################
# collect run times for each individual analysis 
echo `date`  $exec, $segment , ${JOBID}, ${INDEX} , $finish seconds >> $MYGROUP/bio_results/test_${exec}/time.out  

done # end of loop
wait # syncs all the cores

#############################################
# CLEAN UP SCRATCH!!
rm -r ${MYSCRATCH}/run_plink/${JOBID}

echo run_plink finished on `hostname` at `date`. 
