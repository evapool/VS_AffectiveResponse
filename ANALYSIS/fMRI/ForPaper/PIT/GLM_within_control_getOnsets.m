function GLM_within_control_getOnsets()

% intended for REWOD PIT

% like GLM_within but we added a first level modulator to account for the
% change in the CS (which are presented in consecutive repetition of three)

% created by Eva R Pool, verified by David Munoz

%% define paths

cd ~
home = pwd;
homedir = [home '/mountpoint2'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/ForPaper');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
mytools       = fullfile(homedir, '/CODE/ANALYSIS/fMRI/PIT/myfunctions');

addpath(mytools);

ana_name      = 'GLM-within-control';
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
        
        % mob_effort
        modulators.REM     = RIM.BEHAVIOR.mobilized_effort;
         % mean center
        modulators.REM     = meanCenter(modulators.REM);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PE
        onsets.PE          = PE.ONSETS.trialstart;
        durations.PE       = PE.DURATIONS.trialstart;
        
        %mob_effort
        modulators.PE      = PE.BEHAVIOR.mobilized_effort;
        % mean center
        modulators.PE      = meanCenter(modulators.PE);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PIT
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % absolute change
        
        PP = nan(length(PIT.CONDITIONS),1); %odor value vector
        
        VCSplus   = 1;
        VCSminus  = 2;
        VBaseline = 3;
        
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
        for t = 1:length(ChAbs)
            
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
        
        onsets.PIT.CSp          = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.PIT.CSm          = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.PIT.Baseline     = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        durations.PIT.CSp       = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.PIT.CSm       = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.PIT.Baseline  = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        %-------------mob_effort
        modulators.PIT.CSp.eff      = PIT.gripsFrequence(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.eff      = PIT.gripsFrequence(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.Baseline.eff = PIT.gripsFrequence(strcmp ('Baseline', PIT.CONDITIONS));
        
                % if for one of the conditions the modulators is = 0 add small
        % random noise so that the contrasts of inteterest can be computeds       
        list = {'CSp';'CSm';'Baseline'};
        
        for ii = 1:length(list)
            
            nameX = char(list(ii));
            
            if all(modulators.PIT.(nameX).eff == 0)  
                modulators.PIT.(nameX).eff = rand(length(modulators.PIT.(nameX).eff),1); 
            end
        
        end
        
        % mean center
        modulators.PIT.CSp.eff       = meanCenter(modulators.PIT.CSp.eff);
        modulators.PIT.CSm.eff       = meanCenter(modulators.PIT.CSm.eff);
        modulators.PIT.Baseline.eff  = meanCenter(modulators.PIT.Baseline.eff);
        
        %--------------absolute change
        modulators.PIT.CSp.chAbs      =  ChAbs(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.chAbs      =  ChAbs(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.Baseline.chAbs =  ChAbs(strcmp ('Baseline', PIT.CONDITIONS));
        
        % mean center
        modulators.PIT.CSp.chAbs = meanCenter(modulators.PIT.CSp.chAbs);
        modulators.PIT.CSm.chAbs  = meanCenter(modulators.PIT.CSm.chAbs);
        modulators.PIT.Baseline.chAbs = meanCenter(modulators.PIT.Baseline.chAbs);
        
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) %save all info in the participant directory
  
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
        
    end
    
    %create folder for group covariate
    mkdir (fullfile (mdldir, char(task), ana_name, 'group_covariates'));
    
    
end

end