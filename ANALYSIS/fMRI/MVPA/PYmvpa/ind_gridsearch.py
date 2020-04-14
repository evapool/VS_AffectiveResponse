
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
from sklearn.model_selection import GridSearchCV, train_test_split, LeaveOneGroupOut, cross_validate
#from sklearn.model_selection import 
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from datetime import timedelta
from scipy.stats import mode
#from sklearn.model_selection import 

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

repeater = 20+1 #100 #200 perms count + 1
rangeX = 26  #number of different components that we want to test np.linspace(2, nSample, rangeX, dtype= int) 
maxPCA = 27 
# upper bound is the number of sample in the training set


#train_ds = Get_FDS.get_train(model, task)
#test_ds = Get_FDS.get_test(model, task)
#train_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/train_ds'
#train_ds = h5load(train_file)

#test_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/test_ds'
#test_ds = h5load(test_file)



modePCA = []
modeC = []
bestPCA = []
bestC = []



sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21'] #,'22','23','24','25','26']

for i in range(0,len(sub_list)):
    subj = sub_list[i]
    print ''
    print 'doing subj', subj  
    print ''
    load_file =  homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
    ds = h5load(load_file)

    balancer  = Balancer(attr='targets',count=1,apply_selection=True)
    partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
    ds = list(partitioner.generate(ds))
    ds = ds[0]

    start_time = time.time()
    
    for n in range(1,repeater):
        
        
        print 'doing repetition', n

        groups = ds.chunks
        X = ds.samples
        y = ds.targets
        cvLOO=LeaveOneGroupOut().split(X, y, groups)

        #X_test = test_ds.samples
        #y_test = test_ds.targets
        #groupsT = ds.chunks


        # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.
        pca = PCA()
        svm = LinearSVC()
        #svm = SVC()
        pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])



        # Parameters of pipelines can be set using separated parameter names
        param_grid = {
            'PCA__n_components': np.linspace(2, maxPCA, rangeX, dtype= int), 
            'SVM__C': [0.01, 0.1, 1, 5, 10], 
            #'SVM__gamma': [0.0001, 0.001, 0.005],
            #'SVM__kernel': ['rbf', 'sigmoid'] #[0.1, 0.5, 1, 5, 10],
        }

        grid = GridSearchCV(pipe, 
                            param_grid, 
                            cv=cvLOO,
                            refit=True,
                            scoring='accuracy',
                            verbose=1,
                            n_jobs=10)

        grid.fit(X,y)
            
        #pipeBEST = grid.best_estimator_

        #X = ds.samples
        #y = ds.targets
        #cvLOO=LeaveOneGroupOut().split(X, y, groups)

        #cv_res = cross_validate(pipeBEST, X, y, cv=cvLOO, scoring='accuracy')


        #acc = np.average(cv_res['test_score'])
        #print 'Average accuracy:', acc

        #grid_predictions = optimised_clf.predict(X_)
        #print(confusion_matrix(y_train,grid_predictions))
        #print(classification_report(y_train,grid_predictions))

        dict0 = grid.best_params_
        
        nPCA = dict0.get('PCA__n_components')
        print 'best PCA component', nPCA
        
        nC = dict0.get('SVM__C')
        print 'best SCM C regulator', nC
        
        #nG = dict0.get('SVM__gamma')
        #print 'best SCM Gamma', nG

        #nK = dict0.get('SVM__kernel')
        #print 'best SCM Kernel', nK

        bestPCA.append(nPCA)
        bestC.append(nC)



        bPCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestPCAind.tsv'
        np.savetxt(bPCA, bestPCA, delimiter='\t', fmt='%d')  

        bC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegCind.tsv'
        np.savetxt(bC, bestC, delimiter='\t', fmt='%f')  

        print 'finished repetition', n
        elapsed = time.time() - start_time
        print 'it took ' + str(timedelta(seconds=elapsed))


P, idx = mode(bestPCA)
#modePCA.append(P)
namePCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/modePCA.tsv'
np.savetxt(namePCA, P, delimiter='\t', fmt='%f')  

C, idx = mode(bestC)
#modeC.append(C)
nameC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/modeRegC.tsv'
np.savetxt(nameC, C, delimiter='\t', fmt='%f')  
