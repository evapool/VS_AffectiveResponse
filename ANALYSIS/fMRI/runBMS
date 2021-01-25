#!/bin/bash

home=$(eval echo ~$user);

task="PIT"

codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/${task}"
#codeDir="/home/REWOD/CODE/ANALYSIS/fMRI/ForPaper/${task}"
matlab_script="BMS_${task}"
#matlabSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneScript.sh"
matlabSubmit="/home/REWOD/CODE/ANALYSIS/fMRI/dependencies/matlab_oneScript.sh" 

#qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M david.munoz@etu.unige.ch -m e -q queue1 -N ${task}_${GLM}_2ndlevel- -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
qsub -o /home/REWOD/ClusterOutput -j oe -l walltime=100:00:00,pmem=2GB -M david.munoz@etu.unige.ch -m e -q queue1 -N BMS_${task} -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
