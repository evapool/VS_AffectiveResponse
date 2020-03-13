#!/bin/bash
home=$(eval echo ~$user)

#small function to move and copy files

for subjID in 02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
  do
  #for taskID in hedonic PIT
    #do
  #mkdir ${home}/REWOD/SOURCEDATA/behav/${subj}
  #mv ${home}/REWOD/SOURCEDATA/physio/s${subj}* ${home}/REWOD/SOURCEDATA/physio/${subj}/
  #cp ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-second/func/sub-${subj}_task-PIT_run-01_smoothBold.nii /home/cisa/REWOD/DERIVATIVES/ANALYSIS/CONN/func_PIT/
  #mkdir /home/cisa/REWOD/DERIVATIVES/ANALYSIS/CONN/1stLEVEL/sub-${subj}
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-first/behav ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-first/beh

  #new directory with final preprocesssed bold files
    #cp ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/task-${taskID}.ica/filtered_func_data_clean_unwarped_Coreg.nii.gz ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_task-${taskID}_run-01_UnsmoothedBold.nii.gz
  gunzip ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/*UnsmoothedBold.nii.gz
  echo 'done'
  #done
done
