#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
"""
@author Davif Munoz 2020

create individual matrix plots for raw fmri over time
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import nibabel as nib
import numpy as np

import os
homedir = os.path.expanduser('~/REWOD/')

task = ['PIT', 'hedonic']

for taskN in task:

    subjs = ['01', '02', '03', '04', '05', '06', '07', '09', '10', '11','12', '13', '14', '15', '16', '17', '18', '20', '21', '22', '23', '24', '25', '26'] # 

    #load sample to get the datashape
    subjX = subjs[0]
    imgX = homedir+'DERIVATIVES/PREPROC/sub-'+subjX+'/ses-second/func/sub-'+subjX+'_ses-second_task-'+taskN+'_run-01_bold_reoriented_brain.nii.gz'
    dataX = nib.load(imgX).get_fdata()
    shape1, shape2, shape3, shape4 = dataX.shape
    shapeconc = shape1 * shape2 * shape3

    x = len(subjs)

    data = np.empty((x, shape3, shape4))
    conc = np.empty((x, shapeconc, shape4))

    # for loop to load
    for i in range(x):
        subj = subjs[i]
        img = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/func/sub-'+subj+'_ses-second_task-PIT_run-01_bold_reoriented_brain.nii.gz'
        #img = '/Users/davidmunoz/Desktop/sub-'+subj+'_task-PIT_run-01_smoothBold.nii.gz'
        loadX = nib.load(img).get_fdata()
        for j in range(shape3):
            for k in range(shape4):
                data[i,j,k] = loadX[:,:,j,k].mean() 
            
        
    plt.figure(figsize = (10,10))
    #fig, axes = plt.subplots(nrows=1, ncols=x, sharex=True, sharey=True)
    fig, axes = plt.subplots(nrows=4, ncols=6, sharex=True, sharey=True)
    #conc = np.transpose(conc)

    for ax, m in zip(axes.flat, range(x)):
        im = ax.imshow(data[m], interpolation='none', aspect='auto', cmap='viridis', extent=[0,shape4,shape3,0])
        #ax.set_title(title)
        ax.set_title('Subject %s' % subjs[m], fontsize=4, pad=2)
        ax.tick_params(labelsize=4)  
        #ax.set_ylabel('Voxels', fontsize=8)
        #ax.set_xlabel('Time', fontsize=8) 
    

    fig.colorbar(im, ax=axes.ravel().tolist())
    handles, labels = ax.get_legend_handles_labels()
    ax0 = fig.add_subplot(111, frame_on=False)  
    ax0.set_xticks([])
    ax0.set_yticks([])
    ax0.set_xlabel('Voxels', labelpad=18, fontsize=16)
    ax0.set_ylabel('Time', labelpad=18, fontsize=16)
    ax0.set_title('Z average (%s slices) x Time (%s Scan) X Subject' % (shape3, shape4), fontsize=16,  pad=18)


    pngX = homedir+'plot_all_data_'+taskN+'.png'
    plt.savefig(pngX, dpi = 1000)
    
    print 'done task'+taskN

print 'end'