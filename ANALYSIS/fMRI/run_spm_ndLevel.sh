#!/bin/bash

#home=$(eval echo ~$user);

task="PIT"
GLM="GLM_13"

#codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/${task}"
codeDir="/home/REWOD/CODE/ANALYSIS/fMRI/${task}"
matlab_script="${GLM}_ndLevel"
#matlabSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneScript.sh"
matlabSubmit="/home/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneScript.sh" 

#qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M david.munoz@etu.unige.ch -m e -q queue1 -N ${task}_${GLM}_2ndlevel- -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
qsub -o /home/REWOD/ClusterOutput2 -j oe -l walltime=1:00:00,pmem=2GB -M eva.pool@.unige.ch -m e -q queue1 -N ${task}_${GLM}_2ndlevel- -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
