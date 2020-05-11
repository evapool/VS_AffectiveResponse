#!/bin/bash
home=$(eval echo ~$user)

codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/"
taskID="hedonic"
model="MVPA-04"

# in order
R_script="hello_R.R"  # radius2



RSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/R_oneSubj.sh"

# Loop over subjects
 for subjectID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26 # 
    do
			qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=01:40:00,pmem=8GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N R-test -F "${subjectID} ${taskID} ${model} ${codeDir} ${R_script}" ${RSubmit}
            #qsub -I -o ${home}/REWOD/ClusterOutput -j oe -l walltime=00:40:00,pmem=4GB -m n -l nodes=1 -q queue2 -N ${model}_s${subjectID}_${taskID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${RSubmit}
            #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=2:40:00,pmem=GB -M david.munoz@etu.unige.ch -m n -l nodes=1  -q queue1 -N grid_search_${subjectID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${RSubmit}
            #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=4:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N ${GLM}_s${subj}_${task} -F "${subj} ${codeDir} ${matlab_script}" mriqc ~/REWOD/ ~/REWOD/MRIQC participant
            
done
