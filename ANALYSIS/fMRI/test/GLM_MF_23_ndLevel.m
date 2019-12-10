function GLM_MF_23_ndLevel()

% does: analysis on run 2 and 3

% one sample ttest
% a flexible factorial with contrasted images
% a conjuction analysis


sub_list = {'01';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';...
    '15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';...
    '30'};


%% define path

homedir = '/home/eva/PAVMOD/';
%homedir = '/Users/evapool/mountpoint/';

funcdir  = fullfile (homedir, '/DATA/brain/cleanBIDS');% directory with  post processed functional scans
mdldir   = fullfile (homedir, '/DATA/brain/MODELS/SPM');% mdl directory (timing and outputs of the analysis)
name_ana = 'GLM-MF-23'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group/');


%% specify spm param
addpath('/usr/local/matlab/R2014a/toolbox/spm12b');
addpath ([homedir 'ANALYSIS/spm_scripts/GLM/dependencies']);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These contrast names become folders
contrastNames = {'INT23.Val-Deval'};

conImages = {'con-0005'};

%% prepare batch for each contrasts

for n = 1:length(contrastNames)
    
    clear matlabbatch
    
    conImageX = conImages{n};
    contrastX = contrastNames{n};
    
    contrastFolder = fullfile (groupdir, 'ttests', 'all', contrastX);

    mkdir(contrastFolder);
    
    % create the group level spm file
    matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder}; % directory
    
    conAll     = spm_select('List',groupdir,['^'  '.*' conImageX '.nii']); % select constrasts
    for j =1:length(conAll)
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{j,1} = [groupdir conAll(j,:) ',1'];
    end
    
    
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    % extimate design matrix
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[contrastFolder  '/SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % specify one sample tconstrast
    matlabbatch{3}.spm.stats.con.spmmat(1)                = {[contrastFolder  '/SPM.mat']};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name     = contrastX (1:end);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights  = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep  = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name     = ['Neg ' contrastX(1:end)];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights  = [-1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep  = 'none';
    
    spm_jobman('run',matlabbatch)
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLEXIBLE FACTORIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%--------------------------------------------------------------------------
% CS: Valcorr - Devalcorr

analysisX = 'FF.RUN23xVALDEVAL';

factor(1).name       = 'VALUE';
factor(1).condition  = [1 2 1 2];
factor(1).levels     = 2;

factor(2).name       = 'TIME';
factor(2).condition  = [1 1 2 2];
factor(2).levels     = 2;


factor(1).idx2cons   = {'con-0001', 'con-0003', 'con-0002', 'con-0004'};

contrast(1).weights  = [         -1,          1,        1,          -1];
contrast(1).name     = 'TIMExVALUE';

contrast(2).weights  = [         1,           -1,       -1,          1];
contrast(2).name     = 'negative TIMExVALUE';

matlabbatch = espm_level2_ff(groupdir,sub_list, factor, contrast, analysisX);


disp ('***************************************************************')
disp (['running batch for: '  analysisX ] )
disp ('***************************************************************')

spm_jobman('run',matlabbatch)

clear analysisX factor constrast



%--------------------------------------------------------------------------
% CONJUNCTION 1  Val Deval CSm corrected

analysisX = 'CONJ1.RUN23';
    
    factor(1).name       = 'VALUE';
    factor(1).condition  = [1 2 1 2];
    factor(1).levels     = 2;
    
    factor(2).name       = 'TIME';
    factor(2).condition  = [1 1 2 2];
    factor(2).levels     = 2;
    
    factor(1).idx2cons   = {'con-0001', 'con-0003', 'con-0002', 'con-0004'};
    
    contrast(1).weights  = [         1,          0,        0,          0];
    contrast(1).name     = 'PRE.val';
    
    contrast(2).weights  = [         0,           1,       0,          0];
    contrast(2).name     = 'PRE.deval';
    
    contrast(3).weights  = [         0,           0,       1,          0];
    contrast(3).name     = 'POST.val';
    
    contrast(4).weights  = [         0,           0,       0,          1];
    contrast(4).name     = 'POST.deval';
    
    matlabbatch = espm_level2_ff(groupdir,sub_list, factor, contrast, analysisX);
    
    
    disp ('***************************************************************')
    disp (['running batch for: '  analysisX ] )
    disp ('***************************************************************')
    
    spm_jobman('run',matlabbatch)
    
    % run the conjunction analysis
    espm_conjunction(groupdir, 'conjuction.nii', 4, analysisX)
    
    clear analysisX factor constrast
    


end