# getexample

The **getexample** tool provide users on a HPC resource with a fast and easy
way to begin using the HPC resource.  Using **getexample** a directory of a working example 
is copied to the users directory that has typically a _slurm_ script and an executable 
_README_ script.  The information in the files provide the user a working template to 
submit jobs to the resource manangement software.  The users should be able to use these
scripts to as a template that they can edit easily to run **their** jobs on the HPC resources.

## To use getexample on the Pawsey Supercomputers
To use **getexample** on the Pawsey Supercomputer is very easy!
Simple load the **getexample** environment module.

_module load getexample_

The command to run **getexample** is **getexample**!

The **getexample** command by itself will show all the different examples available that are on that system.  This is a list of directories that typically contain the executable *README* file and the *slurm* job script associated with that **getexample**.

To download an example the command is:

_getexample_ _name of example_

This will copy the directory _name of example_ to your current directory.

_cd name of example_

_ls_ will list the contents.

To run the *README* the command is:
_./README_

 

## Notes for the Pawsey Supercomputing System using SLURM 

Some useful SLURM VARIABLE associated with SBATCH
How to set the SBATCH_ACCOUNT variable from the $MYGROUP system variable local to 
the Pawsey Supercomputing Center.
#export SBATCH_ACCOUNT=`echo $MYGROUP | awk 'BEGIN{FS="/"}{print $3}'`

SLURM_SUBMIT_DIR is the directory from which the SBATCH command was run.

The slurm job scripts use some standard local variable to make the scripts
consistent regardless of the job/example type.

JOBID=$SLURM_JOBID is used to so that we future proof the examples if we 
change resource manangers and it makes the scripts easier to read for new users.

SCRATCH is the path to the directory where the job will run and it uses
the local system **MYSCRATCH** variable. Where **MYSCRATCH** is defined as
\/scratch\/_{project_id}_\/_{user}_ 

Please email colbrydi@msu.edu if you are interested in this project.

