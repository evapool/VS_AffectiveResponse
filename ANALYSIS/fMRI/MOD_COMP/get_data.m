

%clear
%clc
dbstop if error
task = 'hedonic';

%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

BMSdir   = fullfile(homedir, 'DERIVATIVES/BMS', task, 'MS_SMM_BMS_10');

if strcmp(task,'PIT')
    img = 'MS_SMM_map_pos_1_mod_1_GLM-07.nii';
else 
    img = 'MS_SMM_map_pos_1_mod_1_GLM-04a.nii';
end


addpath /usr/local/external_toolboxes/spm12/ ;

 
roi = fullfile(homedir, 'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'); 

% intialize spm 
spm('defaults','fmri');
spm_jobman('initcfg');



cd(BMSdir)

%Find XYZ coordinates of ROI
Y = spm_read_vols(spm_vol(roi),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';



P = spm_vol(img);

est = spm_get_data(P,XYZ);
mean = nanmean(est,2);
devia = std(est,'omitnan');







