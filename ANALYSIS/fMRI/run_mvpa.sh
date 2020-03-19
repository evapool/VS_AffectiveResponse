#!/bin/bash
home=$(eval echo ~$user)

codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/MVPA/PYmvpa"
taskID="hedonic"
model="MVPA-01"

#MVPA_script="mvpa_second.py"
#MVPA_script="mvpa_smooth.py"
MVPA_script="mvpa_calc.py"

pythonSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/mvpa_oneSubj.sh"

# Loop over subjects
 for subjectID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26 # 
    do
			qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=08:40:00,pmem=8GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ${model}_s${subjectID}_${taskID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${pythonSubmit}
            #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=4:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N ${GLM}_s${subj}_${task} -F "${subj} ${codeDir} ${matlab_script}" 
done
