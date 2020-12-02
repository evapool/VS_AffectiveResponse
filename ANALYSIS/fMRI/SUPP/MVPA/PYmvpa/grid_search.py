
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

subj = '02'
task = 'hedonic'
model = 'MVPA-04'

boot = 100+1#200 perms count + 1



print 'working on subject:', subj
#fds = Get_FDS.get_ind(subj, model, task)
fds_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
fds = h5load(fds_file)


# featRed = PCAMapper(output_dim=nPCA)
# clf = LinearCSVMC()
# meta_clf = MappedClassifier(clf, featRed)
# cv = CrossValidation(meta_clf, balancer, errorfx=lambda p, t: np.mean(p == t), enable_ca=['stats'])

# res = cv(fds)
# print(np.average(cv_results['test_score']))

partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')


res = []

for i in range(1,boot):

    print 'Boot:', i

    fds = list(partitioner.generate(fds))
    fds = fds[0]
    groups = fds.chunks
    X = fds.samples
    y = fds.targets
    cv=LeaveOneGroupOut().split(X, y, groups)


    # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.
    pca = PCA(copy=True, iterated_power='auto', n_components=11, random_state=None,
    svd_solver='auto', tol=0.0, whiten=False)

    svm = SVC(C=10, cache_size=200, class_weight=None, coef0=0.0,
    decision_function_shape='ovr', degree=3, gamma=0.001, kernel='rbf',
    max_iter=-1, probability=False, random_state=None, shrinking=True,
    tol=0.001, verbose=False)


    pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])

    cv_res = cross_validate(pipe, X, y, cv=cv, scoring='accuracy')

    acc = np.average(cv_res['test_score'])
    print 'Average accuracy:', acc

    resX = cv_res['test_score']
    
    if len(resX) == 1:
        res = resX
    else:
        res = np.concatenate((res,resX), axis=0)


    CV = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/acc.tsv'
    np.savetxt(CV, res, delimiter='\t', fmt='%f')  

#array([0.33150734, 0.08022311, 0.03531764])


#cross validate using NFoldPartioner - which makes cross validation folds by chunk/run
#if model == 'MVPA-01':
#cv = CrossValidation(clf, balancer, errorfx=lambda p, t: np.mean(p == t))

# bestPCA = []
# bestC = []
# bestG = []
# bestK = []
# bestAccTr = []
# bestAccTe = []
# bestStdTe = []

# start_time = time.time()

# for n in range(1,repeater):

#     print 'doing repetition', n
#     balancer  = Balancer(attr='targets',count=1,apply_selection=True)
#     partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
#     ds = list(partitioner.generate(train_ds))
#     ds = ds[0]
#     groups = ds.chunks
#     X_train = ds.samples
#     y_train = ds.targets
#     cv=LeaveOneGroupOut().split(X_train, y_train, groups)

#     X_test = test_ds.samples
#     y_test = test_ds.targets
#     groupsT = ds.chunks


#     # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.
#     pca = PCA()
#     #svm = LinearSVC()
#     svm = SVC()
#     pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])


#     # Parameters of pipelines can be set using separated parameter names
#     param_grid = {
#         'PCA__n_components': np.linspace(2, maxPCA, rangeX, dtype= int), 
#         'SVM__C': [0.01, 0.1, 1, 5, 10], 
#         'SVM__gamma': [0.0001, 0.001, 0.005],
#         'SVM__kernel': ['rbf', 'poly', 'sigmoid'] #[0.1, 0.5, 1, 5, 10],
#     }

#     grid = GridSearchCV(pipe, 
#                         param_grid, 
#                         cv=cv,
#                         refit=True,
#                         scoring='accuracy',
#                         verbose=1,
#                         n_jobs=10)

#     grid.fit(X_train,y_train)
#     print(grid.best_estimator_)



#     optimised_clf = grid.best_estimator_



#     grid_predictions = optimised_clf.predict(X_test)
#     print(confusion_matrix(y_test,grid_predictions))
#     print(classification_report(y_test,grid_predictions))

#     dict0 = grid.best_params_
    
#     nPCA = dict0.get('PCA__n_components')
#     print 'best PCA component', nPCA
    
#     nC = dict0.get('SVM__C')
#     print 'best SCM C regulator', nC
    
#     nG = dict0.get('SVM__gamma')
#     print 'best SCM Gamma', nG

#     nK = dict0.get('SVM__kernel')
#     print 'best SCM Kernel', nK

#     bestPCA.append(nPCA)
#     bestC.append(nC)
#     bestG.append(nG)
#     bestK.append(nK)

#     bAcTr = grid.best_score_
#     bAcTe = grid_predictions.mean()
#     print 'best Accuracy in test', bAcTe

#     #bSdTe = grid_predictions.std()

#     bestAccTr.append(bAcTr)
#     bestAccTe.append(bAcTe)
#     #bestStdTe.append(bSdTe)


#     bPCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestPCA.tsv'
#     np.savetxt(bPCA, bestPCA, delimiter='\t', fmt='%d')  

#     bC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegC.tsv'
#     np.savetxt(bC, bestC, delimiter='\t', fmt='%d')  

#     bG = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegG.tsv'
#     np.savetxt(bG, bestG, delimiter='\t', fmt='%f')  

#     bK = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegK.tsv'
#     np.savetxt(bK, bestK, delimiter='\t', fmt='%f')  

#     AccTr = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/AccTrain.tsv'
#     np.savetxt(AccTr, bestAccTr, delimiter='\t', fmt='%f')  

#     AccTe = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/AccTest.tsv'
#     np.savetxt(AccTe, bestAccTe, delimiter='\t', fmt='%f')   

#     print 'finished repetition', n
#     elapsed = time.time() - start_time
#     print 'it took ' + str(timedelta(seconds=elapsed))

