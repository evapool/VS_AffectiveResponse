#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: David on June 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings, os, sys
warnings.warn = warn

import matplotlib; matplotlib.use('agg') #for server
import matplotlib.pyplot as plt
# from pymvpaw import *
# from mvpa2.measures.searchlight import sphere_searchlight
# from mvpa2.datasets.miscfx import remove_invariant_features ##
# import sys
# import time
# from sh import gunzip
# from nilearn import image ## was missing this line!
import seaborn as sns
import numpy as np
import pandas as pd
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




PCA_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestPCA.tsv'
C_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegC.tsv'
G_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegG.tsv'
K_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegK.tsv'
#res1 = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/res_base_'+str(boot)+'_accuracy.csv'
#res2 = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/res_'+str(nPCA28)+'_'+str(boot)+'_accuracy.csv'
#res3 = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/res_'+str(nPCA29)+'_'+str(boot)+'_accuracy.csv'


PCA = np.genfromtxt(PCA_file, delimiter='\t', dtype='str')
C = np.genfromtxt(C_file, delimiter='\t', dtype='str')
G = np.genfromtxt(G_file, delimiter='\t', dtype='str')
K = np.genfromtxt(K_file, delimiter='\t', dtype='str')


df = pd.DataFrame({"PCA": PCA,"C": C, "G": G, "K": K})


# print the figure with the results of the cross validation
print 'making plot for {}'.format('hyperparameters')
fig = plt.figure()
sns.set_style('darkgrid')

#label1 = 'PCA'
#sns.distplot(PCA, bins=20,label= label1)
#plt.vlines(np.average(base), 0,25, linestyles='solid')

sns.catplot(x='PCA', kind="count", data=df)
PCAname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_PCA.png'
plt.savefig(PCAname)


sns.catplot(x='C', kind="count", data=df)
Cname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_C.png'
plt.savefig(Cname)


sns.catplot(x='G', kind="count", data=df)

Gname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_G.png'
plt.savefig(Gname)


sns.catplot(x='K', kind="count", data=df)
Kname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_K.png'
plt.savefig(Kname)

fig = plt.figure()
sns.set_style('darkgrid')

acc_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/AccTest.tsv'
acc = np.genfromtxt(acc_file, delimiter='\t')

label1 = 'Accuracy'
sns.distplot(acc, bins=10,label= label1)
plt.vlines(np.average(acc), 0,25, linestyles='solid')
ACCname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_acc.png'
plt.savefig(ACCname)

