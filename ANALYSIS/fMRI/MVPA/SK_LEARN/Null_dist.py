
#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: created by David on June 13 2020
"""
def warn(*args, **kwargs):
    pass
import warnings, sys, os, time
warnings.warn = warn
import matplotlib; matplotlib.use('agg') #for server
import matplotlib.pyplot as plt
import seaborn as sns
from mvpa2.suite import *
import pandas as pd  
import numpy as np  
from sklearn.svm import LinearSVC, SVC
from sklearn.metrics import classification_report, confusion_matrix  
#hyperparmeter
from sklearn.model_selection import GridSearchCV, train_test_split, LeaveOneGroupOut, cross_validate, PredefinedSplit
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from datetime import timedelta
from scipy.stats import mode

homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils
import Get_FDS


subj = str(sys.argv[1])
task = str(sys.argv[2])
model = str(sys.argv[3])

#task = 'hedonic'
#model = 'MVPA-05'

repeater = 200+1 #100 #200 perms count + 1
scaler = StandardScaler()

#tuned hyperparameters from gridsearch
if  model == 'MVPA-04':
    nPCA = 612
    G = 0.001
    C = 0.001 
    kernel = 'rbf'

if  model == 'MVPA-05':
    nPCA = 133 
    G = 0.001
    C = 0.001 
    kernel = 'rbf'

ACC_NULL = []

#full participants list
sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']

for n in range(1,repeater):
#for i in range(0,len(sub_list)):

    start_time = time.time()

    print ''
    print '------ doing rep ', n

    [train_ds, test_ds] = Get_FDS.get_rand(sub_list, model, task) 


    y_train = train_ds.targets 

    y_test = test_ds.targets 

    random.shuffle(y_train) # shuffling the training labels at random !!

    y = np.concatenate((y_train, y_test), axis =0)

    ds = vstack([train_ds, test_ds])

    X = ds.samples

    ps = PredefinedSplit(ds.chunks) # to choose manually the split
    ps.get_n_splits() #split the data set intro train and test (or CV)
    #for train_index, test_index in ps.split():
        #print("TRAIN:", train_index, "TEST:", test_index)


    # Fit on training set only.
    scaler.fit(X)

    # Apply transform to both the training set and the test set. (Here we scale for the group !)
    X = scaler.transform(X)
    #X_test = scaler.transform(X_test)

    # Fixed components from the gridsearch
    pca = PCA(n_components = nPCA)

    pca.fit(X)

    X = pca.transform(X)

    #classifier
    svm = SVC(C = C, gamma = G, kernel = kernel)


    #it not really a cross validation since there is only one training set, I was just lazy
    res = cross_validate(svm, X, y, cv=ps, scoring='accuracy', verbose=1, n_jobs=10) 
    acc_null = np.average(res['test_score'])
    print 'Average test accuracy in NULL:', acc_null


    ACC_NULL.append(acc_null)


    null = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/null_acc.tsv'  #subj or group
    np.savetxt(null, ACC_NULL, delimiter='\t', fmt='%f')  

    #print 'finished repetition', n
    elapsed = time.time() - start_time
    print 'it took ' + str(timedelta(seconds=elapsed))






