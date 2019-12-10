function time = cleanKeyboardMemory % attention this function takes up until 15 ms to be executed
    startT = GetSecs();
    [keyisdown, ~,~] = KbCheck;
    while (keyisdown == 1) % if already down, wait for release: this loop cleans the keyboard memory
        [keyisdown, ~, ~] = KbCheck;
        WaitSecs(0.001);
    end;
    time = GetSecs()-startT; % to record the time this function takes and adapt the ITI
end