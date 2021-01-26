function GLM_PIT_validation_getOnsets()

% intended for REWOD PIT

% get onsets for the PIT task validation
% Durations =0 (stick function)
% Simplified model on ONSETs of each grip

% Created by David Munoz, verified by Eva R Pool

%% define paths
cd ~
home = pwd;
homedir = [home '/mountpoint2'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/ForPaper');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-PIT-validation';
task          = {'PIT'};
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
    % Get onsets grips 
    onsets.grips.REM         = RIM.ONSETS.grips;
    durations.grips.REM      = zeros(length(onsets.grips.REM),1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets grips 
    onsets.grips.PE           = PE.ONSETS.grips;
    durations.grips.PE        = zeros (length(onsets.grips.PE),1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets grips 
    onsets.grips.PIT          = PIT.ONSETS.grips;
    durations.grips.PIT       = zeros (length(onsets.grips.PIT),1);
  
    % go in the directory where data will be saved
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd (subjdir) %save all info in the participant directory
    % save data
    mat_name = [ana_name '_task-' taskX '_onsets'];
    save (mat_name, 'onsets', 'durations')
    
end


end