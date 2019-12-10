    function [neutralOdor,fileDoesNotExist] = selectNeutralOdor (referenceOdor,empthyOdor,var) %% modified on the 18.05.2015
        
    
    %%% the reference odor and the empthy odor are defined as the triggers
    %%% when the van open (var.trig)
    
    
        neutralOdor = 34; %define variable at the begining they will be changed by the function
        fileDoesNotExist = 0;
        
        cd(var.filepath.data); %go and check in the data file
        if exist(['hedonic' num2str(var.participantID) '_day1.mat'],'file') == 0;
            fileDoesNotExist = 1;
            cd(var.filepath.scripts)
            return
        end
        
        day1 = load (['hedonic' num2str(var.participantID) '_day1.mat']);%load the data of the day1 to select the most neutral odor
        
        matrix = [day1.data.odorTrigger, day1.data.liking, day1.data.intensity];
        matrix = sortrows (matrix,1);
        matrix = reshape(matrix(~isnan(matrix)),[],size(matrix,2)); %remove NaN from the matrix
        matrix (find(matrix == empthyOdor),:) = []; %% here the number of the empthy van has to be defined as an input of the function the evaluations of the empthy odor have to be removed
        
        
        trigger = accumarray(matrix(:,1),matrix(:,1),[],@mean); % identify which trigger the means refers to
        trigger = trigger(find(trigger~=0));
        liking = accumarray(matrix(:,1),matrix(:,2),[],@mean);% compute the mean for each condition
        liking = liking(find(liking~=0));
        intensity = accumarray(matrix(:,1),matrix(:,3),[],@mean);% compute the mean for each condition
        intensity = intensity(find(intensity~=0));
        
        %%% compute indexes of interest
        neutrality = abs(45-liking); % index computing how "neutral the odor has been perceived going toward the more negative to maximise the difference with the positive odor
        referenceIntensity = intensity(find(trigger == referenceOdor)); %% the number of the chocolate trigger has to be entered as an input in the final function
        
        if isempty(referenceIntensity) == 1;
            fileDoesNotExist = 1;
            referenceIntensity = 50;
        end
                   
        differentialIntensity = abs (intensity - referenceIntensity);  
        matrixToSelect = [trigger, neutrality, differentialIntensity]; % create a matrix with the index of interest
        matrixToSelect = sortrows (matrixToSelect, [2,3]); %sort the matrix first by neutrality and then by differential intensity
        matrixToSelect (find(matrixToSelect == referenceOdor),:) = []; %% here number of the chocolat odor has to be defined as an input of the function the evaluations of the chocolate odor have to be removed
        
        %%% select the neutral odor based on the index of interest
        
        neutralOdor = matrixToSelect (1,1);
        if differentialIntensity (1) >= 40 % this thrashold has been established by me.. maybe there is better way to do it
            neutralOdor = matrixToSelect (2,1);
            if differentialIntesity (2) >= differentialIntensity (1) % if the second most neutral odor is even less than the first one, then the first is kept
                neutralOdor = matrixToSelect (1,1);
            end
        end
        
        clear day1 % we do not want data from day1 to mess with the data collection of day 2
        cd(var.filepath.scripts); %return in the script folder for the rest of the experiment
    end 