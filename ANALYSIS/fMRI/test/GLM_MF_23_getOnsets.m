function GLM_MF_23_getOnsets()

% like GLM-MF-09a but zscores parametric modulators


% last modified on April 2019

% dbstop if error

%% define paths

%homedir = '/home/evapool/PAVMOD/';
homedir = '/Users/evapool/mountpoint/PAVMOD';

mdldir        = fullfile (homedir, '/DATA/brain/MODELS/SPM');
sourcefiles   = fullfile(homedir, '/DATA/behavior');
addpath (genpath(fullfile(homedir,'/ANALYSIS/my_tools')));

ana_name          = 'GLM-MF-23';
runs              = {'01';'02';'03'};

subj              = {'01'; '03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'};
devalued_outcome  = [  3     3    4    3    4    3     4    3    4   3    4    3    4    3    4    3    4    3    4    4    3    3    4    3    4    3    4    3    4]; % 3 = sweet, 4 = savory

%% create folder
mkdir (fullfile (mdldir, ana_name))

%% extract and save data
for j = 1:length(runs)
    
    runX      = char(runs(j));
    
    for  i=1:length(subj)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load participants data
        subjX=char(subj(i));
        devalued_US = devalued_outcome (i);
        
        subjdir=fullfile(mdldir, ana_name,  ['sub-' subjX],'timing');
        mkdir (subjdir)
        
        cd (sourcefiles)
        behavfile = ['PAV_fMRI_', subjX, '_' runX(end) '.mat'];
        fprintf('participant number: %s run number:  %s \n', subj{i}, runs{j})
        disp(['file ' num2str(i) ' ' behavfile]);
        load (behavfile);
        
        %% FOR SPM
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS
        onsets.CS           = getMeasurebyAspect(data.onsets.CS, data, 10, devalued_US);
        
        CSM                 = onsets.CS.CSm;
        
        onsets.CS = rmfield(onsets.CS,'CSm');
        % we need to split the CSm in two
        idx=randperm(20);
        
        onsets.CS.CSm1      = sort(CSM (idx(1:10)));
        onsets.CS.CSm2      = sort(CSM (idx(11:20)));
        
        durations.CS.val    = zeros(length(onsets.CS.val),1);
        durations.CS.deval  = zeros(length(onsets.CS.deval),1);
        durations.CS.CSm1   = zeros(length(onsets.CS.CSm1),1);
        durations.CS.CSm2   = zeros(length(onsets.CS.CSm2),1);
        
        modulators.CS.val   = ones(length(onsets.CS.val),1);
        modulators.CS.deval = ones(length(onsets.CS.deval),1);
        modulators.CS.CSm1  = ones(length(onsets.CS.CSm1),1);
        modulators.CS.CSm2  = ones(length(onsets.CS.CSm2),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets and durations for CS
        onsets.ANT           = data.onsets.anticipation;
        durations.ANT        = zeros (length(onsets.ANT),1);
        modulators.ANT       = ones(length(onsets.ANT),1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets duration for US
        
        onsets.US     = data.onsets.US;
        durations.US  = zeros(length(data.durations.US),1);
        
        data.US_side(data.US_side==2)= 1; % code 1 reward
        data.US_side(data.US_side==0)= 0; % code 0 no reward
        modulators.US.reward  = data.US_side;
        
        if j == 3
            
            onsets.US     = data.onsets.US;
            durations.US  = zeros(length(data.durations.US),1);
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get onsets for the actual modor response
        onsets.ACTION_left     = data.onsets.US(strcmp('9(', data.behavior.USbutton)==1) + data.behavior.USRT(strcmp('9(', data.behavior.USbutton)==1);
        durations.ACTION_left  = zeros(length(onsets.ACTION_left),1);
        modulators.ACTION_left = ones(length(onsets.ACTION_left),1);
        
        onsets.ACTION_right    = data.onsets.US(strcmp('6^', data.behavior.USbutton)==1) + data.behavior.USRT(strcmp('6^', data.behavior.USbutton)==1);
        durations.ACTION_right = zeros(length(onsets.ACTION_right),1);
        modulators.ACTION_right= ones(length(onsets.ACTION_right),1);
        
        %% FOR FSL
        
        % go in the directory where data will be saved
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        cd (subjdir) % let's save all info in the participant directory
        
        % create text file with 3 colons: onsets, durations, paretric modulators
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
        name = {'CS';'ANT'; 'US'; 'ACTION_left'; 'ACTION_right'};
        
        for ii = 1:length(name)
            
            nameX = char(name(ii));
            
            if strcmp (nameX, 'CS') % for structure that contains modulators
                
                substr = {'val'; 'deval';'CSm1';'CSm2'};% specify the substructures names
                
                for iii = 1:length(substr)
                    substrX = char(substr(iii));
                    nameXX  = [nameX '_' substrX]; % name that combines the structure and the substructures
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX).(substrX)), num2cell(durations.(nameX).(substrX)), num2cell(modulators.(nameX).(substrX))];
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameX '_' substrX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameXX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
            elseif strcmp (nameX, 'US') % for structure that contains modulators
                
                % first register the onset only (this will be the variable
                % the modulators will be orthogonalized to
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(ones(length(onsets.(nameX)),1))]; % put one as a modulator
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
                
                
                substr = {'reward'};% specify the substructures names
                
                
                for iii = 1:length(substr)
                    
                    substrX = char(substr(iii));
                    nameXX  = [substrX]; % name that combines the structure and the substructures
                    
                    % database with three rows of interest
                    database.(nameXX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX).(nameXX))]; % change the modulators value only
                    % save the database in a txt file
                    fid = fopen ([ana_name '_run-' runX '_' nameXX '.txt'],'wt');
                    formatSpec = '%d   %d   %d\n';
                    [nrows,~] = size(database.(nameX));
                    for row = 1:nrows
                        fprintf(fid,formatSpec,database.(nameXX){row,:});
                    end
                    fclose(fid);
                end
                
            else
                % database with three rows of interest %%%% ADD MODULATORS
                database.(nameX) = [num2cell(onsets.(nameX)), num2cell(durations.(nameX)), num2cell(modulators.(nameX))];
                % save the database in a txt file
                fid = fopen ([ana_name '_run-' runX '_' nameX '.txt'],'wt');
                formatSpec = '%d   %d   %d\n';
                [nrows,~] = size(database.(nameX));
                for row = 1:nrows
                    fprintf(fid,formatSpec,database.(nameX){row,:});
                end
                fclose(fid);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data
        
        mat_name = [ana_name '_run-' runX '_onsets'];
        save (mat_name, 'onsets', 'durations','modulators')
        
    end
    
end

end