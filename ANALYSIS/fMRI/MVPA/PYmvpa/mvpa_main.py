#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019
@author: logancross
modified by david munoz on May 13 2020
"""

import sys
# this is just for my own machine
#sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/") 
import os

from mvpa2.suite import *
#from pymvpaw import * ??
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils


homedir = os.path.expanduser('~/REWOD/')

#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/PYmvpa')
#os.path.join(path, "CODE/ANALYSIS/fMRI/PYmvpa")

###SCRIPT ARGUMENTS

subj = '01'
task = 'hedonic'
model = 'MVPA-01'

runs2use = 1 ##??

#which ds to use and which mask to use

glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
mask_name = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/anat/sub-'+subj+'_ses-second_run-01_T1w_reoriented_brain_mask.nii'

#customize how trials should be labeled as classes for classifier
#timing files 1
class_dict = {
		'empty' : 0,
		'chocolate' : 1,
        'neutral' : 2,  #watcha
	}

#timing files 2


# class_dict02 = {
# 		'csm' : 0,
# 		'cs_deval_L' : 1,
#         'cs_deval_R' : 1,
# 		'cs_val_L' : 1,
#         'cs_val_R' : 1,
# 	}

# class_dict03 = {
# 		'csm' : 0,
# 		'csp' : 1,
# 	}

# class_dict07 = {
# 		'cs_sweet_L' : 0,
# 		'cs_sweet_R' : 0,
#       'cs_salty_L':1,
#       'cs_salty_R':1,      
# 	}

# class_dict08 = {
# 		'cs_sweet_L' : 1,
# 		'cs_sweet_R' : 0,
#       'cs_salty_L':1,
#       'cs_salty_R':0,      
# 	}



###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task)
##WHATCHA was fds 1
#fds2 = mvpa_utils_pav.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict07, homedir, model)


#basic preproc: detrending [likely not necessary since we work with HRF in GLM]
detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
detrended_fds = fds.get_mapped(detrender)

#basic preproc: zscoring (this is critical given the design of the experiment)
zscore(detrended_fds)
fds_z = detrended_fds


#print fds.a.mapper
#pring fds_z.a.mapper


#use a balancer to make a balanced dataset of even amounts of samples in each class
#balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
##WHATCHA

#SVM classifier
clf = LinearCSVMC()

#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
#cv = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))

cv = CrossValidation(clf, NFoldPartitioner(), errorfx=lambda p, t: np.mean(p == t))
#no balance!

#implement full brain searchlight with spheres with a radius of 3
svm_sl = sphere_searchlight(cv, radius=3, space='voxel_indices',postproc=mean_sample())

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]
    
res_sl = svm_sl(fds) 

#reverse map scores back into nifti format and save
scores_per_voxel = res_sl.samples
#vector_file = homedir+'DATA/brain/MODELS/RSA/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell'
vector_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell'
h5save(vector_file,scores_per_voxel)
nimg = map2nifti(fds, scores_per_voxel)
nii_file = vector_file+'.nii.gz'
nimg.to_filename(nii_file)

