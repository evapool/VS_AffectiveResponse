#!/bin/bash
home=$(eval echo ~$user)


subjID=$1


cd ${home}/REWOD/DERIVATIVES/MRIQC/

mriqc ~/REWOD/ ~/REWOD/DERIVATIVES/MRIQC participant --participant-label ${subjID} -m bold
#mriqc ~/OBIWAN/DATA/STUDY/SOURCEDATA/ ~/OBIWAN/DATA/STUDY/SOURCEDATA/QualityCheck participant #--participant-label control100