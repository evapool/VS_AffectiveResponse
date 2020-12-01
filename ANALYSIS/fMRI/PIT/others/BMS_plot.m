%-----------------------------------------------------------------------
% MODEL VISUALIZATION intended for REWOD HEDONIC
% IMPLEMENTED by David USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

%define variables
task = 'PIT';


%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

addpath('/usr/local/external_toolboxes/spm12/'); %add SPM
addpath('/usr/local/external_toolboxes/spm12/toolbox/MACS/'); %add MACS

BMSdir   = fullfile(homedir, 'DERIVATIVES/BMS', task);


cd(BMSdir)

models       =  {'04a'; '03a'; '09a'; '13a'}; %h0 first and they complexify


%loop trhough models
for i = 1:length(models)
    model_files{i,1} = fullfile(BMSdir, ['GLM-' models{i} '_model_EPM.nii,1']); 
    
    
end

%jobs{4}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMS_mat'));
%jobs{4}.spm.tools.MACS.MS_SMM_BMS.extent = 10;


jobs{1}.spm.tools.MACS.MF_visualize.data = flip(model_files);
jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, ['MS_SMM_BMS_1/MS_SMM_map_pos_1_mod_1_GLM-04a.nii,1'])};


jobs{1}.spm.tools.MACS.MF_visualize.thresh = '>0';
jobs{1}.spm.tools.MACS.MF_visualize.PlotType = 'bar';
jobs{1}.spm.tools.MACS.MF_visualize.LineSpec = 'b';


jobs{1}.spm.tools.MACS.MF_visualize.XTicks = '{0 1 2 3}'; 
%jobs{1}.spm.tools.MACS.MF_visualize.XTicks = 'cellstr(num2str([1:2]''))''';
jobs{1}.spm.tools.MACS.MF_visualize.YLimits = '[0,1]';
jobs{1}.spm.tools.MACS.MF_visualize.Title = 'Bayesian Model Selection';

spm_jobman('run',jobs)