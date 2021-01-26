function GLM_within_control_getOnsets()

% intended for REWOD hedonic

% get onsets for model with change and improvement and liking and intesity as 1st level modulator
% Model on ONSETs (start, 2*odor 1odor less air + 2*questions)

% Created by David Munoz, verified by Eva R Pool

%% define paths
cd ~
home = pwd;
homedir = [home '/REWOD'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM/');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-within-control';
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
    PP = nan(length(CONDITIONS),1); 
    
    Vchoco   = 1;
    Vneutral = 2;
    Vempty   = 3;
    
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
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for start
    onsets.start       = ONSETS.start;
    durations.start    = DURATIONS.start;
    modulators.start   = ones (length(onsets.start),1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for odor 
    
    onsets.odor.reward      = ONSETS.smell(strcmp ('chocolate', CONDITIONS));
    onsets.odor.neutral     = ONSETS.smell(strcmp ('neutral', CONDITIONS));
    onsets.odor.control     = ONSETS.smell(strcmp ('empty', CONDITIONS));
    onsets.odor.conc        = vertcat(onsets.odor.reward, onsets.odor.neutral);
    
    [onsets.odor.conc, Idx] = sort(onsets.odor.conc);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get durations
    durations.odor.reward    = DURATIONS.smell(strcmp ('chocolate', CONDITIONS));
    durations.odor.neutral   = DURATIONS.smell(strcmp ('neutral', CONDITIONS));
    durations.odor.control   = DURATIONS.smell(strcmp ('empty', CONDITIONS));
    durations.odor.conc      = vertcat(durations.odor.reward, durations.odor.neutral);
    
    durations.odor.conc = durations.odor.conc(Idx,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % mod for liking
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %mod for absolute change
    modulators.odor.reward.chAbs  = ChAbs (strcmp ('chocolate', CONDITIONS));
    modulators.odor.neutral.chAbs = ChAbs (strcmp ('neutral', CONDITIONS));
    modulators.odor.control.chAbs = ChAbs (strcmp ('empty', CONDITIONS));
    
    modulators.odor.conc.chAbs= vertcat(modulators.odor.reward.chAbs, modulators.odor.neutral.chAbs);
    
    %mean_centering mod
    cent_chAbs = mean(modulators.odor.conc.chAbs);
    
    for j = 1:length(modulators.odor.conc.chAbs)
        modulators.odor.conc.chAbs(j)  = modulators.odor.conc.chAbs(j) - cent_chAbs;
    end

    modulators.odor.conc.chAbs = modulators.odor.conc.chAbs(Idx,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %mod for improvement change
    modulators.odor.reward.ch  = Ch (strcmp ('chocolate', CONDITIONS));
    modulators.odor.neutral.ch = Ch (strcmp ('neutral', CONDITIONS));
    modulators.odor.control.ch = Ch (strcmp ('empty', CONDITIONS));
    
    modulators.odor.conc.ch= vertcat(modulators.odor.reward.ch, modulators.odor.neutral.ch);
    
    %mean_centering mod
    cent_ch = mean(modulators.odor.conc.ch);
    
    for j = 1:length(modulators.odor.conc.ch)
        modulators.odor.conc.ch(j)  = modulators.odor.conc.ch(j) - cent_ch;
    end
    
    modulators.odor.conc.ch = modulators.odor.conc.ch(Idx,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and duration questions
    onsets.liking            = ONSETS.liking;
    durations.liking         = DURATIONS.liking;
    
    onsets.intensity         = ONSETS.intensity;
    durations.intensity      = DURATIONS.intensity;
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save data
    cd (subjdir) % let's save all info in the participant directory
    mat_name = [ana_name '_task-' taskX '_onsets'];
    save (mat_name, 'onsets', 'durations', 'modulators')
end


end
