function SendTrigger (trigger,var) % modified on the 23.04.2015

if var.experimentalSetup
    
        data_out = trigger; % trigger signaling when the odor is relased
        io32(var.ioObj,hex2dec('378'),data_out);
  
end
    end