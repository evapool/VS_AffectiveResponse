
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

repeater = 10+1 #100 #200 perms count + 1
scaler = StandardScaler()


bestPCA = []
bestC = []
bestG = []
bestK = []
ACC_IND = []


for n in range(1,repeater):

    start_time = time.time()

    print ''
    print '------ doing repetition ----- ', n

    #full participants list
    sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']

    ds = Get_FDS.get_80_20(sub_list, model, task) 
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

    # Fit on training set only.
    pca = PCA(.95)

    pca.fit(X)

    nPCA =  pca.n_components_ # minimal number of components (linear combination) that retained at 95% variance

    X = pca.transform(X)
    #X_test = pca.transform(X_test)

    # Define a pipeline to search for the best combination classifier regularization (C is the penalty
    # parameter, which represents misclassification or error term. The misclassification or error term 
    # tells the SVM optimisation how much error is bearable. This is how you can control the trade-off 
    # between decision boundary and misclassification term.) AND Gamma: It defines how far influences 
    # the calculation of plausible line of separation.
    
    # Parameters of pipelines can be set using separated parameter names
    param_grid = {'C': [0.001, 0.1,1, 10], 'gamma': [0.1,0.01,0.001],'kernel': ['rbf','linear']}

    grid = GridSearchCV(SVC(), 
                        param_grid, 
                        cv=ps,
                        refit=True,
                        scoring='accuracy',
                        verbose=1,
                        n_jobs=10)

    grid.fit(X,y)
        
    BEST = grid.best_estimator_

    cv_res = cross_validate(BEST, X, y, cv=ps, scoring='accuracy')
    acc_grid = np.average(cv_res['test_score'])
    print 'Average test accuracy in gridsearch:', acc_grid
    
    #grid_predictions = grid.predict(X_test)
    #print(confusion_matrix(y_test,grid_predictions))
    #print(classification_report(y_test,grid_predictions))
    #evaluator = grid.scorer_
    #acc_ind = evaluator(BEST, X_test, y_test)
    #print 'Average test accuracy in test:', acc_ind

    dict0 = grid.best_params_
    
    print 'best PCA component 95%', nPCA
    
    nC = dict0.get('C')
    print 'best SCM C regulator', nC


    nG = dict0.get('gamma')
    print 'best SVM gamma regulator', nG

    nK = dict0.get('kernel')
    print 'best SVM Kernel', nK

    ACC_IND.append(acc_grid)

    bestPCA.append(nPCA)
    bestC.append(nC)
    bestG.append(nG)
    bestK.append(nK)


    bPCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_PCA.tsv'
    np.savetxt(bPCA, bestPCA, delimiter='\t', fmt='%d')  

    bC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_C.tsv'
    np.savetxt(bC, bestC, delimiter='\t', fmt='%f')  

    bG = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_G.tsv'
    np.savetxt(bG, bestG, delimiter='\t', fmt='%f')  

    bK = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_K.tsv'
    np.savetxt(bK, bestK, delimiter='\t', fmt='%s') 

    ind = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/grid_acc.tsv'
    np.savetxt(ind, ACC_IND, delimiter='\t', fmt='%f')  

    print 'finished repetition', n
    elapsed = time.time() - start_time
    print 'it took ' + str(timedelta(seconds=elapsed))


#P, idx = mode(bestPCA) #590
#modePCA.append(P)
#namePCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/modePCA.tsv'
#np.savetxt(namePCA, P, delimiter='\t', fmt='%f')  

#C, idx = mode(bestC)  #0.01
#modeC.append(C)
#nameC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/modeRegC.tsv'
#np.savetxt(nameC, C, delimiter='\t', fmt='%f')  
