%-----------------------------------------------------------------------
% BAYESIAN MODEL SELECTION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

model_H0       =  '15';
models       =  {'04'; '15'};

addpath('/usr/local/external_toolboxes/spm12/');

cd ~
home = pwd;
homedir = [home '/REWOD/'];


BMSdir   = fullfile(homedir,'DERIVATIVES/GLM/hedonic/MACS/');

cd(BMSdir)

%loop trhough models
for i = 1:length(models)
    
    model_files{i,1} = {fullfile(homedir, ['DERIVATIVES/GLM/hedonic/MACS/GLM-' models{i} '_model_LFM.nii,1'])};
    model_names{i} = ['GLM-' model{i}];
end

jobs{1}.spm.tools.MACS.MF_visualize.data = {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/MACS/GLM-04_model_LFM.nii,1')
                                            fullfile(homedir, 'DERIVATIVES/GLM/hedonic/MACS/GLM-15_model_LFM.nii,1')
                                                   };
                                               
jobs{1}.spm.tools.MACS.MF_visualize.overlay = {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/MACS/MS_SMM_BMS_10/MS_SMM_map_pos_2_mod_2_GLM-15.nii,1')};
jobs{1}.spm.tools.MACS.MF_visualize.thresh = '>0';
jobs{1}.spm.tools.MACS.MF_visualize.PlotType = 'bar';
jobs{1}.spm.tools.MACS.MF_visualize.LineSpec = 'b';
jobs{1}.spm.tools.MACS.MF_visualize.XTicks = 'cellstr(num2str([1:2]''))''';
jobs{1}.spm.tools.MACS.MF_visualize.YLimits = '[0,1]';
jobs{1}.spm.tools.MACS.MF_visualize.Title = 'Bayesian Model Selection';

spm_jobman('run',jobs)