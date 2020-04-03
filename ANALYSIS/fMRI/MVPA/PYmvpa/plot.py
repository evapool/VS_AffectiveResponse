#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: David on June 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn


import matplotlib.pyplot as plt
# from pymvpaw import *
# from mvpa2.measures.searchlight import sphere_searchlight
# from mvpa2.datasets.miscfx import remove_invariant_features ##
# import sys
# import time
# from sh import gunzip
# from nilearn import image ## was missing this line!

import os
import sys
import seaborn as sns
import numpy as np
# import utilities Un   
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
#import mvpa_utils


#subj = str(sys.argv[1])
#subj = '01'
#task = str(sys.argv[2])
task = 'hedonic'

#model = str(sys.argv[3])
model = 'MVPA-04'

runs2use = 1 ##??

boot = 99 #00
numPCA = 29

res1 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/res_base_'+str(boot)+'_accuracy.csv'
res2 = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/res_'+str(numPCA)+'_'+str(boot)+'_accuracy.csv'


base = np.genfromtxt(res1, delimiter='\t')
PCA = np.genfromtxt(res2, delimiter='\t')

# print the figure with the results of the cross validation
print 'making plot for {}'.format('PCA & base')
fig = plt.figure()
sns.set_style('darkgrid')
labelX = 'base'
sns.distplot(base, bins=10,label= labelX)
plt.vlines(np.average(base), 0,25, linestyles='solid')

labelY = 'PCA'
sns.distplot(PCA, bins=10,label=labelY)
plt.vlines(np.average(PCA), 0,25, linestyles='dashed')
plt.legend()
# fname = homedir+'ANALYSIS/mvpa_scripts/PYmvpa/cross_decoding/crossvalidation_'+roix+'_2runs.pdf'
fname = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/plot_accuracy'+str(boot)+'.png'

plt.savefig(fname)
# proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))
# plt.close(fig)

# print the figure with the results of the cross validation
# print 'making plot for {}'.format(roix)
# fig = plt.figure()
# sns.set_style('darkgrid')
# labelX = roix+ ': t = {}, p = {}'.format(*t_nz)
# sns.distplot(res_cv1_nz, bins=10,label= labelX)
# plt.vlines(np.average(res_cv1_z), 0,10, linestyles='solid')
# labelX = roix+ ': t = {}, p = {}'.format(*t_z)
# sns.distplot(res_cv1_z, bins=10,label=' zscore ' +labelX)
# plt.vlines(np.average(res_cv1_z), 0,10, linestyles='dashed')
# plt.legend()
# fname = homedir+'ANALYSIS/mvpa_scripts/PYmvpa/cross_decoding/crossvalidation_'+roix+'_2runs.pdf'
# plt.savefig(fname)
# proc=subprocess.Popen(shlex.split('lpr {f}'.format(f=fname)))
# plt.close(fig)
