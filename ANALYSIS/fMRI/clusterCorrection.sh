# cluster ocrrection
#1) make sure that you have the residual files from each subject (checking "write residuals"on the "estimation" step) e.g Res_0001.nii
#2) concatenate the Res files
fslmerge -t Res_4D.nii.gz Res*
#3 estimate spatial smoothness #with roi mask
3dFWHMx -acf smooth.txt -mask mask.nii Res_4D.nii
# the ouput will look lik this :

# ++start ACF calculations out to radius = 37.68mm
# +ACF done (0.74 CPU s thus far)
# 0  0  0    0
# 0.525  3.48032  8.97545    9.27474


# you want the 3 first number of the second row (updated estimate of the smoothness): eg.  0.260939 6.36019 16.6387 in this case
#4) run simulations with roi mask
3dClustSim -acf 0.525 3.48032 8.97545 -mask mask.nii -athr 0.05 -pthr 0.005


#OUR MAIN RESULTS
# task - correction   - ROI - extend
# PIT - SVC 0.05 0.005 - VS - 4.8
# PIT - SVC 0.05 0.005 -  AMY - 22.6
# HED - SVC 0.05 0.005 - VS - 4.6
# HED - SVC 0.05 0.005 - OFC - 12.9