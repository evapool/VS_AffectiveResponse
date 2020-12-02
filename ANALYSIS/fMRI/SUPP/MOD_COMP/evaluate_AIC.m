%-----------------------------------------------------------------------
% Job saved on 20-May-2020 15:48:13 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear all


%define variables
%task = 'hedonic';
task = 'PIT';
subj       =  {'01'; '02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
model       =  {'03'; '04'};

%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];

addpath('/usr/local/external_toolboxes/spm12/');

spm('Defaults','fMRI');
spm_jobman('initcfg');


%loop trhough subjects
for i = 1:length(subj)
    
    %loop trhough models
    for j = 1:length(model)
        
        fprintf('participant number: %s model: %s \n', subj{i}, model{j});
        
        clear jobs
       
        jobs{1}.spm.tools.MACS.MA_classic_ICs_man.SPM_mat =  {fullfile(homedir, ['DERIVATIVES/GLM/' task '/GLM-' model{j} '/sub-' subj{i} '/output/SPM.mat'])};
        jobs{1}.spm.tools.MACS.MA_classic_ICs_man.ICs = 'BIC';
        spm_jobman('run', jobs);  
    end

end


