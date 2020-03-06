#!/usr/bin/env python
# coding: utf-8

"""
Created on Mon Mar 10 14:13:20 2020
@author: David Munoz
"""


# data analysis and wrangling
import pandas as pd
import numpy as np
from scipy import stats 
import os
from pathlib import Path


#addpath
home = str(Path.home())
        

#declare variables
GLM = ("GLM-20")
s = ("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")
taskDIR = ("hedonic")

df1 = []
df2 = []
df3 = []
df5 = []

dfsubj = []

df01 = pd.DataFrame()
df02 = pd.DataFrame()
df03 = pd.DataFrame()
df05 = pd.DataFrame()

#%%
for i in s:
    subj = 'sub-' + i
    covpath = home + '/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/' + subj + '/timing/'
    cov_control = pd.read_table(covpath + GLM + '_task-hedonic_odor_control.txt',sep='\t', header=None)
    cov_neutral = pd.read_table(covpath + GLM + '_task-hedonic_odor_neutral.txt',sep='\t', header=None)
    cov_reward = pd.read_table(covpath + GLM + '_task-hedonic_odor_reward.txt',sep='\t', header=None)

    dfsubj = np.append(dfsubj, i)

    C_R = cov_control[2] - cov_reward[2]
    df1 = np.append(df1,C_R.mean())

    N_R =  cov_neutral[2] - cov_reward[2]
    df2 = np.append(df2, N_R.mean())

    NoOdor_Odor = cov_control[2] - (cov_reward[2] + cov_neutral[2])/2
    df3 = np.append(df3, NoOdor_Odor.mean())
    
    NoReward_Reward = cov_reward[2] - (cov_neutral[2] + cov_control[2])/2
    df5 = np.append(df5, NoReward_Reward.mean())

#%%      
df01[0] = dfsubj
df02[0] = dfsubj
df03[0] = dfsubj
df05[0] = dfsubj

# mean center BY CONDITION
df01[1] = stats.zscore(df1)
df02[1] = stats.zscore(df2)
df03[1] = stats.zscore(df3)
df05[1] = stats.zscore(df5)

df01.columns = ['subj', 'EMG']
df02.columns = ['subj', 'EMG']
df03.columns = ['subj', 'EMG']
df05.columns = ['subj', 'EMG']


os.chdir(home +'/REWOD/DERIVATIVES/ANALYSIS/' + taskDIR + '/' + GLM + '/group_covariates')
df01.to_csv('control-reward_EMG_zscore.txt',sep='\t', index=False)
df02.to_csv('neutral-reward_EMG_zscore.txt',sep='\t', index=False)
df03.to_csv('NoOdor-Odor_EMG_zscore.txt',sep='\t', index=False)
df05.to_csv('NoReward_Reward_EMG_zscore.txt',sep='\t', index=False)

print("covariates done")