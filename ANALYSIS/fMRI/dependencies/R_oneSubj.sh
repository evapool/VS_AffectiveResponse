#!/bin/bash

echo "Bash version ${BASH_VERSION}..."

R="/usr/bin/R"

PBS_O_WORKDIR=$4

echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

NPROCS=`wc -l < $PBS_NODEFILE`

echo This job has allocated $NPROCS cpus

R_script=$5
sbj=$1
tsk=$2
mdl=$3

#PBS -N cluster_analysis_classic_preproc
$R CMD BATCH ${R_script} #--no-save #$sbj $tsk $mdl
