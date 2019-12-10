function SetParallelPort()
    var.ioObj = io32;
    status = io32(var.ioObj);
    
    if status ~= 0
        disp('inpout32 installation failed!')
    else
        disp('inpout32 (re)installation successful.')
    end
    
    io32(var.ioObj,hex2dec('378'),0); % Set condition code to zero, adress =
    hex2dec('378')
end