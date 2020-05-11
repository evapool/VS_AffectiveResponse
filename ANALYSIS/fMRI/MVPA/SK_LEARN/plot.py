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
import seaborn as sns
import numpy as np
import pandas as pd
# import utilities  
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

#acc_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_acc.tsv'
#PCA_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_PCA.tsv'
#C_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_C.tsv'
#G_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_G.tsv'
#K_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_K.tsv'
#base = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/base_acc.csv'

acc_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_acc.tsv'
PCA_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_PCA.tsv'
C_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_C.tsv'
G_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_G.tsv'
K_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_K.tsv'
base_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/base_acc.tsv'

PCA = np.genfromtxt(PCA_file, delimiter='\t', dtype='str')
C = np.genfromtxt(C_file, delimiter='\t', dtype='str')
G = np.genfromtxt(G_file, delimiter='\t', dtype='str')
K = np.genfromtxt(K_file, delimiter='\t', dtype='str')

acc = np.genfromtxt(acc_file, delimiter='\t')
base = np.genfromtxt(base_file, delimiter='\t')


df = pd.DataFrame({"PCA": PCA,"C": C, "G": G, "K": K})

# print the figure with the results of the cross validation
print 'making plot for {}'.format('hyperparameters')
fig = plt.figure()
sns.set_style('darkgrid')

#label1 = 'PCA'
#sns.distplot(PCA, bins=20,label= label1)
#plt.vlines(np.average(base), 0,25, linestyles='solid')

sns.catplot(x='PCA', kind="count", data=df)
PCAname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_olf_PCA.png'
plt.savefig(PCAname)


sns.catplot(x='C', kind="count", data=df)
Cname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_olf_C.png'
plt.savefig(Cname)


sns.catplot(x='G', kind="count", data=df)
Gname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_olf_G.png'
plt.savefig(Gname)


sns.catplot(x='K', kind="count", data=df)
Kname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_olf_K.png'
plt.savefig(Kname)


#________  figure with the results of the cross validation
fig = plt.figure()
sns.set_style('darkgrid')

label1 = 'Grid Search Test Accuracy (Olfactory Cortex)'
sns.distplot(acc, bins=10,label= label1)
sns.distplot(base, bins=10,label='Baseline')
plt.vlines(np.average(acc), 0,25, linestyles='solid')
plt.vlines(np.average(base), 0,25, linestyles='dashed')
plt.legend()
ACCname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_olf_olf_acc.png'
plt.savefig(ACCname)



