%-----------------------------------------------------------------------
% BAYESIAN MODEL SELECTION intended for PIT HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all


%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

addpath('/usr/local/external_toolboxes/spm12/'); %add SPM
addpath('/usr/local/external_toolboxes/spm12/toolbox/MACS/'); %add MACS

spm('Defaults','fMRI');
spm_jobman('initcfg');

%define variables
task = 'PIT';
subj       =  {'24';'25';'26';}; %subID;
model       =  {'04'; '03'; '09'; '13'}; %h0 first and they complexify

%01'; '02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';

jobs{1}.spm.tools.MACS.MA_model_space.dir = {fullfile(homedir, 'DERIVATIVES/GLM', task, 'BMS')};


%loop trhough subjects
for i = 1:length(subj)
    
    model_list = {};
    
    %loop trhough models
    for j = 1:length(model)
       
        model_list{j} = {fullfile(homedir, ['DERIVATIVES/GLM/' task '/GLM-' model{j} '/sub-' subj{i} '/output/MA_cvLME.nii'])};
        
        model_names{j,1} = ['GLM-' model{j}];
        
    end
    
    model_space{i} = model_list;
end


%define group level BMS batch
jobs{1}.spm.tools.MACS.MS_BMS_group_man.dir = {'/home/davidM/REWOD/DERIVATIVES/GLM/PIT/BMS'};
jobs{1}.spm.tools.MACS.MS_BMS_group_man.models = model_space;
jobs{1}.spm.tools.MACS.MS_BMS_group_man.names = model_names;
jobs{1}.spm.tools.MACS.MS_BMS_group_man.inf_meth = 'RFX-VB';
jobs{1}.spm.tools.MACS.MS_BMS_group_man.EPs = 1;



spm_jobman('run', jobs)
