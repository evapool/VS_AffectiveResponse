
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
from sklearn.model_selection import cross_validate, train_test_split, LeaveOneGroupOut
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from datetime import timedelta

homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils
import Get_FDS

#subj = str(sys.argv[1])
#task = str(sys.argv[2])
#model = str(sys.argv[3])

#subj = '01'
task = 'hedonic'
model = 'MVPA-04'

repeater = 100+1 #100 #200 perms count + 1
# upper bound is the number of sample in the training set


#train_ds = Get_FDS.get_train(model, task)
#test_ds = Get_FDS.get_test(model, task)
#fds = Get_FDS.get_full(model, task)

#train_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/train_ds'
#train_ds = h5load(train_file)

#test_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/test_ds'
#test_ds = h5load(test_file)

full_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/full_ds'
fds = h5load(full_file)


#load_file =  homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
#ds = h5load(load_file)


res = []

start_time = time.time()

for n in range(1,repeater):

    print 'doing repetition', n
    balancer  = Balancer(attr='targets',count=1,apply_selection=True)
    partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
    
    fds = list(partitioner.generate(fds))
    fds = fds[0]
    groups = fds.chunks
    X = fds.samples
    y = fds.targets
    cv=LeaveOneGroupOut().split(X, y, groups)

    # enumerate splits
    #for train, test in LeaveOneGroupOut().split(X, y, groups):
        #print('train: %s, test: %s' % (train, test))


    # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.

    pca = PCA(copy=True, iterated_power='auto', n_components=11, random_state=None,
    svd_solver='auto', tol=0.0, whiten=False)

    svm = SVC(C=10, cache_size=200, class_weight=None, coef0=0.0,
    decision_function_shape='ovr', degree=3, gamma=0.001, kernel='rbf',
    max_iter=-1, probability=False, random_state=None, shrinking=True,
    tol=0.001, verbose=False)

    pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])


    cv_res = cross_validate(pipe, X, y, 
                        cv=cv, 
                        scoring='accuracy',
                        verbose=1,
                        n_jobs=10)
    

    acc = np.average(cv_res['test_score'])
    print 'Average accuracy:', acc

    resX = cv_res['test_score']
    
    if len(resX) == 1:
        res = resX
    else:
        res = np.concatenate((res,resX), axis=0)
    

    print 'finished repetition', n
    elapsed = time.time() - start_time
    print 'it took ' + str(timedelta(seconds=elapsed))

    CV = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/cv_IND.tsv'
    np.savetxt(CV, res, delimiter='\t', fmt='%f')  

