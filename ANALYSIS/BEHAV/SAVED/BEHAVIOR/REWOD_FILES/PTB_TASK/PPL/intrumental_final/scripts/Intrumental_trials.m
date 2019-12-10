function  Intrumental_trials (Nloops, Trial,var,target,wPtr) %% % modified on the 06.05.2015 by Eva

var.RewardNumber = 2; % this could be 2 for  learning and riminder 1 for partial extinvtion and 0 for extinction
var.centralImage = var.GeoImage; % neutral Image for instrumental

for nTrial = 1:length(Trial)
    
    Time1 = GetSecs; % initializing clock
    trigger = var.trigPhase;
    ResultsInstru.TrialOnset(1,nTrial) = TriggerStart(trigger,var); % send trigger and record time
    WaitSecs(0.03);
    TriggerEnd(var);
    ResultsInstru.TriggerOnset (1,nTrial) = trigger;
    
    %%%%%%%%%%%%%%%% Variable initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rewardcount = 0;% variable to count rewarded responses
    
    A = [1;2;3;4;5];
    idxa = randperm(numel(A));
    a = A(idxa(1:1));
    
    %second reward window
    B = [1;2;3;4;5];
    idxb = randperm(numel(B));
    b = B(idxb(1:1));
    
    %%%%%%%%%%%%%%%%%     TRIAL PROCEDURE     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% FIRST LOOP
    drift1 = GetSecs();
    mobforce1 = pressingNoReward (a,Nloops,var,wPtr);
    var.drift = GetSecs - drift1;
    
    
    %%% SECOND LOOP: special 1 s window during which the response is rewarded
    [mobforce2,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var, wPtr);
    ResultsInstru.tValveOpenR1(1,nTrial) = tValveOpen;
    ResultsInstru.tValveCloseR1(1,nTrial) = tValveClose;
    var.RewardWindowDuration1 = RewardWindowDuration;
    
    %%% THIRD LOOP
    drift1 = GetSecs();
    mobforce3 = pressingNoReward (b,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;
    
    %%% FOURTH LOOP: special 1 second window during which the response is rewarded
    [mobforce4,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var,wPtr);
    ResultsInstru.tValveOpenR2(1,nTrial) = tValveOpen;
    ResultsInstru.tValveCloseR2(1,nTrial) = tValveClose;
    var.RewardWindowDuration2 = RewardWindowDuration;
    
    %%% FIFTH LOOP:
    % wait until the 12 s are finished without rewarding the response
    drift1 = GetSecs();
    c = (10 - (a+b));
    mobforce5 = pressingNoReward (c,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;
    ResultsInstru.drift(nTrial) = var.drift ;
    ResultsInstru.TrialDuration(nTrial) = GetSecs-Time1;
    
    %%% ITI
    ResultsInstru.OnsetITI (nTrial) = GetSecs - var.time_MRI;
    ResultsInstru.ITI (nTrial) = DisplayITI (var, wPtr, nTrial);  % minimal ITI = 1.5; maximal ITI; = 8.5; average ITI = 8 adjusted to have a 20 s trial
    
    % record value of instrumental learning
    Mobilizedforce = [mobforce1;mobforce2;mobforce3;mobforce4;mobforce5];
    ResultsInstru.mobilizedforce(:,nTrial) = Mobilizedforce;
    ResultsInstru.Trial(nTrial) = nTrial (1,:);
    ResultsInstru.RewardedResponses(nTrial) = rewardcount;
    ResultsInstru.FirstRewardTime(nTrial) = a;
    ResultsInstru.SecondRewardTime(nTrial) = b + 1 + c;
    ResultsInstru.RewardWindowDuration1(nTrial) = var.RewardWindowDuration1;
    ResultsInstru.RewardWindowDuration2(nTrial) = var.RewardWindowDuration2;
    
    save(var.resultFile, 'ResultsInstru', '-append');% We store after each trial to prevet data loss
end
end