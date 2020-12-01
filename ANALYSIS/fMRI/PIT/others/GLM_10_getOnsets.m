function GLM_10_getOnsets()

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

ana_name      = 'GLM-10';
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
        modulators.REM     = ones(length(RIM.DURATIONS.trialstart),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS FOR PE
        onsets.PE          = PE.ONSETS.trialstart;
        durations.PE       = PE.DURATIONS.trialstart;
        modulators.PE     = ones(length(PE.DURATIONS.trialstart),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute improvement index
        order = repmat(1:3,1,length(PIT.CONDITIONS)/3)'; % get the presentation order
        
        RPE = nan(length(PIT.CONDITIONS),1);
        VV = nan(length(PIT.CONDITIONS),1); %odor value vector
        
        VCSplus   =  1;
        VCSminus  =  -1;
        VBaseline =  0;
        
        
        V0       =  (VCSplus + VCSminus + VBaseline) / 3;
        
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
        
        for t = 1:length(order)
            
            presentation = order(t);
            odor         = PIT.CONDITIONS{t};
            
            if presentation == 1
                
                if strcmp ('CSplus',  odor)
                    RPE(t) = VCSplus - V0;
                    
                elseif strcmp ('CSminus',  odor)
                    RPE(t) = VCSminus - V0;
                    
                elseif strcmp ('Baseline',  odor)
                    RPE(t) = VBaseline - V0;
                    
                end
                
            else
                
                if strcmp ('CSplus',  odor)
                    RPE(t) = VCSplus - VCSplus;
                    
                elseif strcmp ('CSminus',  odor)
                    RPE(t) = VCSminus - VCSminus;
                    
                elseif strcmp ('Baseline',  odor)
                    RPE(t) = VBaseline - VBaseline;
                    
                end
            end
            
        end
        

        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations

        onsets.PIT.CSp          = PIT.ONSETS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        onsets.PIT.CSm          = PIT.ONSETS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        onsets.PIT.Baseline     = PIT.ONSETS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        onsets.PIT.conc         = vertcat(onsets.PIT.CSp, onsets.PIT.CSm);
        
        [onsets.PIT.conc, Idx] = sort(onsets.PIT.conc);
        
        
        durations.PIT.CSp       = PIT.DURATIONS.trialstart(strcmp ('CSplus', PIT.CONDITIONS));
        durations.PIT.CSm       = PIT.DURATIONS.trialstart(strcmp ('CSminus', PIT.CONDITIONS));
        durations.PIT.Baseline  = PIT.DURATIONS.trialstart(strcmp ('Baseline', PIT.CONDITIONS));
        durations.PIT.conc      = vertcat(durations.PIT.CSp, durations.PIT.CSm);
        
        durations.PIT.conc     = durations.PIT.conc(Idx,:);
        
        
        %mod for value
        modulators.PIT.CSp.VV  = VV (strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.VV  = VV (strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.conc.VV = vertcat(modulators.PIT.CSp.VV, modulators.PIT.CSm.VV);
        
        modulators.PIT.conc.VV     = modulators.PIT.conc.VV(Idx,:);
        modulators.PIT.conc.VV     = meanCenter(modulators.PIT.conc.VV);
        
        %mod for rpe
        modulators.PIT.CSp.RPE  = RPE(strcmp ('CSplus', PIT.CONDITIONS));
        modulators.PIT.CSm.RPE  = RPE (strcmp ('CSminus', PIT.CONDITIONS));
        modulators.PIT.conc.RPE = vertcat(modulators.PIT.CSp.RPE, modulators.PIT.CSm.RPE);
        
        modulators.PIT.conc.RPE  = modulators.PIT.conc.RPE(Idx,:);        
        modulators.PIT.conc.RPE  = meanCenter(modulators.PIT.conc.RPE);
        

        
        
        
        %% FOR FSL
        
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) %save all info in the participant directory
        
        
        % FOR FSL and covariates!
        % create text file with 3 colons: onsets, durations, parametric
        % modulators (!!!! this is not what it does)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name = {'REM'; 'PE'; 'PIT'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'PIT')  % for structure that contains substuctures
                substr = {'conc'};% specify the substructures names
                subsubstr = {'VV'; 'RPE'}; % specify the subsubstructures names
                
                
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