function TestVAN()

var.experimentalSetup = 1;
var.time_MRI = GetSecs();

%%%%%%%%%%%%  Experimental Set Up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Set comunication with olfactometer
var.comport = str2num(input('Enter COMPORT olfactometer ','s'));
oInit(var.comport,true); % Open Olfacto library

config_io;
outp(57392, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i = 1:13
    
    oStimulus(1,i); % select odor
    
    trigger = 2+i;
    SendOdorTEST (trigger);% Odor Release and record time
    
    WaitSecs(2.5);
    
    oInterStimulus(1); % select ISI air
    
    trigger = 32+i;
    SendOdorTEST (trigger);% release ISI air and record time
    
    WaitSecs(60);
    
end

oClose;

    function SendOdorTEST (trigger)
        
        outp(57392, trigger);
        oCommit(); % release odor
        outp(57392,0);
    end

end