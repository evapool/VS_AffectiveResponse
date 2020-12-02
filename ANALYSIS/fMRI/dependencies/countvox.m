img = '/home/davidM/REWOD/DERIVATIVES/EXTERNALDATA/ROI/mask.nii';
nii= load_nii(img);%% loading NIFTI files v
%view_nii(nii); %Count voxels 
count_of_white_voxels = sum(nii.img(:))

% # of voxels
%VS = 1259
%cmOFC = 976
%striatum = 3404
%pirif = 238
%AMY = 605

%/home/davidM/REWOD/DERIVATIVES/EXTERNALDATA/LABELS/RL_Atlas/VS.nii