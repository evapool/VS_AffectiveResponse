%-----------------------------------------------------------------------
% BAYESIAN MODEL SELECTION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

%define variables
task = 'hedonic';
model_H0       =  '15';
models       =  {'04'; '15'};


%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

%addpath('/usr/local/external_toolboxes/spm12/');

BMSdir   = fullfile(homedir, 'DERIVATIVES/BMS', task);


cd(BMSdir)

%loop trhough models
for i = 1:length(models)
    
    model_files{i,1} = fullfile(BMSdir, ['GLM-' models{i} '_model_LFM.nii,1']); 
    model_names{i} = ['GLM-' models{i}];
end

jobs{1}.spm.tools.MACS.MF_visualize.data = model_files;
jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, ['MS_SMM_BMS_10/MS_SMM_map_pos_2_mod_2_GLM-' model_H0 '.nii,1'])};
jobs{1}.spm.tools.MACS.MF_visualize.thresh = '>0';
jobs{1}.spm.tools.MACS.MF_visualize.PlotType = 'bar';
jobs{1}.spm.tools.MACS.MF_visualize.LineSpec = 'b';


jobs{1}.spm.tools.MACS.MF_visualize.XTicks = model_names;
%jobs{1}.spm.tools.MACS.MF_visualize.XTicks = 'cellstr(num2str([1:2]''))''';
jobs{1}.spm.tools.MACS.MF_visualize.YLimits = '[0,1]';
jobs{1}.spm.tools.MACS.MF_visualize.Title = 'Bayesian Model Selection';

spm_jobman('run',jobs)