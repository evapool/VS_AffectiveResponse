function  Nloops = Intrumental_Training(Trial,var,target,wPtr) %% % modified on the 28.04.2015 by Eva

% This function is only for explanatory proposes it does not recored any
% value

var.RewardNumber = 2; % this could be 2 for riminder 1 for partial extinvtion and 0 for extinction
var.centralImage = var.GeoImage; % neutral Image for instrumental

for nTrial = 1:length(Trial)
    
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
        [~,Nloops] = calibrationLoop (var,a,wPtr);
        var.drift = GetSecs - drift1;
    elseif nTrial ~= 1
        drift1 = GetSecs();
        pressingNoReward (a,Nloops,var,wPtr);
        var.drift = GetSecs - drift1;
    end
    
    %%% SECOND LOOP: special 1 s window during which the response is rewarded
    pressingReward (Nloops,rewardcount,target,var, wPtr);
    
    %%% THIRD LOOP
    drift1 = GetSecs();
    pressingNoReward (b,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;
    
    %%% FOURTH LOOP: special 1 second window during which the response is rewarded
    pressingReward (Nloops,rewardcount,target,var,wPtr);
    
    %%% FIFTH LOOP:
    % wait until the 12 s are finished without rewarding the response
    drift1 = GetSecs();
    c = (10 - (a+b));
    pressingNoReward (c,Nloops,var,wPtr);
    var.drift = (GetSecs - drift1) + var.drift;

    %%% ITI
    ITI = var.ITI(nTrial);  % minimal ITI = 1.5; maximal ITI; = 8.5; average ITI = 8 adjusted to have a 20 s trial
    Cross = '+';
    DrawFormattedText(wPtr, Cross, 'center', 'center', [0 0 0]);
    Screen('Flip', wPtr);
    WaitSecs(ITI);
    
end
end