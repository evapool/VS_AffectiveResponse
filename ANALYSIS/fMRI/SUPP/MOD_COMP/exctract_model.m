function exctract_betas()

%clear
%clc
dbstop if error

task = 'hedonic';

%glm = ['GLM-' model];

cHeader = {'SMM_between_m';'SMM_within_m';'SMM_between_sd'; 'SMM_within_sd' };% 'R2'; 'AIC'} %; 'BIC'; 'LME'

%SMMs are likeliest frequency
%maps, but only show those voxels where the corresponding model is the optimal model.
mea_list = {'MS_SMM_map_pos_1_mod_1_GLM-04.nii'; 'MS_SMM_map_pos_2_mod_2_GLM-15.nii'}; %'MA_GoF_R2.nii'; 'MA_ICs_AIC.nii'} %; 'MA_ICs_BIC.nii'; 'MA_cvLME.nii'


%define path
cd ~
home = pwd;
homedir = [home '/REWOD'];

addpath /usr/local/external_toolboxes/spm12/ ;

BMS_dir = fullfile(homedir, 'DERIVATIVES/BMS', task, 'MS_SMM_BMS_10');
cd(BMS_dir)
 
roi = fullfile(homedir, 'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'); 

% intialize spm 
spm('defaults','fmri');
spm_jobman('initcfg');

%subj = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%for i = 1:length(subj)
    
    %sub = ['sub-' subj{i}];

    %dir_data   =  fullfile(homedir, '/DERIVATIVES/GLM', task, glm, sub, 'output');

    %cd(dir_data)

%Find XYZ coordinates of ROI
Y = spm_read_vols(spm_vol(roi),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';

%loop across model
for j = 1:length(mea_list)

    disp([' Doing model -' mea_list{j}]);

    P = spm_vol(mea_list{j});

    est = spm_get_data(P,XYZ);
    meanest = nanmean(est,2);
    stdest = nanstd(est);

    data{j} = meanest ;
    data{2+j} = stdest ;
    

end

    
%end

%cd(fullfile(BMS_dir, 'GoF_NAcc'))
commaHeader = [cHeader';repmat({','},1,numel(cHeader))]; %insert commas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas

%write header to file
fid = fopen('MOD_comp.csv','w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);

%write data to end of file
dlmwrite('MOD_comp.csv',data,'-append');

end




