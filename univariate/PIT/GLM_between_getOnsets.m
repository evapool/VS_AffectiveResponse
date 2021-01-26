function GLM_between_getOnsets()

% intended for REWOD PIT
% get onsets for model with 2nd level modulators
% Model on ONSETs 3*CS without first level modulator


% Created by David Munoz, verified by Eva R Pool

%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD/'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-between';
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
        onsets.CS.REM         = RIM.ONSETS.trialstart;
        durations.CS.REM      = RIM.DURATIONS.trialstart;
        modulators.CS.REM     = ones(length(RIM.DURATIONS.trialstart),1);
  
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips %%
        onsets.grips.REM         = RIM.ONSETS.grips;
        durations.grips.REM      = zeros (length(onsets.grips.REM),1);
        modulators.grips.REM     = ones  (length(onsets.grips.REM),1);
        
              
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PE
        onsets.CS.PE          = PE.ONSETS.trialstart;
        durations.CS.PE       = PE.DURATIONS.trialstart;
        modulators.CS.PE      = ones(length(PE.DURATIONS.trialstart),1);
  
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips %%
        onsets.grips.PE          = PE.ONSETS.grips;
        durations.grips.PE       = zeros (length(onsets.grips.PE),1);
        modulators.grips.PE      = ones  (length(onsets.grips.PE),1);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PIT
        onsets.CS.CSp          = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.CS.CSm          = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.CS.Baseline     = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        durations.CS.CSp       = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.CS.CSm       = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.CS.Baseline  = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        PIT.gripsFrequence     = PIT.gripsFrequence';
        
        % mob_effort
        modulators.CS.CSp      = PIT.gripsFrequence(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.CS.CSm      = PIT.gripsFrequence(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.CS.Baseline = PIT.gripsFrequence(strcmp ('Baseline', PIT.CONDITIONS));
        modulators.CS.REM      = RIM.BEHAVIOR.mobilized_effort;
        modulators.CS.PE       = PE.BEHAVIOR.mobilized_effort;
        
        %mean_centering mod
        cent_CSp    = mean(modulators.CS.CSp);
        cent_CSm    = mean(modulators.CS.CSm);
        cent_base   = mean(modulators.CS.Baseline);
        cent_REM    = mean(modulators.CS.REM);
        cent_PE     = mean(modulators.CS.PE);
        
        
        for j = 1:length(modulators.CS.CSp)
             modulators.CS.CSp(j)      = modulators.CS.CSp(j) - cent_CSp;
             modulators.CS.CSm(j)      = modulators.CS.CSm(j) - cent_CSm;
             modulators.CS.Baseline(j) = modulators.CS.Baseline(j) - cent_base;
        end
        
        for j = 1:length(modulators.CS.REM)
             modulators.CS.REM(j)      = modulators.CS.REM(j) - cent_REM;
        end
        
        for j = 1:length(modulators.CS.PE)
             modulators.CS.PE(j)       = modulators.CS.PE(j) - cent_PE;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets grips 
        onsets.grips.PIT           = PIT.ONSETS.grips;
        durations.grips.PIT       = zeros (length(onsets.grips.PIT),1);
        modulators.grips.PIT      = ones  (length(onsets.grips.PIT),1);

        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
  
    end
               
  
end
   