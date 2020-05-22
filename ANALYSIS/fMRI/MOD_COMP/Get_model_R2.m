function Get_model_R2(subj, model, task)
%-----------------------------------------------------------------------
% MODEL INSPECTION intended for REWOD
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------

%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];


SPM_mat = fullfile(homedir, ['DERIVATIVES/GLM/' task '/GLM-' model '/sub-' subj '/output/SPM.mat']);

load(SPM_mat);

cd(SPM.swd)

% Get model parameters
%---------------------------------------------------------------------%
GLM.X = SPM.xX.X;           % design matrix
GLM.K = SPM.xX.K;           % filtering matrix
GLM.W = SPM.xX.W;           % whitening matrix
GLM.V = SPM.xVi.V;          % non-sphericity
GLM.n = size(GLM.X,1);      % number of data points
GLM.p = size(GLM.X,2);      % number of parameters
GLM.d = ceil(GLM.n/100);

% Load mask image
%---------------------------------------------------------------------%
[GLM.M m_dim GLM.m] = MA_load_mask(SPM);
[m_img GLM.XYZ] = spm_read_vols(SPM.VM);
GLM.w = prod(SPM.VM.dim);   % number of all voxels
GLM.v = length(GLM.m);      % number of in-mask voxels
clear m_img m_dim

% Load time series
%---------------------------------------------------------------------%
spm_progress_bar('Init',100,'Load time series...','');
GLM.Y = zeros(GLM.n,GLM.v);

for i = 1:GLM.n
    y_img = spm_read_vols(SPM.xY.VY(i));
    y_img = reshape(y_img,[1 GLM.w]);
    GLM.Y(i,:) = y_img(GLM.m);
    if mod(i,GLM.d) == 0, spm_progress_bar('Set',(i/GLM.n)*100); end
end

clear y_img
spm_progress_bar('Clear');

% Load parameter estimates
%---------------------------------------------------------------------%
spm_progress_bar('Init',100,'Load parameter estimates...','');
GLM.B = zeros(GLM.p,GLM.v);
for j = 1:GLM.p
    b_img = spm_read_vols(SPM.Vbeta(j));
    b_img = reshape(b_img,[1 GLM.w]);
    GLM.B(j,:) = b_img(GLM.m);
    spm_progress_bar('Set',(j/GLM.p)*100);
end

clear b_img
spm_progress_bar('Clear');

% Measured and predicted signal
%---------------------------------------------------------------------%
GLM.KWX  = spm_filter(GLM.K,GLM.W*GLM.X);
GLM.KWY  = spm_filter(GLM.K,GLM.W*GLM.Y);
GLM.KWZ  = GLM.KWX * GLM.B;
GLM      = rmfield(GLM,{'Y'});

% Correct for implicit baseline
%---------------------------------------------------------------------%
GLM.pc   = [1:(SPM.xX.iB(1)-1)];
GLM.base = GLM.KWX(:,SPM.xX.iB) * GLM.B(SPM.xX.iB,:);
GLM.KWXc = GLM.KWX(:,GLM.pc);
GLM.KWYc = GLM.KWY - GLM.base;
GLM.KWZc = GLM.KWZ - GLM.base;
GLM      = rmfield(GLM,{'KWX', 'KWY', 'KWZ', 'base'});

% Calculate GoF as overlay
%---------------------------------------------------------------------%
[GLM.sig2, GLM.R2, GLM.adj_R2, GLM.gen_R2] = ME_GLM_GoF(GLM.KWYc, GLM.KWXc, [], GLM.B(GLM.pc,:));
[GLM.mf_SNR, GLM.mb_SNR] = ME_GLM_SNR(GLM.KWYc, GLM.KWXc, [], GLM.B(GLM.pc,:));

% Save GoF as images
%---------------------------------------------------------------------%
H = MA_init_header(SPM, false);
GoF_img = NaN(size(GLM.M));
GoF_img(GLM.m) = GLM.R2;                % R^2
H.fname   = 'MA_GoF_R2.nii';
H.descrip = 'MA_inspect_GoF: coefficient of determination (R^2)';
spm_write_vol(H,reshape(GoF_img,SPM.VM.dim));
SPM.MACS.R2 = H;
GoF_img(GLM.m) = GLM.adj_R2;            % adj. R^2
H.fname   = 'MA_GoF_R2_adj.nii';
H.descrip = 'MA_inspect_GoF: adjusted coefficient of determination (adj. R^2)';
spm_write_vol(H,reshape(GoF_img,SPM.VM.dim));
SPM.MACS.R2_adj = H;
GoF_img(GLM.m) = GLM.mf_SNR;            % mf. SNR
H.fname   = 'MA_GoF_SNR_mf.nii';
H.descrip = 'MA_inspect_GoF: model-free signal-to-noise ratio (mf. SNR)';
spm_write_vol(H,reshape(GoF_img,SPM.VM.dim));
SPM.MACS.SNR_mf = H;
GoF_img(GLM.m) = GLM.mb_SNR;            % mb. SNR
H.fname   = 'MA_GoF_SNR_mb.nii';
H.descrip = 'MA_inspect_GoF: model-based signal-to-noise ratio (mb. SNR)';
spm_write_vol(H,reshape(GoF_img,SPM.VM.dim));
SPM.MACS.SNR_mb = H;
save(strcat(SPM.swd,'/','SPM.mat'),'SPM');

end