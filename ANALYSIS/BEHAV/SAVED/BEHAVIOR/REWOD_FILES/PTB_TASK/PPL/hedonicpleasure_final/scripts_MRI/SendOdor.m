function [tValve, oCommit_t] = SendOdor (trigger,var)

startT = GetSecs();
tValve = GetSecs - var.time_MRI; % time_MRI is define in the main function
data_out = trigger; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    outp(57392, data_out);
    
    oCommit(); % release odor
    
    outp(57392,0);
end

timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end

oCommit_t = GetSecs()-startT;
end