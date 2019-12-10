    function [mobforce,rewardcount,RewardWindowDuration,tValveOpen,tValveClose] = pressingReward (Nloops,rewardcount,target,var,wPtr)   % modified on the 22.04.2015
        
        tValveClose = NaN;
        tValveOpen = NaN;
        lines = 1*Nloops;
        tic;
        mfexp = 0;
        mobforce = nan (lines,1);
        Start = GetSecs;
        
        while toc <= 1
            
            mfexp = mfexp + 1;
            
            if mfexp > length(mobforce); %to be surethat it does not ad an extraloop
                break
            end
            %read and record mobilized force
            val = readAD();
            mobforce(mfexp) = val ;
            
            %to set the maximal value as a value that change randomly
            % between 50% and 70%
            idxv = randperm(numel(var.v));
            var.ValMax = var.v (idxv (1:1));
            
            % compute variable for online feedback and Diplay feedback on the screen
            ft = OnlineFeedback(var,val);
            displayFeedback(var,ft,wPtr);
            
            if mobforce(mfexp) >= var.ValMax
                
                % Display reward and Send Odor
                if var.experimentalSetup
                    oStimulus(target.side,target.stim);% select odor
                    tValveOpen = SendOdor (var);% Odor Release and record time
                end
                
                displayReward(var,ft,wPtr);
                WaitSecs(var.odorDuration);
                
                if var.experimentalSetup
                    oInterStimulus(var.sideISI); % select ISI air
                    tValveClose = SendOdor (var);% release ISI air and record time
                end
                
                displayReward(var,ft,wPtr);
                WaitSecs(2);
                % Update the results variables
                rewardcount = rewardcount + 1;

                break;
            end
            
        end
        End = GetSecs;
        RewardWindowDuration = End - Start;
    end