function [time,SendTrigger_t] = SendTrigger (trigger,var)
startT = GetSecs;
time = GetSecs - var.time_MRI; % time_MRI is  define in the main function
data_out = trigger; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    io32(var.ioObj,hex2dec('378'),data_out);
    
    WaitSecs (0.03);
    
    io32(var.ioObj,hex2dec('378'),0);% set trigger = 0
end


SendTrigger_t = GetSecs()-startT;

end