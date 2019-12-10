#!/bin/bash

codeDir="/home/eva/tests_eva/ANALYSIS/spm_scripts/GLM/"
matlab_script="GLM_04g_ndLevel"
matlabSubmit="/home/eva/tests_eva/ANALYSIS/spm_scripts/matlab_oneScript.sh"

qsub -o ~/ClusterOutput -j oe -l walltime=1:00:00,pmem=2GB -M evapool@unige.ch -m e -q queue1 -N GLM-04g_ttests-${subj} -F " ${codeDir} ${matlab_script}" ${matlabSubmit}
#qsub -o ~/ClusterOutput -j oe -l walltime=2:00:00,pmem=4GB -M eva.pool@unige.ch -m e -q queue1 -N GLM-03i_sub-${subj} -F "${subj} ${codeDir} ${matlab_script}" ${matlabSubmit}
