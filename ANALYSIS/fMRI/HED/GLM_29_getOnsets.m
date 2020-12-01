function GLM_29_getOnsets()

% intended for REWOD hedonic reactivity
% like GLM-04 but with control modulater of improvement and change entered
% at the first level


%% define paths

cd ~
home = pwd;
homedir = [home '/mountpoint2'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-29';
%session       = {'second'};
task          = {'hedonic'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name));

%% extract and save data
%for j = 1:length(task) % this is only because we have one run per task

taskX      = char(task(1));
%sessionX  = char(session(j));

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
    load (behavfile)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute improvement index
    
    VV = nan(length(CONDITIONS),1); %odor value vector
    
    Vchoco   =  1;
    Vneutral = -0.5;
    Vempty   = -0.5;
    
    
    
    % recode smell in values
    for t = 1:length(CONDITIONS)
        
        odor         = CONDITIONS{t};
        if strcmp ('chocolate',  odor)
            VV(t) = Vchoco;
            
        elseif strcmp ('neutral',  odor)
            VV(t) = Vneutral;
            
        elseif strcmp ('empty',  odor)
            VV(t) = Vempty;
            
        end
        
    end
    
    % code change vector
    V0       = 0;
    Ch       = nan(length(CONDITIONS),1);
    
    for t = 1:length(VV)
        
        if t == 1
            Ch(t) = V0;
            VV(t) = V0;
        else
            
            if VV(t-1) < VV(t)
                Ch(t) = 1;
            elseif VV(t-1) > VV(t)
                Ch(t) = -1;
            elseif VV(t-1) == VV(t)
                Ch(t) = 0;
            end
            
        end
        
    end
    
    % compute preceptual propertis
    
    PP = nan(length(CONDITIONS),1); %odor value vector
    
    Vchoco   = 1;
    Vneutral = 2;
    Vempty   = 3;
    
    % recode smell in values
    for t = 1:length(CONDITIONS)
        
        odor         = CONDITIONS{t};
        if strcmp ('chocolate',  odor)
            PP(t) = Vchoco;
            
        elseif strcmp ('neutral',  odor)
            PP(t) = Vneutral;
            
        elseif strcmp ('empty',  odor)
            PP(t) = Vempty;
            
        end
        
    end
    
    
    ChAbs      = nan(length(CONDITIONS),1);
    P0 = 0.5;
    for t = 1:length(VV)
        
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
    
    

    
    %% FOR SPM
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for start
    onsets.start       = ONSETS.start;
    durations.start    = DURATIONS.start;
    modulators.start   = ones (length(onsets.start),1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for odor valveopen
    onsets.odor.reward      = ONSETS.smell(strcmp ('chocolate', CONDITIONS));
    onsets.odor.neutral     = ONSETS.smell(strcmp ('neutral', CONDITIONS));
    onsets.odor.control     = ONSETS.smell(strcmp ('empty', CONDITIONS));
    
    %get durations
    durations.odor.reward    = DURATIONS.smell(strcmp ('chocolate', CONDITIONS));
    durations.odor.neutral   = DURATIONS.smell(strcmp ('neutral', CONDITIONS));
    durations.odor.control   = DURATIONS.smell(strcmp ('empty', CONDITIONS));
    
%     %mod for improvement
%     modulators.odor.reward.Ch  = Ch (strcmp ('chocolate', CONDITIONS));
%     modulators.odor.neutral.Ch = Ch (strcmp ('neutral', CONDITIONS));
%     modulators.odor.control.Ch = Ch (strcmp ('empty', CONDITIONS));
%     
    
    %mod for change
    modulators.odor.reward.ChAbs  = ChAbs (strcmp ('chocolate', CONDITIONS));
    modulators.odor.neutral.ChAbs = ChAbs(strcmp ('neutral', CONDITIONS));
    modulators.odor.control.ChAbs = ChAbs (strcmp ('empty', CONDITIONS));
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and duration questions
    onsets.liking            = ONSETS.liking;
    durations.liking         = DURATIONS.liking;
    modulators.liking        = ones (length(onsets.liking),1);
    
    onsets.intensity         = ONSETS.intensity;
    durations.intensity      = DURATIONS.intensity;
    modulators.intensity     = ones (length(onsets.intensity),1);
    
    
    % go in the directory where data will be saved
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
    cd (subjdir) %save all info in the participant directory
    
    
    %% FOR FSL #uncoment if you want to use FSL#
    % Now we need it for second level covariates !
    
    % create text file with 3 colons: onsets, durations, paretric
    % modulators % for each parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    name = {'start'; 'odor'; 'liking'; 'intensity'};
    
    for ii = 1:length(name)
        
        nameX = char(name(ii));
        
        if strcmp (nameX, 'odor')  % for structure that contains substuctures
            substr = {'reward'; 'control'; 'neutral'};% specify the substructures names
            subsubstr = {'ChAbs'}; % specify the subsubstructures names
            for iii = 1:length(substr)
                substrX = char(substr(iii));
                for iiii =  1:length(subsubstr)
                    subsubstrX = char(subsubstr(iiii));
                    nameXX  = [nameX '_' substrX '_' subsubstrX]; % name that combines the structure and the substructures
                    % database with three rows of interest
                    %database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX).(subsubstrX))];
                    database.(nameXX) = num2cell(modulators.(nameX).(substrX).(subsubstrX));
                    % save the database in a txt file
                    fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '_' subsubstrX '.txt'],'wt');
                    %formatSpec = '%f\t%f\t%f\n';
                    formatSpec = '%f\n';
                    [nrows,~] = size(database.(nameXX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
            end
            
        else
            % database with three rows of interest %%%% ADD MODULATORS
            database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX))];
            % save the database in a txt file
            fid = fopen ([ana_name '_task-' taskX '_' nameX '.txt'],'wt');
            formatSpec = '%f\t%f\t%f\n';
            [nrows,~] = size(database.(nameX));
            for row = 1:nrows
                fprintf(fid,formatSpec,database.(nameX){row,:});
            end
            fclose(fid);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        mat_name = [ana_name '_task-' taskX '_onsets'];
        save (mat_name, 'onsets', 'durations', 'modulators')
        
        
    end
    
    %create folder for group covariate
    mkdir (fullfile (mdldir, char(task), ana_name, 'group_covariates'));
    
end
