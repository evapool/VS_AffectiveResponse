
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
from sklearn.model_selection import GridSearchCV, train_test_split, LeaveOneGroupOut
#from sklearn.model_selection import 
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from datetime import timedelta
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

repeater = 100+1 #100 #200 perms count + 1
rangeX = 35  #number of different components that we want to test np.linspace(2, nSample, rangeX, dtype= int) 
maxPCA = 36 
# upper bound is the number of sample in the training set


#train_ds = Get_FDS.get_train(model, task)
#test_ds = Get_FDS.get_test(model, task)
train_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/train_ds'
train_ds = h5load(train_file)

test_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/test_ds'
test_ds = h5load(test_file)

#load_file =  homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
#ds = h5load(load_file)

bestPCA = []
bestC = []
bestG = []
bestK = []
bestAccTr = []
bestAccTe = []
bestStdTe = []

start_time = time.time()

for n in range(1,repeater):

    print 'doing repetition', n
    balancer  = Balancer(attr='targets',count=1,apply_selection=True)
    partitioner = ChainNode([NFoldPartitioner(),Balancer(attr='targets',count=1,limit='partitions',apply_selection=True)],space='partitions')
    ds = list(partitioner.generate(train_ds))
    ds = ds[0]
    groups = ds.chunks
    X_train = ds.samples
    y_train = ds.targets
    cv=LeaveOneGroupOut().split(X_train, y_train, groups)

    X_test = test_ds.samples
    y_test = test_ds.targets
    groupsT = ds.chunks


    # Define a pipeline to search for the best combination of PCA truncation and classifier regularization.
    pca = PCA()
    #svm = LinearSVC()
    svm = SVC()
    pipe = Pipeline(steps=[('PCA', pca), ('SVM', svm)])



    # Parameters of pipelines can be set using separated parameter names
    param_grid = {
        'PCA__n_components': np.linspace(2, maxPCA, rangeX, dtype= int), 
        'SVM__C': [0.01, 0.1, 1, 5, 10], 
        'SVM__gamma': [0.0001, 0.001, 0.005],
        'SVM__kernel': ['rbf', 'sigmoid'] #[0.1, 0.5, 1, 5, 10],
    }

    grid = GridSearchCV(pipe, 
                        param_grid, 
                        cv=cv,
                        refit=True,
                        scoring='accuracy',
                        verbose=1,
                        n_jobs=10)

    grid.fit(X_train,y_train)
    print(grid.best_estimator_)



    optimised_clf = grid.best_estimator_



    grid_predictions = optimised_clf.predict(X_test)
    print(confusion_matrix(y_test,grid_predictions))
    print(classification_report(y_test,grid_predictions))

    dict0 = grid.best_params_
    
    nPCA = dict0.get('PCA__n_components')
    print 'best PCA component', nPCA
    
    nC = dict0.get('SVM__C')
    print 'best SCM C regulator', nC
    
    nG = dict0.get('SVM__gamma')
    print 'best SCM Gamma', nG

    nK = dict0.get('SVM__kernel')
    print 'best SCM Kernel', nK

    bestPCA.append(nPCA)
    bestC.append(nC)
    bestG.append(nG)
    bestK.append(nK)

    bAcTr = grid.best_score_
    bAcTe = grid_predictions.mean()
    print 'best Accuracy in test', bAcTe

    #bSdTe = grid_predictions.std()

    bestAccTr.append(bAcTr)
    bestAccTe.append(bAcTe)
    #bestStdTe.append(bSdTe)


    bPCA = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestPCA.tsv'
    np.savetxt(bPCA, bestPCA, delimiter='\t', fmt='%d')  

    bC = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegC.tsv'
    np.savetxt(bC, bestC, delimiter='\t', fmt='%f')  

    bG = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegG.tsv'
    np.savetxt(bG, bestG, delimiter='\t', fmt='%f')  

    bK = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/bestRegK.tsv'
    np.savetxt(bK, bestK, delimiter='\t', fmt='%s')  

    AccTr = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/AccTrain.tsv'
    np.savetxt(AccTr, bestAccTr, delimiter='\t', fmt='%f')  

    AccTe = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/AccTest.tsv'
    np.savetxt(AccTe, bestAccTe, delimiter='\t', fmt='%f')   

    print 'finished repetition', n
    elapsed = time.time() - start_time
    print 'it took ' + str(timedelta(seconds=elapsed))




#StdTe = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/StdTest.tsv'
#np.savetxt(StdTe, bestStdTe, delimiter='\t', fmt='%f')  

# import numpy as np
# import matplotlib.pyplot as plt
# from sklearn.datasets import load_digits
# from sklearn.model_selection import GridSearchCV
# from sklearn.pipeline import Pipeline
# from sklearn.svm import LinearSVC
# from sklearn.decomposition import PCA, NMF
# from sklearn.feature_selection import SelectKBest, chi2



# print(__doc__)

# pipe = Pipeline([
#     # the reduce_dim stage is populated by the param_grid
#     ('reduce_dim', 'passthrough'),
#     ('classify', LinearSVC(dual=False, max_iter=10000))
# ])

# N_FEATURES_OPTIONS = [2, 4, 8]
# C_OPTIONS = [1, 10, 100, 1000]
# param_grid = [
#     {
#         'reduce_dim': [PCA(iterated_power=7), NMF()],
#         'reduce_dim__n_components': N_FEATURES_OPTIONS,
#         'classify__C': C_OPTIONS
#     },
#     {
#         'reduce_dim': [SelectKBest(chi2)],
#         'reduce_dim__k': N_FEATURES_OPTIONS,
#         'classify__C': C_OPTIONS
#     },
# ]
# reducer_labels = ['PCA', 'NMF', 'KBest(chi2)']

# grid = GridSearchCV(pipe, n_jobs=1, param_grid=param_grid)
# X, y = load_digits(return_X_y=True)
# grid.fit(X, y)

# mean_scores = np.array(grid.cv_results_['mean_test_score'])
# # scores are in the order of param_grid iteration, which is alphabetical
# mean_scores = mean_scores.reshape(len(C_OPTIONS), -1, len(N_FEATURES_OPTIONS))
# # select score for best C
# mean_scores = mean_scores.max(axis=0)
# bar_offsets = (np.arange(len(N_FEATURES_OPTIONS)) *
#                (len(reducer_labels) + 1) + .5)

# plt.figure()
# COLORS = 'bgrcmyk'
# for i, (label, reducer_scores) in enumerate(zip(reducer_labels, mean_scores)):
#     plt.bar(bar_offsets + i, reducer_scores, label=label, color=COLORS[i])

# plt.title("Comparing feature reduction techniques")
# plt.xlabel('Reduced number of features')
# plt.xticks(bar_offsets + len(reducer_labels) / 2, N_FEATURES_OPTIONS)
# plt.ylabel('Digit classification accuracy')
# plt.ylim((0, 1))
# plt.legend(loc='upper left')

# plt.show()