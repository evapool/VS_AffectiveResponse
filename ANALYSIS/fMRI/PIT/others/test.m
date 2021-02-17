% List of open inputs
% MS: perform BMS (manually): Select LME maps - cfg_repeat
% MS: perform BMS (manually): Enter GLM names - cfg_repeat
nrun = X; % enter the number of runs here
jobfile = {'/home/davidM/REWOD/CODE/ANALYSIS/fMRI/PIT/forBMS/test_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % MS: perform BMS (manually): Select LME maps - cfg_repeat
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % MS: perform BMS (manually): Enter GLM names - cfg_repeat
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
