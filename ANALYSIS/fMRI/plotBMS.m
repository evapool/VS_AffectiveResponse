%-----------------------------------------------------------------------
% MODEL VISUALIZATION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

%define variables
task = 'PIT'; %'hedonic'



%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

%addpath('/usr/local/external_toolboxes/spm12/');

BMSdir   = fullfile(homedir, 'DERIVATIVES/GLM/', task, 'BMS');


cd(BMSdir)

% model_H0       =  '04a';
% ;

if strcmp(task, 'PIT')
    models       =  {'04'; '13'};
else
    models       =  {'04'; '15a'};
end

%loop trhough models
for i = 1:length(models)
    model_files{i,1} = fullfile(BMSdir, ['GLM-' models{i} '_model_EPM.nii,1']); 
end

jobs{1}.spm.tools.MACS.MF_visualize.data = flip(model_files);
if strcmp(task, 'PIT')
    jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, ['MS_SMM_BMS_10/MS_SMM_map_pos_2_mod_4_GLM-13.nii,1'])};
else
    jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, ['MS_SMM_BMS_10/MS_SMM_map_pos_1_mod_1_GLM-04a.nii,1'])};
end

jobs{1}.spm.tools.MACS.MF_visualize.thresh = '>0';
jobs{1}.spm.tools.MACS.MF_visualize.PlotType = 'bar';
jobs{1}.spm.tools.MACS.MF_visualize.LineSpec = 'b';


jobs{1}.spm.tools.MACS.MF_visualize.XTicks = '{0 1}'; 
%jobs{1}.spm.tools.MACS.MF_visualize.XTicks = 'cellstr(num2str([1:2]''))''';
jobs{1}.spm.tools.MACS.MF_visualize.YLimits = '[0,1]';
jobs{1}.spm.tools.MACS.MF_visualize.Title = 'Bayesian Model Selection';

spm_jobman('run',jobs)