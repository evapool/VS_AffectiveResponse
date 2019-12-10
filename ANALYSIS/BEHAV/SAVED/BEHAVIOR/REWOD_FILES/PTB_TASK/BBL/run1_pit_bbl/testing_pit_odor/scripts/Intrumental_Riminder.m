function  Nloops = Intrumental_Riminder(Trial,var,target,wPtr) %% % modified on the 22.04.2015

var.RewardNumber = 2; % this could be 2 for riminder 1 for partial extinvtion and 0 for extinction
var.centralImage = var.GeoImage; % neutral Image for instrumental

for nTrial = 1:length(Trial)
    
    Time1 = GetSecs; % initializing clock
    trigger = CreateTrigger(var);
    ResultsRimind.TrialOnset(1,nTrial) = TriggerStart(trigger,var); % send trigger and record time
    ResultsRimind.TriggerOnset (1,nTrial) = trigger;
    WaitSecs (0.03);
    TriggerEnd (var);
    %%%%%%%%%%%%%%%% Variable initialization %%%%%%%%%%%%%%%%%%%%%%
    rewardcount = 0;% variable to count rewarded responses
    
    % first reward window
    if Trial(nTrial) == 1
        a = 1; %manually fix the time at 1 for the first trial for the familiarization to get the timing variable I'm interest in
    elseif Trial(nTrial) ~= 1;
        A = [1;2;3;4;5];
        idxa = randperm(numel(A));
        a = A(idxa(1:1));
    end
    
    %second reward window
    B = [1;2;3;4;5];
    idxb = randperm(numel(B));
    b = B(idxb(1:1));
    
    %%% FIRST LOOP
    if nTrial == 1 % if this is the first trial then record the number of measures the computer takes in
        drift1 = GetSecs();
        [mobforce1,Nloops] = calibrationLoop (var,a,wPtr);
        var.drift = GetSecs - drift1;
    elseif nTrial ~= 1
        drift1 = GetSecs();
        mobforce1 = pressingNoReward (a,Nloops,var,wPtr);
        var.drift = GetSecs - drift1;
    end
    
    %%% SECOND LOOP: special 1 s window during which the response is rewarded
    [mobforce2,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var, wPtr);
    ResultsRimind.tValveOpenR1(1,nTrial) = tValveOpen;
    ResultsRimind.tValveCloseR1(1,nTrial) = tValveClose;
    var.RewardWindowDuration1 = RewardWindowDuration;
    
    %%% THIRD LOOP
    drift1 = GetSecs();
    mobforce3 = pressingNoReward (b,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;
    
    %%% FOURTH LOOP: special 1 second window during which the response is rewarded
    [mobforce4,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var,wPtr);
    ResultsRimind.tValveOpenR2(1,nTrial) = tValveOpen;
    ResultsRimind.tValveCloseR2(1,nTrial) = tValveClose;
    var.RewardWindowDuration2 = RewardWindowDuration;
    
    %%% FIFTH LOOP:
    % wait until the 12 s are finished without rewarding the response
    drift1 = GetSecs();
    c = (10 - (a+b));
    mobforce5 = pressingNoReward (c,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;
    ResultsRimind.drift(nTrial) = var.drift ;
    ResultsRimind.TrialDuration(nTrial) = GetSecs-Time1;
    
    %%% ITI
    ResultsRimind.OnsetITI (nTrial) = GetSecs - var.time_MRI;
    ResultsRimind.ITI (nTrial) = DisplayITI (var, wPtr, nTrial);  % minimal ITI = 1.5; maximal ITI; = 8.5; average ITI = 8 adjusted to have a 20 s trial
    
    % record value of riminder
    Mobilizedforce = [mobforce1;mobforce2;mobforce3;mobforce4;mobforce5];
    ResultsRimind.mobilizedforce(:,nTrial) = Mobilizedforce;
    ResultsRimind.Trial(nTrial) = nTrial (1,:);
    ResultsRimind.RewardedResponses(nTrial) = rewardcount;
    ResultsRimind.FirstRewardTime(nTrial) = a;
    ResultsRimind.SecondRewardTime(nTrial) = b + 1 + c;
    ResultsRimind.RewardWindowDuration1(nTrial) = var.RewardWindowDuration1;
    ResultsRimind.RewardWindowDuration2(nTrial) = var.RewardWindowDuration2;
    
    save(var.resultFile, 'ResultsRimind', '-append');% We store after each trial to prevet data loss
end
end