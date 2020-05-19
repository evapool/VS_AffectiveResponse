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

if model == 'MVPA-04':
    label1 = 'Individudal Test Accuracy (Olfactory cortex)'
    name = 'olf_cort'

if model == 'MVPA-05':
    label1 = 'Individudal Test Accuracy (Nucleus Accumbens)'
    name = 'nacc'

acc_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_acc.tsv'
PCA_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_PCA.tsv'
C_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_C.tsv'
G_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_G.tsv'
K_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_K.tsv'
null_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/null_acc.tsv'

#acc_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_acc.tsv'
#PCA_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_PCA.tsv'
#C_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_C.tsv'
#G_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_G.tsv'
#K_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/grid_K.tsv'
#null_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/rep50/null_acc.tsv'

PCA = np.genfromtxt(PCA_file, delimiter='\t', dtype='str')
C = np.genfromtxt(C_file, delimiter='\t', dtype='str')
G = np.genfromtxt(G_file, delimiter='\t', dtype='str')
K = np.genfromtxt(K_file, delimiter='\t', dtype='str')

acc = np.genfromtxt(acc_file, delimiter='\t')
null = np.genfromtxt(null_file, delimiter='\t')


df = pd.DataFrame({"PCA": PCA,"C": C, "G": G, "K": K})

# print the figure with the results of the cross validation
print 'making plot for {}'.format('hyperparameters')
fig = plt.figure()
sns.set_style('darkgrid')

#label1 = 'PCA'
#sns.distplot(PCA, bins=20,label= label1)
#plt.vlines(np.average(null), 0,25, linestyles='solid')

sns.catplot(x='PCA', kind="count", data=df)
PCAname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_'+name+'_PCA.png'
plt.savefig(PCAname)


sns.catplot(x='C', kind="count", data=df)
Cname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_'+name+'_C.png'
plt.savefig(Cname)


sns.catplot(x='G', kind="count", data=df)
Gname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_'+name+'_G.png'
plt.savefig(Gname)


sns.catplot(x='K', kind="count", data=df)
Kname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_'+name+'_K.png'
plt.savefig(Kname)


#________  figure with the results of the cross validation
fig = plt.figure()
sns.set_style('darkgrid')

if model == 'MVPA-04':
    sns.distplot(acc, bins=10,label= label1)
    sns.distplot(null, kde=False, bins=7,label='null')
else:
    sns.distplot(acc, bins=15,label= label1)
    sns.distplot(null, bins=15,label='null')

plt.vlines(np.average(acc), 0,25, linestyles='solid')
plt.vlines(np.average(null), 0,25, linestyles='dashed')
plt.legend()
ACCname = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/plot_'+name+' _acc.png'
plt.savefig(ACCname)



