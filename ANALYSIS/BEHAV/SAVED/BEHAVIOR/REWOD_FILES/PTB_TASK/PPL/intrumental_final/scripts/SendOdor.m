function [tValve] = SendOdor (var)

% get time
tValve = GetSecs - var.time_MRI; % time_MRI is define in the main function

% Send odor
data_out = var.trigTarget; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    io32(var.ioObj,hex2dec('378'),data_out);
    oCommit(); % release odor
    io32(var.ioObj,hex2dec('378'),0);% set trigger = 0
end

end