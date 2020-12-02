% List of open inputs
% MS: generate SMM from BMS: Select BMS.mat - cfg_files
% MS: perform BMS (automatic): Select MS.mat - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/cisa/REWOD/CODE/ANALYSIS/fMRI/MOD_COMP/EP_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % MS: generate SMM from BMS: Select BMS.mat - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % MS: perform BMS (automatic): Select MS.mat - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
