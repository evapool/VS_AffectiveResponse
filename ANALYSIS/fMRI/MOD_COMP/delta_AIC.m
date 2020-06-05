% List of open inputs
nrun = 1; % enter the number of runs here
%jobfile = {'/home/davidM/REWOD/CODE/ANALYSIS/fMRI/MOD_COMP/delta_AIC_HED.m'};
jobfile = {'/home/davidM/REWOD/CODE/ANALYSIS/fMRI/MOD_COMP/delta_AIC_PIT.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
