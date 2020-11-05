%-----------------------------------------------------------------------
% BAYESIAN MODEL SELECTION intended for REWOD HEDONIC
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all
addpath /usr/local/external_toolboxes/spm12/toolbox/MACS/ 

cd ~
home = pwd;
homedir = [home '/REWOD/'];

spm('Defaults','fMRI');
spm_jobman('initcfg');

jobs{1}.spm.tools.MACS.MA_model_space.dir = {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/MACS')};
jobs{1}.spm.tools.MACS.MA_model_space.models = {
                                                       {
                                                       {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/GLM-04/sub-01/output/SPM.mat')}
                                                       {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/GLM-15/sub-01/output/SPM.mat')}
                                                       }'
                                                       {
                                                       {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/GLM-04/sub-02/output/SPM.mat')}
                                                       {fullfile(homedir, 'DERIVATIVES/GLM/hedonic/GLM-15/sub-02/output/SPM.mat')}
                                                       }'
                                                       }';
jobs{1}.spm.tools.MACS.MA_model_space.names = {
                                                      'GLM-04'
                                                      'GLM-15'
                                                      }';
                                                  
jobs{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
jobs{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
jobs{3}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;
jobs{4}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMS_mat'));
jobs{4}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

spm_jobman('run', jobs)
