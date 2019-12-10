#!/bin/bash

codeDir="/home/eva/tests_eva/ANALYSIS/spm_scripts/GLM"
matlab_script="GLM_04g_stLevel"
matlabSubmit="/home/eva/tests_eva/ANALYSIS/spm_scripts/matlab_oneSubj.sh"


# Loop over subjects

for subj in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	# prep for each session's data
		qsub -o ~/ClusterOutput -j oe -l walltime=2:00:00,pmem=4GB -M eva.pool@unige.ch -m e -q queue1 -N GLM-04g_sub-${subj} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}

done
