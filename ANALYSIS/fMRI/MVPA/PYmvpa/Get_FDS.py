
#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 29 16:47:57 2019

@author: created by David on June 13 2020
"""

def warn(*args, **kwargs):
    pass
import warnings, sys, os
from mvpa2.suite import * 
import numpy as np  
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils


def get_train(model, task):
    
    runs2use = 1 ##??

    if model == 'MVPA-01' or model == 'MVPA-04':
        mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

        class_dict = {
                'empty' : 0,
                'chocolate' : 1,
                'neutral' : 1,  #watcha
            }


    # 80% for train
    sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21'] #,'22','23','24','25','26']
    #shuffle(sub_list)  #training set
    #sub_list=sub_list[0:19]
    # #sampling with replacement
    # sub_list = random.choices(slist, k=19)

    print 'doing train ds'

    glm_ds_file = []
    fds = []

    for i in range(0,len(sub_list)):
        subj = sub_list[i]
        print 'working on subject:', subj
        #glm_ds_file.append(homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
        glm_ds_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'

        #use make_targets and class_dict for timing files 1
        ds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task) #glm_ds_file[i]

        #balancing out at the subject level
        if model == 'MVPA-04':
            balancer  = Balancer(attr='targets',count=1,apply_selection=True)
            ds = list(balancer.generate(ds))
            ds = ds[0]


        #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
        detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
        detrended_fds = ds.get_mapped(detrender)

        #basic preproc: zscoring (this is critical given the design of the experiment)
        zscore(detrended_fds)
        ds = detrended_fds

        #changing chunks from miniruns to subjects
        subX = int(subj)
        lenX = len(ds)
        subChunk = np.linspace(subX, subX, lenX, dtype=int)
        ds.chunks = subChunk

        # Removing inv features #pleases the SVM but  ##triplecheck
        #ds = remove_invariant_features(ds)

        fds.append(ds)

        if len(fds) == 1:
            train_ds = fds[i]
        else:
            train_ds = vstack([train_ds,fds[i]])


    train_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/train_ds'
    save(train_ds, train_file)

    return train_ds
    #get_train(homedir, model, task)

def get_full(model, task):
    
    runs2use = 1 ##??

    class_dict = {
        'empty' : 0,
        'chocolate' : 1,
        'neutral' : 1,  #watcha
    }

    if  model == 'MVPA-04':
        mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'


    if model == 'MVPA-01': 
        mask_name = homedir+'DERIVATIVES/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'


    sub_list=['01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26']

    print 'doing full ds'

    glm_ds_file = []
    fds = []

    for i in range(0,len(sub_list)):
        subj = sub_list[i]
        print 'working on subject:', subj
        #glm_ds_file.append(homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
        glm_ds_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'

        #use make_targets and class_dict for timing files 1
        ds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task) #glm_ds_file[i]

        #balancing out at the subject level
        if model == 'MVPA-04':
            balancer  = Balancer(attr='targets',count=1,apply_selection=True)
            ds = list(balancer.generate(ds))
            ds = ds[0]

        #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
        detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
        detrended_fds = ds.get_mapped(detrender)

        #basic preproc: zscoring (this is critical given the design of the experiment)
        zscore(detrended_fds)
        ds = detrended_fds

        #changing chunks from miniruns to subjects
        subX = int(subj)
        lenX = len(ds)
        subChunk = np.linspace(subX, subX, lenX, dtype=int)
        ds.chunks = subChunk


        # Removing inv features #pleases the SVM but  ##triplecheck
        #ds = remove_invariant_features(ds)

        fds.append(ds)

        if len(fds) == 1:
            full_ds = fds[i]
        else:
            full_ds = vstack([full_ds,fds[i]])


    full_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/full_ds'
    save(full_ds, full_file)

    return full_ds
    #get_train(homedir, model, task)


def get_test(model, task):
    
    runs2use = 1 ##??

    if model == 'MVPA-04':
        mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

        class_dict = {
                'empty' : 0,
                'chocolate' : 1,
                'neutral' : 1,  #watcha
            }


    # 20% for test
    sub_list=['22','23','24','25','26']

    print 'doing test ds'

    glm_ds_file = []
    fds = []

    for i in range(0,len(sub_list)):
        subj = sub_list[i]
        print 'working on subject:', subj
        #glm_ds_file.append(homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
        glm_ds_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'

        #use make_targets and class_dict for timing files 1
        ds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task) #glm_ds_file[i]

        #balancing out at the subject level
        if model == 'MVPA-04':
            balancer  = Balancer(attr='targets',count=1,apply_selection=True)
            ds = list(balancer.generate(ds))
            ds = ds[0]
        
        #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
        detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
        detrended_fds = ds.get_mapped(detrender)

        #basic preproc: zscoring (this is critical given the design of the experiment)
        zscore(detrended_fds)
        ds = detrended_fds

        #changing chunks from miniruns to subjects
        subX = int(subj)
        lenX = len(ds)
        subChunk = np.linspace(subX, subX, lenX, dtype=int)
        ds.chunks = subChunk


        # Removing inv features #pleases the SVM but  ##triplecheck
        #ds = remove_invariant_features(ds)

        fds.append(ds)

        if len(fds) == 1:
            test_ds = fds[i]
        else:
            test_ds = vstack([test_ds,fds[i]])


    test_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/test_ds'
    save(test_ds, test_file)

    #get_test(homedir, model, task)
    return test_ds



def get_ind(subj, model, task):


    runs2use = 1 

    if model == 'MVPA-01' or model == 'MVPA-04':
        class_dict = {
            'empty' : 0,
            'chocolate' : 1,
            'neutral' : 1, 
        }

    if model == 'MVPA-02':
        class_dict = {
            'empty' : 0,
            'chocolate' : 1,
        }

    if model == 'MVPA-03' or model == 'MVPA-05':
        class_dict = {
            'neutral' : 0,
            'chocolate' : 1,
        }

    if model == 'MVPA-01' or model == 'MVPA-02' or model == 'MVPA-03': 
        mask_name = homedir+'DERIVATIVES/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'

    if model == 'MVPA-05':
        mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'

    if model == 'MVPA-04':
        mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

    
    glm_ds_file = (homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
    #use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
    fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task)


    #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
    detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
    detrended_fds = fds.get_mapped(detrender)

    #basic preproc: zscoring (this is critical given the design of the experiment)
    zscore(detrended_fds)
    fds_z = detrended_fds

    # Removing inv features #pleases the SVM but  ##triplecheck
    fds = remove_invariant_features(fds_z)

    sub_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds'
    save(fds, sub_file)

    return fds
    
#     runs2use = 1 

#     if model == 'MVPA-04':
#         mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

#         class_dict = {
#                 'empty' : 0,
#                 'chocolate' : 1,
#                 'neutral' : 1,  #watcha
#             }


#     print 'working on subject:', subj
#     glm_ds_file = (homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
    
#     #use make_targets and class_dict for timing files 1
#     ds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task) 

#     #balancing out at the subject level
#     if model == 'MVPA-04':
#         balancer  = Balancer(attr='targets',count=1,apply_selection=True)
#         ds = list(balancer.generate(ds))
#         ds = ds[0]

#     #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
#     detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
#     detrended_fds = ds.get_mapped(detrender)

#     #basic preproc: zscoring (this is critical given the design of the experiment)
#     zscore(detrended_fds)
#     ds = detrended_fds

#     # Removing inv features #pleases the SVM but  ##triplecheck
#     #ds = remove_invariant_features(ds)

#     fds.append(ds)

#     if len(fds) == 1:
#         train_ds = fds[i]
#     else:
#         train_ds = vstack([train_ds,fds[i]])


# train_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/fds_train'
# save(train_ds, train_file)

# return train_ds




# def get_test(model, task):
    
#     runs2use = 1 ##??

#     if model == 'MVPA-04':
#         mask_name = homedir+'DERIVATIVES/EXTERNALDATA/LABELS/Olfa_cortex/Olfa_AMY_full.nii'

#     class_dict = {
#             'empty' : 0,
#             'chocolate' : 1,
#             'neutral' : 1,  #watcha
#         }


#     # 20% for test
#     sub_list=['22','23','24','25','26']

#     print 'doing test ds'

#     glm_ds_file = []
#     fds = []

#     for i in range(0,len(sub_list)):
#         subj = sub_list[i]
#         print 'working on subject:', subj
#         #glm_ds_file.append(homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii')
#         glm_ds_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'

#         #use make_targets and class_dict for timing files 1
#         ds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir,  model, task) #glm_ds_file[i]

#         #balancing out at the subject level
#         if model == 'MVPA-04':
#             balancer  = Balancer(attr='targets',count=1,apply_selection=True)
#             ds = list(balancer.generate(ds))
#             ds = ds[0]

#         #changing chunks from miniruns to subjects
#         subX = int(subj)
#         lenX = len(ds)
#         subChunk = np.linspace(subX, subX, lenX, dtype=int)
#         ds.chunks = subChunk

#         #basic preproc: detrending [likely not necessary since we work with HRF in GLM]
#         detrender = PolyDetrendMapper(polyord=1, chunks_attr='chunks')
#         detrended_fds = ds.get_mapped(detrender)

#         #basic preproc: zscoring (this is critical given the design of the experiment)
#         zscore(detrended_fds)
#         ds = detrended_fds

#         # Removing inv features #pleases the SVM but  ##triplecheck
#         #ds = remove_invariant_features(ds)

#         fds.append(ds)

#         if len(fds) == 1:
#             test_ds = fds[i]
#         else:
#             test_ds = vstack([test_ds,fds[i]])


#     test_file = homedir+'DERIVATIVES/MVPA/'+task+'/'+model+'/test_ds'
#     save(test_ds, test_file)

#     #get_test(homedir, model, task)
#     return test_ds