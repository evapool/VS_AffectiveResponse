function GLM_23_getOnsets()

% intended for REWOD HED
% get onsets for model with Expected value 1st level modulator
% Duration =1
% Model on ONSETs (start, +odor + 2*questions)
% last modified on OCT 2020 by Eva

%% define paths

cd ~
home = pwd;
homedir = [home '/mountpoint2'];


mdldir        = fullfile (homedir, '/DERIVATIVES/GLM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');

ana_name      = 'GLM-23';
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
    load (behavfile);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute the RPE
    
    order = repmat(1:3,1,length(CONDITIONS)/3)'; % get the presentation order
    
    RPE = nan(1,length(CONDITIONS));
    VV  = nan(1,length(CONDITIONS));
    
    Vchoco   = 1;
    Vneutral = 0;
    Vempty   = 0;
    
    V0       =  (Vchoco + Vneutral + Vempty) / 3;
    
    for t = 1:length(order)
        
        presentation = order(t);
        odor         = CONDITIONS{t};
        
        if presentation == 1
            
            if strcmp ('chocolate',  odor)
                RPE(t) = Vchoco - V0;
                VV(t)  = V0;
                
            elseif strcmp ('neutral',  odor)
                RPE(t) = Vneutral - V0;
                VV(t)  = V0;
                
            elseif strcmp ('empty',  odor)
                RPE(t) = Vneutral - V0;
                VV(t)  = V0;
                
            end
            
        else
            
            if strcmp ('chocolate',  odor)
                RPE(t) = Vchoco - Vchoco;
                VV(t)  = Vchoco;
                
            elseif strcmp ('neutral',  odor)
                RPE(t) = Vneutral - Vneutral;
                VV(t)  = Vneutral;
                
            elseif strcmp ('empty',  odor)
                RPE(t) = Vempty - Vempty;
                VV(t)  = Vempty;
                
            end
        end
        
    end
    
    
    %% FOR SPM
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for start
    onsets.start          = ONSETS.start;
    durations.start       = DURATIONS.start; % donethis is a rapid fix that needs to be changed
    modulators.start.VV   = VV';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get onsets and durations for odor valveopen
    onsets.odor             = ONSETS.smell;
    
    %get durations
    durations.odor          = DURATIONS.smell;
    
    %modulators
    modulators.odor         = ones (length(onsets.odor),1);
    %modulators.odor.lik     = BEHAVIOR.liking;
    %modulators.odor.int     = BEHAVIOR.intensity;
    
    %mean_centering mod
    %RPE
    cent_int  = mean(modulators.start.VV);
    
    for j = 1:length(modulators.start.VV)
        modulators.start.VV(j)  = modulators.start.VV(j) - cent_int;
    end
    
    
    
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
    cd (subjdir) % let's save all info in the participant directory
    
    
    %% FOR FSL #uncoment if you want to use FSL#
    % create text file with 3 colons: onsets, durations and 2
    % parametric modulators for each parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    name = {'start'; 'odor'; 'liking'; 'intensity'};
    
    for ii = 1:length(name)
        
        nameX = char(name(ii));
        
        if strcmp (nameX, 'start')  % for structure that contains substuctures
            substr = {'VV'};% specify the substructures names
            for iii = 1:length(substr)
                substrX = char(substr(iii));
                nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
                % database with three rows of interest
                database.(nameXX) = num2cell(modulators.(nameX).(substrX));
                % save the database in a txt file
                fid = fopen ([ana_name '_task-' taskX '_' nameX '_' substrX '.txt'],'wt');
                formatSpec = '%f\n';
                [nrows,~] = size(database.(nameXX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameXX){row,:});
                end
                fclose(fid);
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
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save data
    mat_name = [ana_name '_task-' taskX '_onsets'];
    save (mat_name, 'onsets', 'durations', 'modulators')
end



end

