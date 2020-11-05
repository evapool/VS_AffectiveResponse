%-----------------------------------------------------------------------
% MODEL VISUALIZATION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

%define variables
task = 'hedonic'; %'PIT'; 



%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

%addpath('/usr/local/external_toolboxes/spm12/');

BMSdir   = fullfile(homedir, 'DERIVATIVES/BMS', task);


cd(BMSdir)


if strcmp(task, 'PIT')
    models       =  {'04a'; '07'};
    MS_name      = 'MS_SMM_map.nii,1';
else
    models       =  {'04a';  '15a'; '27a'; '28a'};
    MS_name      =   'MS_SMM_map.nii,1';
end

%loop trhough models
for i = 1:length(models)
    model_files{i,1} = fullfile(BMSdir, ['GLM-' models{i} '_model_EPM.nii,1']); 
end

jobs{1}.spm.tools.MACS.MF_visualize.data = flip(model_files);
if strcmp(task, 'PIT')
    jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, 'MS_SMM_BMS_10', MS_name)};
else
    jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(BMSdir, 'MS_SMM_BMS_10', MS_name)};
end

jobs{1}.spm.tools.MACS.MF_visualize.thresh = '>0';
jobs{1}.spm.tools.MACS.MF_visualize.PlotType = 'bar';
jobs{1}.spm.tools.MACS.MF_visualize.LineSpec = 'b';


jobs{1}.spm.tools.MACS.MF_visualize.XTicks = '{0 1 2 3}'; 
%jobs{1}.spm.tools.MACS.MF_visualize.XTicks = 'cellstr(num2str([1:2]''))''';
jobs{1}.spm.tools.MACS.MF_visualize.YLimits = '[0,1]';
jobs{1}.spm.tools.MACS.MF_visualize.Title = 'Bayesian Model Selection';

spm_jobman('run',jobs)