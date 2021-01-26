function GLM_within_control_stLevel(subID) 

% intended for REWOD hedonic

% get onsets for model with change and improvement and liking and intesity as 1st level modulator
% Model on ONSETs (start, 2*odor 1odor less air + 2*questions)

% Created by David Munoz, verified by Eva R Pool


%% What to do
firstLevel    = 1;
contrasts     = 1;
copycontrasts = 1;

%% define path
homedir = ['/home/REWOD/'];


mdldir   = fullfile(homedir, '/DERIVATIVES/GLM/hedonic');% mdl directory (timing and outputs of the analysis)
funcdir  = fullfile(homedir, '/DERIVATIVES/PREPROC');% directory with  post processed functional scans
name_ana = 'GLM-within-control'; % output folder for this analysis
groupdir = fullfile (mdldir,name_ana, 'group/');

addpath('/usr/local/external_toolboxes/spm12/');


%% specify fMRI parameters
param.TR = 2.4;
param.im_format = 'smoothBold.nii'; 
param.ons_unit = 'secs'; 
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% define experiment setting parameters
subj       = subID; % run in parallel on the server
param.task = {'hedonic'};

%% define experimental design parameters
param.Cnam     = cell (length(param.task), 1);
param.duration = cell (length(param.task), 1);
param.onset = cell (length(param.task), 1);


for i = 1:length(param.task)
    
    % Specify each conditions of your desing matrix separately for each session. The sessions
    % represent a line in Cnam, and the conditions correspond to a item in the line
    % these names must correspond identically to the names from your ONS*mat.
    param.Cnam{i} = {'start',... 
        'odor',...
        'control',...
        'liking',... 
        'intensity'};

        
     param.onset{i} = {'ONS.onsets.start',... %1
        'ONS.onsets.odor.conc', ...
        'ONS.onsets.odor.control', ...
        'ONS.onsets.liking',... 
        'ONS.onsets.intensity'};

    
    % duration of the blocks (if events, put '0'). Specify it for each condition of each session
    % the values must be included in your onsets in seconds
    param.duration{i} = {'ONS.durations.start',...
        'ONS.durations.odor.conc',...
         'ONS.durations.odor.control',...
        'ONS.durations.liking',...
        'ONS.durations.intensity'};

    
    % parametric modulation of your events or blocks (ex: linear time, or emotional value, or pupillary size, ...)
    % If you have a parametric modulation
    param.modulName{i} = {'none',...
        'multiple',...
        'none',...
        'none',...
        'none'}; 
    
    param.modul{i} = {'none',...
        'ONS.modulators.odor.conc',... 
        'none',... 
        'none',... 
        'none'}; 
    
    % value of the modulators, If you have a parametric modulation
    param.time{i} = {'0',... 
        '1',... 
        '0',... 
        '0'};

end

%% apply design for first level analysis for each participant


% participant's specifics
subjX = char(subID);
subjoutdir =fullfile(mdldir,name_ana, [ 'sub-' subjX]); 
subjfuncdir=fullfile(funcdir, [ 'sub-' subjX], 'ses-second'); 
fprintf('participant number: %s \n', subjX);
cd (subjoutdir)

if ~exist('output','dir')
    mkdir ('output');
end

%%%%%%%%%%%%%%%%%%%%% DO FIRST LEVEL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%
if firstLevel == 1
    [SPM] = doFirstLevel(subjoutdir,subjfuncdir,name_ana,param,subjX);
else
    cd (fullfile(subjoutdir,'output'));
    load SPM
end

%%%%%%%%%%%%%%%%%%%%%%%  DO CONTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if contrasts == 1
    doContrasts(subjoutdir,param, SPM);
end

%%%%%%%%%%%%%%%%%%%%% COPY CONTRASTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if copycontrasts == 1
    
    mkdir (groupdir); % make the group directory where contrasts will be copied
    cd (fullfile(subjoutdir,'output'))
    
    list_dir = dir(fullfile(subjoutdir,'output', 'con*'));
    list_files = '';
    for ii = 1:length(list_dir)
        copyfile(list_dir(ii).name, [groupdir, 'sub-' subjX '_' list_dir(ii).name])
    end
    
    
    list_dir = dir(fullfile(subjoutdir,'output', 'ess*'));
    list_files = '';
    for iii = 1:length(list_dir)
        copyfile(list_dir(iii).name, [groupdir, 'sub-' subjX '_' list_dir(iii).name])
    end
    
    display('contrasts copied!');
end


%% function section
    function [SPM] = doFirstLevel(subjoutdir,subjfuncdir, name_ana, param, subjX)
        
        % variable initialization
        ntask = size(param.task,1);
        im_style = 'sub'; 
        nscans = [];
        scanID = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %-----------------------------
        % select post processed images for each Session
        %for 
        ses = 1:ntask;
            
        taskX = char(param.task(ses));
        smoothfolder       = [subjfuncdir '/func'];
        targetscan         = dir (fullfile(smoothfolder, [im_style '*' taskX '*' param.im_format]));
        tmp{ses}           = spm_select('List',smoothfolder,targetscan.name);
        
        Maskimage = [subjfuncdir '/anat/sub-' subjX '_ses-second_run-01_T1w_reoriented_brain_mask.nii'];

        % get the number of EPI for each session
        cd (smoothfolder);
        V         = dir(fullfile(smoothfolder, targetscan.name));
        [p,n,e]   = spm_fileparts(V(1).name);
        Vn        = spm_vol(fullfile(p,[n e]));
        nscans    = [nscans numel(Vn)];

        for j = 1:nscans(ses)
            scanID    = [scanID; {[smoothfolder,'/', V.name, ',', num2str(j)]}];
        end
            
        %end
        
        SPM.xY.P    = char(scanID);
        SPM.nscan   = nscans;
        
        
        %-----------------------------
        % building matrix
        for ses = 1:ntask
            
            taskX = char(param.task(ses));
            
            ONSname = spm_select('List',[subjoutdir '/timing/'],[name_ana '_task-' taskX '_onsets.mat']);
            cd([subjoutdir '/timing/']) % path
            ONS = load(ONSname);
            cd([subjoutdir '/output/'])
            
            nconds=length(param.Cnam{ses});
            
            c = 0; % we need a counter because we include only condition that are non empty
            
            for cc=1:nconds
                
                if ~ std(eval(param.onset{ses}{cc}))== 0 % only if the onsets are not all 0
               
                    c = c+1; % update counter
                    
                    SPM.Sess(ses).U(c).name      = {param.Cnam{ses}{cc}};
                    SPM.Sess(ses).U(c).ons       = eval(param.onset{ses}{cc});
                    SPM.Sess(ses).U(c).dur       = eval(param.duration{ses}{cc});
                    
                    SPM.Sess(ses).U(c).P(1).name = 'none';
                    SPM.Sess(ses).U(c).orth = 0;
                    
                    
                    if isfield (param, 'modul') % this parameters are specified only if modulators are defined in the design
                        
                        if ~ strcmp(param.modul{ses}{cc}, 'none')
                            
                            if isstruct (eval(param.modul{ses}{cc}))
                                SPM.Sess(ses).U(c).orth = 0; 
                                mod_names = fieldnames (eval(param.modul{ses}{cc}));
                                nc = 0; % intialize the modulators count
                                
                                for nmod = 1:length(mod_names)
                                    
                                    nc = nc+1;
                                    mod_name = char(mod_names(nmod));
                                    
                                    if  ~ round(std(eval([param.modul{ses}{cc} '.' mod_name])),10)== 0  %verify that there is variance in mod
                                      
                                    
                                        SPM.Sess(ses).U(c).P(nc).name  = mod_name;
                                        SPM.Sess(ses).U(c).P(nc).P     = eval([param.modul{ses}{cc} '.' mod_name]);
                                        SPM.Sess(ses).U(c).P(nc).h     = 1;
                                        
                                    else

                                       SPM.Sess(ses).U(c).P(nc).name  = [];
                                       SPM.Sess(ses).U(c).P(nc).P     = [];
                                       SPM.Sess(ses).U(c).P(nc).h     = []; 
                                    end

                                end
                                

                            else
                                
                                SPM.Sess(ses).U(c).P(1).name  = char(param.modulName{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).P     = eval(param.modul{ses}{cc});
                                SPM.Sess(ses).U(c).P(1).h     = 1; 
                           
                            end
                        end
                    end
                end
            end
        end
        
        %-----------------------------
        %multiple regressors for mvts parameters ( no movement regressor after ICA)
        
        for ses=1:ntask
            
            SPM.Sess(ses).C.C = [];
            SPM.Sess(ses).C.name = {};
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % basis functions and timing parameters
        
        % OPTIONS: TR in seconds
        %--------------------------------------------------------------------------
        SPM.xY.RT          = param.TR;
        
        % OPTIONS: % 'hrf (with time derivative)'
        %--------------------------------------------------------------------------
        SPM.xBF.name       = 'hrf';
        
        % OPTIONS: % 2 = hrf (with time derivative)
        %--------------------------------------------------------------------------
        SPM.xBF.order      = 1;
        
        % OPTIONS: % length in seconds
        %--------------------------------------------------------------------------
        SPM.xBF.length     = 0;
        
        %--------------------------------------------------------------------------
        SPM.xBF.UNITS      = param.ons_unit;
        
        % % OPTIONS: 1|2 = order of convolution
        %--------------------------------------------------------------------------
        SPM.xBF.Volterra   = 1;
        
        % global normalization: OPTIONS:'Scaling'|'None'
        %--------------------------------------------------------------------------
        SPM.xGX.iGXcalc    = 'None';
        
        % low frequency confound: high-pass cutoff (secs) [Inf = no filtering] 
        %--------------------------------------------------------------------------
        SPM.xX.K(1).HParam = 128;
        
        % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
        %--------------------------------------------------------------------------
        SPM.xVi.form       = 'AR'; 
        
        % specify SPM working dir for this sub
        %==========================================================================
        SPM.swd = pwd;
        
        % set threshold of mask
        %==========================================================================
        SPM.xM.gMT =  0.1;
        SPM.xM.VM  =  spm_vol(Maskimage);
        SPM.xM.I   =  0.1;
        
        % Configure design matrix
        %==========================================================================
        SPM = spm_fmri_spm_ui(SPM);
        
        % Estimate parameters
        %==========================================================================
        disp ('estimating model')
        SPM = spm_spm(SPM); %SPM = spm_rwls_spm(SPM);
        
        disp ('first level done');
    end

 
    function [] = doContrasts(subjoutdir, param, SPM)
        
        % define the SPM.mat that contains the design of the first level analysis
        %------------------------------------------------------------------
        path_ana = fullfile(subjoutdir, 'output'); % path for the first level analysis
        [files]=spm_select('List',path_ana,'SPM.mat');
        jobs{1}.stats{1}.con.spmmat = {fullfile(path_ana,files)};
        
        % define  T contrasts in a human friendly readable way
        %------------------------------------------------------------------
        
        % | GET THE NAMES FROM THE ONSETS PARAMETERS OF THE SPM MODEL
        ncondition = size(SPM.xX.name,2);
        
        for j = 1:ncondition
   
            task  = 'task-hed.'; %taskN in the middle
            conditionName{j} = strcat(task,SPM.xX.name{j} (7:end-6)); %this cuts off the useless parts of the names
            
        end
        conditionName{ncondition} = strcat(task,'constant'); %just for the last condition
        
         Ct = []; Ctnames = []; ntask = size(param.task,1);
        
        % | contrasts FOR T-TESTS
        
        % con1
        Ctnames{1} = 'odor_lik';
        weightPos  = ismember(conditionName, {'task-hed.odorxlik^1'}) * 1; 
        Ct(1,:)    = weightPos;
        
        %con2
        Ctnames{2} = 'odor_int';
        weightPos  = ismember(conditionName, {'task-hed.odorxint^1'}) * 1; 
        Ct(2,:)    = weightPos;
        
        %con3
        Ctnames{3} = 'odor_ch';
        weightPos  = ismember(conditionName, {'task-hed.odorxch^1'}) * 1; 
        Ct(3,:)    = weightPos;

        %con4
        Ctnames{4} = 'odor_ChAbs';
        weightPos  = ismember(conditionName, {'task-hed.odorxchAbs^1'}) * 1;
        Ct(4,:)    = weightPos;

        
        % put the contrast matrix
        %------------------------------------------------------------------
        
        % t contrasts
        for icon = 1:size(Ct,1)
            jobs{1}.stats{1}.con.consess{icon}.tcon.name = Ctnames{icon};
            jobs{1}.stats{1}.con.consess{icon}.tcon.convec = Ct(icon,:);
        end
      
        
        % run the job
        spm_jobman('run',jobs)
        
        disp ('contrasts created!')
    end


end