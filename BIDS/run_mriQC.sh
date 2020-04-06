#!/bin/bash
home=$(eval echo ~$user)

QCScript=${home}/REWOD/CODE/BIDS/mriQC.sh


qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:00:00,pmem=16GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N MriQc  ${QCScript}

