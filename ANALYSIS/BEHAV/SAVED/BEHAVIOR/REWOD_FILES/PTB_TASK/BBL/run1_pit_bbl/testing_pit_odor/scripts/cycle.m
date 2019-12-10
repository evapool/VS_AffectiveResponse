function [mobilizedforce,Item,onset,triggerOnset,onsetITI,ItemDuration,ITI,image] = cycle (duration,var,nCycle,Nloops,wPtr)

Item = nan (1,var.blockSize);
onset = nan (1,var.blockSize);
onsetITI = nan (1,var.blockSize);
ItemDuration = nan (1,var.blockSize);
ITI = nan (1,var.blockSize);
image = cell (1,var.blockSize);
mobilizedforce = nan((duration*Nloops),var.blockSize);
triggerOnset =nan (1,var.blockSize);
var.nCycle = nCycle; % put it in the var structure to compute trigger

for nTrial = 1:var.blockSize % first cycle (miniblock) of three presentation
    
    triggerOnset(nTrial) = CreateTrigger(var);
    onset(nTrial) = TriggerStart(triggerOnset,var);
    WaitSecs(0.03);
    TriggerEnd(var);
    
    %%% prepare variables
    CS = imread(var.CSs(var.ordre(:,nCycle),:));
    image (nTrial) = {var.CSs(var.ordre(:,nCycle),:)};
    var.centralImage = CS;
    
    %trigger = Trigger (nTrial);%Send and define Trigger
    
    %%% play extinction cycle
    drift1 = GetSecs();
    mobilizedforce (:,nTrial) = pressingNoReward (duration,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1); % this is for the Display ITI function
    ItemDuration (nTrial) = var.drift;
    
    %%% ITI
    onsetITI (nTrial) = GetSecs - var.time_MRI;
    ITI(nTrial) = DisplayITI (var, wPtr,nTrial);
    Item (nTrial) = nTrial (1,:);
    
end

end