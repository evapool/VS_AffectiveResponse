function Intrumental_PartialExtinction(Trial,var,target,Nloops,wPtr) %modified on the 22.04.2015

var.RewardNumber = 1; % partial extinction
var.centralImage = var.GeoImage; % neutral image for instrumental

for nTrial = 1:length(Trial)
    
    %%%TRIAL START
    Time1 = GetSecs; % initializing clock
    trigger = CreateTrigger(var);
    ResultsPartialExtinction.TrialOnset(1,nTrial) = TriggerStart(trigger,var); % send trigger and record time
    ResultsPartialExtinction.TriggerOnset (1,nTrial) = trigger;
    WaitSecs(0.03);
    TriggerEnd(var);
    
    %%Variable initialization 
    rewardcount = 0;% variable to count rewarded responses
    
    A = [1;2;3;4;5;6;7;8;9;10];
    idxa = randperm(numel(A));
    a = A(idxa(1:1));
    
    
    %%% FIRST LOOP
    drift1 = GetSecs();
    mobforce1 = pressingNoReward (a,Nloops,var,wPtr);
    var.drift = GetSecs - drift1; 
    
    %%% SECOND LOOP: special 1 s window during which the response is rewarded
    [mobforce2,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var,wPtr);
    ResultsPartialExtinction.tValveOpenR(1,nTrial) = tValveOpen;
    ResultsPartialExtinction.tValveCloseR(1,nTrial) = tValveClose;
    var.RewardWindowDuration1 = RewardWindowDuration;
    
    %%% THIRD LOOP: % wait until the 12 s are finished without rewarding the reposnses
    drift1 = GetSecs();
    c = (11 - a);
    mobforce3 = pressingNoReward (c,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift; 
    
    %%% end of the loops 
    Time2 = GetSecs;
    
    %%% ITI
    ResultsPartialExtinction.onsetITI (nTrial) = GetSecs - var.time_MRI;
    ResultsPartialExtinction.triggerITIonset (1,nTrial) = trigger;
    ResultsPartialExtinction.ITI (nTrial) = DisplayITI (var, wPtr, nTrial);
    
    % record value of riminder
    
    Mobilizedforce = [mobforce1; mobforce2;mobforce3];
    ResultsPartialExtinction.mobilizedforce(:,nTrial) = Mobilizedforce;
    ResultsPartialExtinction.TrialDuration (nTrial) = Time2-Time1;
    ResultsPartialExtinction.Trial (nTrial) = nTrial (1,:);
    ResultsPartialExtinction.RewardedResponses (nTrial) = rewardcount;
    ResultsPartialExtinction.FirstRewardTime (nTrial) = a;
    ResultsPartialExtinction.drift (nTrial)= var.drift;
    ResultsPartialExtinction.RewardWindowDuration1(nTrial) = var.RewardWindowDuration1;
    save(var.resultFile, 'ResultsPartialExtinction', '-append');% We store after each trial to prevet data loss
    
end

end