# cluster ocrrection
#1) make sure that you have the residual files from each subject (checking "write residuals"on the "estimation" step) e.g Res_0001.nii
#e.g. matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
#2) concatenate the Res files
fslmerge -t Res_4D.nii Res*
gunzip Res_4D.nii.gz

#3 estimate spatial smoothness #with roi mask
3dFWHMx -acf smooth.txt -mask mask.nii Res_4D.nii
# the ouput will look lik this :

# ++start ACF calculations out to radius = 18.24 mm
# +ACF done (0.74 CPU s thus far)
#0  0  0    0
#0.530377  3.46858  8.92606    9.22028


# you want the 3 first number of the second row (updated estimate of the smoothness): eg.  0.260939 6.36019 16.6387 in this case
#4) run simulations with roi mask
3dClustSim -acf 0.530377  3.46858  8.92606 -mask mask.nii -athr 0.05 -pthr 0.005
#HED #3dClustSim -acf 0.623897  3.22178  9.51635 -mask ~/REWOD/DERIVATIVES/EXTERNALDATA/ROI/VS.nii -athr 0.05 -pthr 0.005

#OUR MAIN RESULTS (NN1 TWO-SIDED)
# task - correction   - ROI - extend
# PIT - SVC 0.05 0.005 - VS - 15.8 #
# PIT - SVC 0.05 0.005 -  AMY - 9.4 #
# PIT - ALL 0.05 0.005 - ALL - 81.7 #
# HED - SVC 0.05 0.005 - VS - 15.0 #
# HED - SVC 0.05 0.005 - mOFC - 10.0 #
# HED - ALL 0.05 0.005 - ALL -  87.6


