function [time,SendTrigger_t] = SendTrigger (trigger,var) % modified 21.05.2015 for BBL room

% this function has been adapted for the MRI lab

startT = GetSecs;
time = GetSecs - var.time_MRI; % time_MRI is  define in the main function
data_out = trigger; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    
    outp(57392, data_out);
    WaitSecs (0.03);
    outp(57392,0);
    
end

SendTrigger_t = GetSecs()-startT;

end