%-----------------------------------------------------------------------
% BAYESIAN MODEL SELECTION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
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

jobs{1}.spm.tools.MACS.MA_model_space.dir = {fullfile(homedir, 'DERIVATIVES/BMS', task)};


%loop trhough subjects
for i = 1:length(subj)
    
    model_list = {};
    
    %loop trhough models
    for j = 1:length(model)
       
        model_list{j} = {fullfile(homedir, ['DERIVATIVES/GLM/' task '/GLM-' model{j} '/sub-' subj{i} '/output/SPM.mat'])};
        
        model_names{j,1} = ['GLM-' model{j}];
        
    end
    
    model_space{i} = model_list;
end

%define model space
jobs{1}.spm.tools.MACS.MA_model_space.models = model_space;
jobs{1}.spm.tools.MACS.MA_model_space.names = model_names;


%define group level BMS batch
jobs{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
jobs{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;
jobs{4}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMS_mat'));
jobs{4}.spm.tools.MACS.MS_SMM_BMS.extent = 10;


spm_jobman('run', jobs)
