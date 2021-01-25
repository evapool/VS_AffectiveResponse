function GLM_between_getOnsets()

% intended for REWOD hedonic reactivity
% get onsets for model with 2st level covariates
% Duration =1 

% Created by David Munoz, verified by Eva R Pool


%% define paths

cd ~
home = pwd;
homedir = [home '/REWOD'];

homedir = [home '/mountpoint2'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/ForPaper');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-between';

task          = {'hedonic'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name));

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
        % Get onsets and durations for start
        onsets.start       = ONSETS.start;
        durations.start    = DURATIONS.start;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for odor valveopen
        onsets.odor.reward      = ONSETS.smell(strcmp ('chocolate', CONDITIONS));
        onsets.odor.neutral     = ONSETS.smell(strcmp ('neutral', CONDITIONS));
        onsets.odor.control     = ONSETS.smell(strcmp ('empty', CONDITIONS));
        
        %get durations
        durations.odor.reward    = DURATIONS.smell(strcmp ('chocolate', CONDITIONS));
        durations.odor.neutral   = DURATIONS.smell(strcmp ('neutral', CONDITIONS));
        durations.odor.control   = DURATIONS.smell(strcmp ('empty', CONDITIONS));
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and duration questions
        
        onsets.liking            = ONSETS.liking;
        durations.liking         = DURATIONS.liking;
        
        onsets.intensity         = ONSETS.intensity;
        durations.intensity      = DURATIONS.intensity;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        cd (subjdir)
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations')
    end
    
    
end


end
