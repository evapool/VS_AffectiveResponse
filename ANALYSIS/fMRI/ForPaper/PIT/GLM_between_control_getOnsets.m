function GLM_between_control_getOnsets()

% intended for REWOD PIT

% like GLM-between but we added a first level modulator to account for the
% change in the CS (which are presented in consecutive repetition of three)

% created by Eva R Pool, verified by David Munoz

% last modified on NOV by Eva R. Pool

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];

homedir = [home '/mountpoint2/'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/ForPaper');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
mytools       = fullfile(homedir, '/CODE/ANALYSIS/fMRI/ForPaper/PIT/myfunctions');

addpath(mytools);

ana_name      = 'GLM-between-control';
task          = {'PIT'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name)); % this is only because we have one run per task

%% extract and save data
for j = 1:length(task)
    
    taskX      = char(task(1));
    
    for  i=1:length(subj)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=[char(subj(i))];
        
        subjdir=fullfile(mdldir, char(task), ana_name,  ['sub-' subjX],'timing');
        mkdir (subjdir)
        
        cd (fullfile(sourcefiles,['sub-' subjX], 'ses-second', 'func'));
        behavfile = ['sub-' num2str(subjX) '_ses-second' '_task-' taskX '_run-01_events.mat'];
        fprintf('participant number: %s task: %s \n', subj{i}, task{1})
        disp(['file ' num2str(i) ' ' behavfile]);
        load (behavfile);
        
        %% FOR SPM
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR RIM
        onsets.REM         = RIM.ONSETS.trialstart;
        durations.REM      = RIM.DURATIONS.trialstart;
        modulators.REM     = RIM.BEHAVIOR.mobilized_effort;
        modulators.REM     = meanCenter(modulators.REM);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PE
        onsets.PE          = PE.ONSETS.trialstart;
        durations.PE       = PE.DURATIONS.trialstart;
        modulators.PE      = PE.BEHAVIOR.mobilized_effort;
        modulators.PE      = meanCenter(modulators.PE);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute preceptual propertis
        
        PP = nan(length(PIT.CONDITIONS),1); %odor value vector
        
        VCSplus   = 1;
        VCSminus  = 2;
        VBaseline = 3;
        
        % recode smell in values
        for t = 1:length(PIT.CONDITIONS)
            
            condition       = PIT.CONDITIONS{t};
            if strcmp ('CSplus',  condition)
                PP(t) = VCSplus;           
            elseif strcmp ('CSminus',  condition)
                PP(t) = VCSminus;    
            elseif strcmp ('Baseline',  condition)
                PP(t) = VBaseline;
            end
            
        end
        
        
        ChAbs      = nan(length(PIT.CONDITIONS),1);
        P0 = 0.5;
        for t = 1:length(PP)
            
            if t == 1
                ChAbs (t) = P0;
                PP(t) = P0;
            else
                if PP(t-1) < PP(t)
                    ChAbs (t) = 1;
                elseif PP(t-1) > PP(t)
                    ChAbs (t) = 1;
                elseif PP(t-1) == PP(t)
                    ChAbs (t) = -0.5;
                end
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute changes in values in time series
        
        VV = nan(length(PIT.CONDITIONS),1); %odor value vector
        
        VCSplus   =  1;
        VCSminus  =  -1;
        VBaseline =  0;
        
        % recode CS in values
        for t = 1:length(PIT.CONDITIONS)
            
            condition         = PIT.CONDITIONS{t};
            if strcmp ('CSplus',  condition)
                VV(t) = VCSplus;
            elseif strcmp ('CSminus',  condition)
                VV(t) = VCSminus;
            elseif strcmp ('Baseline',  condition)
                VV(t) = VBaseline;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations

        onsets.PIT.CSp            = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.PIT.CSm            = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.PIT.Baseline       = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        onsets.PIT.conc           = vertcat(onsets.PIT.CSp, onsets.PIT.CSm);
        
        [onsets.PIT.conc, Idx]    = sort(onsets.PIT.conc);
        
        
        durations.PIT.CSp          = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.PIT.CSm          = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.PIT.Baseline     = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        durations.PIT.conc         = vertcat(durations.PIT.CSp, durations.PIT.CSm);
        
        durations.PIT.conc         = durations.PIT.conc(Idx,:);
        
        
        %mod for value
        modulators.PIT.CSp.VV      = VV (strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.VV      = VV (strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.conc.VV     = vertcat(modulators.PIT.CSp.VV, modulators.PIT.CSm.VV);
        
        modulators.PIT.conc.VV     = modulators.PIT.conc.VV(Idx,:);
        modulators.PIT.conc.VV     = meanCenter(modulators.PIT.conc.VV);
        
        %mod for change
        modulators.PIT.CSp.ChAbs   = ChAbs(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.ChAbs   = ChAbs(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.conc.ChAbs  = vertcat(modulators.PIT.CSp.ChAbs, modulators.PIT.CSm.ChAbs);
        
        modulators.PIT.conc.ChAbs  = modulators.PIT.conc.ChAbs(Idx,:);        
        modulators.PIT.conc.ChAbs  = meanCenter(modulators.PIT.conc.ChAbs);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        
        cd (subjdir) 
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
        
    end    
    
end

end