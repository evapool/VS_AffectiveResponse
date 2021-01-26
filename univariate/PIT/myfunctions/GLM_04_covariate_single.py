#!/usr/bin/env python
# coding: utf-8

"""
Created on Mon Jun 10 14:13:20 2019

@author: David Munoz

takes the condition name as input ('eff')
"""

def covariate (cond):
    # data analysis and wrangling
    import pandas as pd
    import numpy as np
    import os
    #rom pathlib import Path

    cond = 'eff'

    #addpath
    home =  '/home/davidM'

    #declare variables
    GLM = ("GLM-04")
    s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")
    taskDIR = ("PIT")

    df1 = []
    df2 = []
    df3 = []

    dfsubj = []

    df01 = pd.DataFrame()



    for i in s:
        subj = 'sub-' + i
        covpath = home + '/REWOD/DERIVATIVES/GLM/' + taskDIR + '/' + GLM + '/' + subj + '/timing/'
  
        cov_minus = pd.read_table(covpath + GLM + '_task-PIT_CS_CSm.txt',sep='\t', header=None)
        cov_plus = pd.read_table(covpath + GLM + '_task-PIT_CS_CSp.txt',sep='\t', header=None)

        dfsubj = np.append(dfsubj, i)

        CSp_CSm = cov_plus[2] - cov_minus[2]
        df1 = np.append(df1, CSp_CSm.mean())


  #%%
    df01[0] = dfsubj


    # mean center BY CONDITION
    df01[1] = df1 - df1.mean()

    df01.columns = ['subj', cond]



    os.chdir(home +'/REWOD/DERIVATIVES/GLM/' + taskDIR + '/' + GLM + '/group_covariates')
    df01.to_csv('CSp_CSm_' + cond + '_meancent.txt',sep='\t', index=False)

    print("covariates done")

    
