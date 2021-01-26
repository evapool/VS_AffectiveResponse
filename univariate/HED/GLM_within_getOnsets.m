function GLM_within_getOnsets()

% intended for REWOD hedonic reactivity

% get onsets for model with 1st level modulators
% Model on ONSETs (start, 2*odor 1odor less air + 2*questions)

% Created by David Munoz, verified by Eva R Pool

%% define paths
cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-within';
task          = {'hedonic'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name));

%% extract and save data

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
    % Get onsets and durations for start
    onsets.start       = ONSETS.start;
    durations.start    = DURATIONS.start;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for odor valveopen
    onsets.odor.reward      = ONSETS.smell(strcmp ('chocolate', CONDITIONS));
    onsets.odor.neutral     = ONSETS.smell(strcmp ('neutral', CONDITIONS));
    onsets.odor.control     = ONSETS.smell(strcmp ('empty', CONDITIONS));
    onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral);
    
    [onsets.odor.conc, Idx] = sort(onsets.odor.conc);
    
    %get durations
    durations.odor.reward   = DURATIONS.smell(strcmp ('chocolate', CONDITIONS));
    durations.odor.neutral  = DURATIONS.smell(strcmp ('neutral', CONDITIONS));
    durations.odor.control  = DURATIONS.smell(strcmp ('empty', CONDITIONS));
    durations.odor.conc     = vertcat(durations.odor.reward, durations.odor.neutral);
    
    durations.odor.conc = durations.odor.conc(Idx,:);
    
    %mod for liking
    modulators.odor.reward.lik  = BEHAVIOR.liking (strcmp ('chocolate', CONDITIONS));
    modulators.odor.neutral.lik = BEHAVIOR.liking (strcmp ('neutral', CONDITIONS));
    modulators.odor.control.lik = BEHAVIOR.liking (strcmp ('empty', CONDITIONS));
    
    modulators.odor.conc.lik = vertcat(modulators.odor.reward.lik, modulators.odor.neutral.lik);
    
    %mean_centering mod
    cent_lik  = mean(modulators.odor.conc.lik);
    
    for j = 1:length(modulators.odor.conc.lik)
        modulators.odor.conc.lik(j)  = modulators.odor.conc.lik(j) - cent_lik;
    end
    
    modulators.odor.conc.lik = modulators.odor.conc.lik(Idx,:);
    
    
    %mod for intensity
    modulators.odor.reward.int  = BEHAVIOR.intensity (strcmp ('chocolate', CONDITIONS));
    modulators.odor.neutral.int = BEHAVIOR.intensity (strcmp ('neutral', CONDITIONS));
    modulators.odor.control.int = BEHAVIOR.intensity (strcmp ('empty', CONDITIONS));
    
    modulators.odor.conc.int = vertcat(modulators.odor.reward.int, modulators.odor.neutral.int);
    
    %mean_centering mod
    cent_int  = mean(modulators.odor.conc.int);
    
    for j = 1:length(modulators.odor.conc.int)
        modulators.odor.conc.int(j)  = modulators.odor.conc.int(j) - cent_int;
    end
    
    modulators.odor.conc.int = modulators.odor.conc.int(Idx,:);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and duration questions
    onsets.liking            = ONSETS.liking;
    durations.liking         = DURATIONS.liking;
    modulators.liking        = ones (length(onsets.liking),1);
    
    onsets.intensity         = ONSETS.intensity;
    durations.intensity      = DURATIONS.intensity;
    modulators.intensity     = ones (length(onsets.intensity),1);
    
    
    % go in the directory and save
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
    cd (subjdir) % let's save all info in the participant directory
    mat_name = [ana_name '_task-' taskX '_onsets'];
    save (mat_name, 'onsets', 'durations', 'modulators')
end



end

