
    function mobforce = pressingNoReward (duration,Nloops,var,wPtr)
        
        lines = duration*Nloops;
        tic;
        mobforce = nan(lines,1);
        mfexp = 0;
        
        while toc <= duration
            
            mfexp = mfexp + 1;
            
            if mfexp > length(mobforce);% to be sure that it does not ad an extraloop
                break
            end
            
            %read and record mobilized force
            val = readAD();
            mobforce(mfexp) = val;
            
            %to set the maximal value as a value that change randomly
            % between 50% and 70%
            idxv = randperm(numel(var.v));
            var.ValMax = var.v (idxv (1:1));
            
            % compute variable for online feedback and Diplay feedback on the screen
            ft = OnlineFeedback(var,val);
            displayFeedback(var,ft,wPtr);
            
        end
    end