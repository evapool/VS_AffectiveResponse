#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: logancross

modified by eva on May 13 2019
"""

import sys
# this is just for my own machine
sys.path.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/") 


from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils_pav


ana_name  = 'MVPA-07'
homedir = '/Users/evapool/mountpoint/'

#add utils to path
sys.path.insert(0, homedir+'ANALYSIS/mvpa_scripts/PYmvpa')

###SCRIPT ARGUMENTS

subj = '01'

runs2use = 2

#which ds to use and which mask to use

glm_ds_file = homedir+'DATA/brain/MODELS/RSA/MVPA-07/sub-'+subj+'/glm/beta_everytrial_pav/tstat_all_trials_4D.nii'
mask_name = homedir+'DATA/brain/CANONICALS/averaged_T1w_mask.nii'

#customize how trials should be labeled as classes for classifier
#timing files 1
class_dict = {
		'csm' : 0,
		'cs_deval' : 1,
		'cs_val' : 1,
	}

#timing files 2
class_dict02 = {
		'csm' : 0,
		'cs_deval_L' : 1,
        'cs_deval_R' : 1,
		'cs_val_L' : 1,
        'cs_val_R' : 1,
	}

class_dict03 = {
		'csm' : 0,
		'csp' : 1,
	}

class_dict07 = {
		'cs_sweet_L' : 0,
		'cs_sweet_R' : 0,
      'cs_salty_L':1,
      'cs_salty_R':1,      
	}

class_dict08 = {
		'cs_sweet_L' : 1,
		'cs_sweet_R' : 0,
      'cs_salty_L':1,
      'cs_salty_R':0,      
	}



###SCRIPT ARGUMENTS END

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds1 = mvpa_utils_pav.make_targets05(subj, glm_ds_file, mask_name, runs2use, class_dict08, homedir, ana_name)

fds2 = mvpa_utils_pav.make_targets05(subj, glm_ds_file, mask_name, runs2use, class_dict07, homedir, ana_name)


#basic preproc: detrending [likely not necessary since we work with HRF in GLM]
detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
detrended_fds = fds.get_mapped(detrender)

#basic preproc: zscoring (this is critical given the design of the experiment)
zscore(detrended_fds)
fds_z = detrended_fds


#print fds.a.mapper
#pring fds_z.a.mapper


#use a balancer to make a balanced dataset of even amounts of samples in each class
balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')

#SVM classifier
clf = LinearCSVMC()
#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
cv = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))

cv = CrossValidation(clf, NFoldPartitioner(), errorfx=lambda p, t: np.mean(p == t))


#implement full brain searchlight with spheres with a radius of 3
svm_sl = sphere_searchlight(cv, radius=3, space='voxel_indices',
                             postproc=mean_sample())

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]
    
res_sl = svm_sl(fds) 

#reverse map scores back into nifti format and save
scores_per_voxel = res_sl.samples
vector_file = homedir+'DATA/brain/MODELS/RSA/'+ana_name+'/sub-'+subj+'/mvpa/svm_cs+_cs-'
h5save(vector_file,scores_per_voxel)
nimg = map2nifti(fds, scores_per_voxel)
nii_file = vector_file+'.nii.gz'
nimg.to_filename(nii_file)

