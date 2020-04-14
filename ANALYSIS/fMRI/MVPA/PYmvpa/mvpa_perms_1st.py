#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri May  3 14:07:51 2019

@author: logancross
modified by david on May 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings, sys, os, time
warnings.warn = warn

from mvpa2.suite import *
from pymvpaw import *
from mvpa2.measures.searchlight import sphere_searchlight
from mvpa2.datasets.miscfx import remove_invariant_features
# import utilities
homedir = os.path.expanduser('~/REWOD/')
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils
import Get_FDS

###radius 2## 6 min per perm ~10h for 100


#PERMUTATION TESTING PROCEDURE PERFORMED AS DESCRIBED AS IN STELZER
#https://www.sciencedirect.com/science/article/pii/S1053811912009810?via%3Dihub#bb0035
#FIRST LEVEL PERMUTATIONS FOR A SINGLE SUBJECT PERFORMED HERE

# ---------------------------- Script arguments
#subj = str(sys.argv[1])
subj = '01'

#task = str(sys.argv[2])
task = 'hedonic'

#model = str(sys.argv[3])
model = 'MVPA-01'
runs2use = 1 ##??

#number of permutations to run
num_perms = 2#00

print 'subject id: ', subj
print 'number of perms: ', num_perms


# ---------------------------- define targets, classifier and searchlight

fds = Get_FDS.get_ind(subj, model, task)

#use a balancer to make a balanced dataset of even amounts of samples in each class
balancer = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')

#SVM classifier
clf = LinearCSVMC(C=1)  #Regulator

# ---------------------------- Run
#PERMUTATION TESTS FOR SINGLE SUBJECT LEVEL
#CLASS LABELS ARE SHUFFLED N TIMES TO CREATE A NONPARAMETRIC NULL DISTRIBUTION
vector_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell'

perm_file = vector_file+'_nulldist.hdf5'

#searchlight
# enable progress bar
if __debug__:
    debug.active += ["SLC"]

start_time = time.time()

print 'Starting training',time.time() 


perm_sl = slClassPermTest_1Ss(fds, perm_count = num_perms, radius = 3, ###
                            clf = clf, part = balancer, status_print = 0, h5 = 1,
                            h5out = perm_file)
# else: 
#     perm_sl = slClassPermTest_1Ss(fds, perm_count = num_perms, radius = 3,
#                               clf = clf, part = NFoldPartitioner(), status_print = 0, h5 = 1,
#                               h5out = perm_file)

print 'Finished training, it took',time.time() - start_time
print 'end'