function GLM_08_getOnsets()

% intended for REWOD PIT
% get onsets for model with 2st level covariates
% Durations =1 (except grips)
% Model on ONSETs 3*CS with modulator
% adding a modulator of non interst for the improvement (?) and the
% absolute change
% last modified on NOV by Eva R. Pool

%% define paths

cd ~
home = pwd;
homedir = [home '/mountpoint2'];

mdldir        = fullfile (homedir, '/DERIVATIVES/GLM');
sourcefiles   = fullfile(homedir, '/DERIVATIVES/PREPROC');
mytools       = fullfile(homedir, '/CODE/ANALYSIS/fMRI/PIT/myfunctions');

addpath(mytools);

ana_name      = 'GLM-08';
%session       = {'second'};
task          = {'PIT'};
subj          = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};


%% create folder
mkdir (fullfile (mdldir, char(task), ana_name)); % this is only because we have one run per task

%% extract and save data
for j = 1:length(task)
    
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
        modulators.PE = meanCenter(modulators.PE);

        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PIT
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute improvement index
        
        VV = nan(length(PIT.CONDITIONS),1); %odor value vector
        
        VCSplus   =  1;
        VCSminus  = -0.5;
        VBaseline = -0.5;
        
        
        
        % recode smell in values
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
        
        % code change vector
        V0       = 0;
        Ch       = nan(length(PIT.CONDITIONS),1);
        
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
        
        
        
        onsets.PIT.CSp          = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.PIT.CSm          = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.PIT.Baseline     = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        durations.PIT.CSp       = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.PIT.CSm       = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.PIT.Baseline  = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        
        %-------------mob_effort (for nd level analysis)
        modulators.ndl.CSp.eff      = PIT.gripsFrequence(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.ndl.CSm.eff      = PIT.gripsFrequence(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.ndl.Baseline.eff = PIT.gripsFrequence(strcmp ('Baseline', PIT.CONDITIONS));
        
        % mean center
%         modulators.PIT.CSp.eff = meanCenter(modulators.PIT.CSp.eff);
%         modulators.PIT.CSm.eff = meanCenter(modulators.PIT.CSm.eff);
%         modulators.PIT.Baseline.eff = meanCenter(modulators.PIT.Baseline.eff);
        
        %--------------absolute change
        modulators.PIT.CSp.chAbs      = ChAbs(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.chAbs      =  ChAbs(strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.Baseline.chAbs =  ChAbs(strcmp ('Baseline', PIT.CONDITIONS));
        
        % mean center
        modulators.PIT.CSp.chAbs = meanCenter(modulators.PIT.CSp.chAbs);
        modulators.PIT.CSm.chAbs  = meanCenter(modulators.PIT.CSm.chAbs);
        modulators.PIT.Baseline.chAbs = meanCenter(modulators.PIT.Baseline.chAbs);
        
        
        %-------------- improvement (this I am not sure it makes sense)
%         modulators.PIT.CSp.ch      = Ch (strcmp ('CSplus', PIT.CONDITIONS));
%         modulators.PIT.CSm.ch      = Ch (strcmp ('CSminus', PIT.CONDITIONS));
%         modulators.PIT.Baseline.ch = Ch (strcmp ('Baseline', PIT.CONDITIONS));
%         
%         % mean center
%         modulators.PIT.CSp.ch = meanCenter(modulators.PIT.CSp.ch);
%         modulators.PIT.CSm.ch = meanCenter(modulators.PIT.CSm.ch);
%         modulators.PIT.Baseline.ch = meanCenter(modulators.PIT.Baseline.ch);
%         
        
        
        %% FOR FSL
        
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) %save all info in the participant directory
        
        
        % FOR FSL and covariates!
        % create text file with 3 colons: onsets, durations, parametric
        % modulators (!!!! this is not what it does)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'REM'; 'PE'; 'PIT';'ndl'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'PIT')  % for structure that contains substuctures
                substr = {'CSp'; 'CSm'; 'Baseline'};% specify the substructures names
                subsubstr = {'chAbs'}; % specify the subsubstructures names
                
                
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
                
            elseif strcmp (nameX, 'ndl')  % for structure that contains substuctures
                substr = {'CSp'; 'CSm'; 'Baseline'};% specify the substructures names
                subsubstr = {'eff'}; % specify the subsubstructures names
                
                
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
                % database with three rows of interest
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
    
    %create folder for group covariate
    mkdir (fullfile (mdldir, char(task), ana_name, 'group_covariates'));
    
    
end

end