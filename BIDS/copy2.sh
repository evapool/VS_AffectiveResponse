#!/bin/bash
home=$(eval echo ~$user)

#small function to move and copy files
subjID=$1

for subjID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26
  do
  #for taskID in hedonic PIT
    #do
    mkdir -p ${home}/REWOD/BIDS/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func
    rsync -av --progress ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/* /home/davidM/REWOD/BIDS/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func --exclude derivatives
  done
  #mv ${home}/REWOD/SOURCEDATA/physio/s${subj}* ${home}/REWOD/SOURCEDATA/physio/${subj}/
  
  #gzip ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_task* 
  #rm ${home}/REWOD/sub-${subjID}/ses-second/func/*.nii.gz
  #cp ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_task-${taskID}_run-01_UnsmoothedBold.nii.gz ${home}/REWOD/sub-${subjID}/ses-second/func/sub-${subjID}_ses-second_task-${taskID}_run-01_bold.nii.gz
  #cp ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-second/func/sub-${subj}_task-taskID_run-01_smoothBold.nii /home/cisa/REWOD/DERIVATIVES/ANALYSIS/CONN/func_PIT/
  #mkdir ${home}/REWOD/DERIVATIVES/PREPROC/CONN/1stLEVEL/sub-${subj}
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-first/behav ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subj}/ses-first/beh

  #new directory with final preprocesssed bold files
  #mkdir ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/derivatives
  #gunzip ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_ses-second_task-hedonic_run-01_smoothBold.nii.gz
  #gunzip ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_ses-second_task-PIT_run-01_smoothBold.nii.gz
  #rm ${home}/REWOD/sub-${subjID}/ses-second/func/*.nii.gz
  #${home}/REWOD/SOURCEDATA/brain/bids/sub-${subjID}/ses-second/func/*.nii.gz
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_task-hedonic_run-01_UnsmoothedBold.nii.gz ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_ses-second_task-hedonic_run-01_Bold.nii.gz
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_task-PIT_run-01_UnsmoothedBold.nii.gz ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/sub-${subjID}_ses-second_task-PIT_run-01_Bold.nii.gz
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/ICA*  ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/derivatives/
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/task*  ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/derivatives/
  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/*.tsv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/clean/

  #mv ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/*.mat ${home}/REWOD/DERIVATIVES/PREPROC/sub-${subjID}/ses-second/func/clean/
  #cd ${home}/REWOD/DERIVATIVES/ANALYSIS/MVPA/hedonic/MVPA-04/sub-${subjID}/mvpa/
  #fslstats svm_smell_nosmell_smoothed.nii -m -M
  #echo 'done'
    #done
 #done
