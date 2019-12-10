function [time] = TriggerEnd (var) % modified on the 22.04.2015
        time = GetSecs - var.time_MRI; % time_MRI is  define in the main function   
        
        if var.experimentalSetup % variable define in the main function
            io32(var.ioObj,hex2dec('378'),0);% set trigger = 0
        end
        
    end