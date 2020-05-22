function exctract_betas(model, task)

%clear
%clc
dbstop if error

glm = ['GLM-' model];

cHeader = {'R2adj'; 'R2'; 'AIC'; 'BIC'; 'LME'};

mea_list = {'MA_GoF_R2_adj.nii'; 'MA_GoF_R2.nii'; 'MA_ICs_AIC.nii'; 'MA_ICs_BIC.nii'; 'MA_cvLME.nii'}; %


%define path
cd ~
home = pwd;
homedir = [home '/REWOD'];

addpath /usr/local/external_toolboxes/spm12/ ;

BMS_dir = fullfile(homedir, 'DERIVATIVES/BMS', task);
cd(BMS_dir)
mkdir('GoF_NAcc')
 
roi = fullfile(homedir, 'DERIVATIVES/EXTERNALDATA/LABELS/CORE_SHELL/NAcc.nii'); 

% intialize spm 
spm('defaults','fmri');
spm_jobman('initcfg');

subj = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


for i = 1:length(subj)
    
    sub = ['sub-' subj{i}];

    dir_data   =  fullfile(homedir, '/DERIVATIVES/GLM', task, glm, sub, 'output');

    cd(dir_data)

    %Find XYZ coordinates of ROI
    Y = spm_read_vols(spm_vol(roi),1);
    indx = find(Y>0);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]';

    %loop across model
    for j = 1:length(mea_list)
        
        disp([' Doing sub-' subj{i} ' for meaure-' mea_list{j}]);
        
        P = spm_vol(mea_list{j});

        est = spm_get_data(P,XYZ);
        est = nanmean(est,2);
        
        data{i,j} = est;

    end

    
end

cd(fullfile(BMS_dir, 'GoF_NAcc'))
commaHeader = [cHeader';repmat({','},1,numel(cHeader))]; %insert commas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas

%write header to file
fid = fopen([glm '.csv'],'w'); 
fprintf(fid,'%s\n',textHeader)
fclose(fid)

%write data to end of file
dlmwrite([glm '.csv'],data,'-append');
end




