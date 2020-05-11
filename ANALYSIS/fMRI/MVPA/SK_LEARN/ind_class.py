
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


#subj = str(sys.argv[1])
#task = str(sys.argv[2])
#model = str(sys.argv[3])

task = 'hedonic'
model = 'MVPA-04'

repeater = 1+1 #100 #200 perms count + 1
scaler = StandardScaler()

#tuned hyperparameters from gridsearch
nPCA = 612
G = 0.001
C = 0.001
kernel = 'rbf'


ACC_IND = []

#full participants list
sub_list=['01'] #,'02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']

#for n in range(1,repeater):
for i in range(0,len(sub_list)):
    
    subj = sub_list[i]
    
    start_time = time.time()

    print ''
    print '------ doing subj ', subj


    ds = Get_FDS.get_ind(subj, model, task) 
    #ds_test = Get_FDS.get_conc_FDS(sub_test, model, task) 
    #load_file =  homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
    #ds = h5load(load_file)
    
    #groups = ds.chunks
    #In time series data, Kfold is not a right approach as kfold cv 
    # will shuffle you data and you will lose pattern within series. Here is an approach
    ps = PredefinedSplit(ds.chunks) # to choose manually the split
    ps.get_n_splits() #split the data set intro train and test (or CV)
    #for train_index, test_index in ps.split():
        #print("TRAIN:", train_index, "TEST:", test_index)

    X = ds.samples
    y = ds.targets
    #cvLOO=LeaveOneGroupOut().split(X, y, groups)

    #X_test = ds_test[0].samples
    #y_test = ds_test[0].targets

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
    acc_ind = np.average(res['test_score'])
    print 'Average test accuracy in gridsearch:', acc_ind
    
    #grid_predictions = grid.predict(X_test)
    #print(confusion_matrix(y_test,grid_predictions))
    #print(classification_report(y_test,grid_predictions))
    #evaluator = grid.scorer_
    #acc_ind = evaluator(BEST, X_test, y_test)
    #print 'Average test accuracy in test:', acc_ind

    ACC_IND.append(acc_ind)


    ind = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/ind_acc.tsv'  #subj or group
    np.savetxt(ind, ACC_IND, delimiter='\t', fmt='%f')  

    #print 'finished repetition', n
    elapsed = time.time() - start_time
    print 'it took ' + str(timedelta(seconds=elapsed))

 
