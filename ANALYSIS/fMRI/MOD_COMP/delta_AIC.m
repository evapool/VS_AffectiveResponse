%-----------------------------------------------------------------------
% MODEL COMPARISON using DELTA AIC intended for HEDONIC
% IMPLEMENTED using MACS by J. Soch
%-----------------------------------------------------------------------
clear all


%define variables
task = 'hedonic';
subj       =  {'01'; '02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
model       =  {'04'; '15'};

%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

addpath('/usr/local/external_toolboxes/spm12/');

spm('Defaults','fMRI');
spm_jobman('initcfg');


%loop trhough subjects
for i = 1:length(subj)
    
    model_list = {};
    
    %loop trhough models
    for j = 1:length(model)
       
        model_list{j} = {fullfile(homedir, ['DERIVATIVES/GLM/' task '/GLM-' model{j} '/sub-' subj{i} '/output/MA_ICs_AIC.nii,1'])};
        
        model_names{j,1} = ['GLM-' model{j}];
        
    end
    
    model_AIC{i} = model_list;
end


%define model space
jobs{1}.spm.tools.MACS.MC_LBF_group_man.models = model_AIC;


jobs{1}.spm.tools.MACS.MC_LBF_group_man.dir = {fullfile(homedir, ['DERIVATIVES/BMS/' task ])};
jobs{1}.spm.tools.MACS.MC_LBF_group_man.names = model_names;



spm_jobman('run', jobs)



