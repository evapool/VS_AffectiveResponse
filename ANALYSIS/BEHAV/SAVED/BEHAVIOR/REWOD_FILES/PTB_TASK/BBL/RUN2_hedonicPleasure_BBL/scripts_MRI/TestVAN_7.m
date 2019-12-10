% testing odor


function TestVAN()

var.experimentalSetup = 1;



%%%%%%%%%%%%  Experimental Set Up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if var.experimentalSetup
    
    % Set comunication with olfactometer
    var.comport = str2num(input('Enter COMPORT olfactometer ','s'));
    oInit(var.comport,true); % Open Olfacto library
    
    % Set comunication with paralle port
    
    config_io;
    outp(57392, 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        EXPERIMENTAAL PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize variables



for i = 1:13
    
    oStimulus(1,i); % select odor
    
    
    SendOdor ((i+20),var);% Odor Release and record time
    
    WaitSecs(2);
    
    
    oInterStimulus(1); % select ISI air
    
    
    SendOdor((i+50),var);% release ISI air and record time
    
    WaitSecs(12);
    
    
end


end