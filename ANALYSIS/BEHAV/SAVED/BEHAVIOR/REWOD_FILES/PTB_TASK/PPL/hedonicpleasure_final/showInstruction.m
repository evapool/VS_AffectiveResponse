function time = showInstruction(wPtr, instructionText)

startT = GetSecs();
% Screen settings
Screen('TextFont', wPtr, 'Arial');
Screen('TextSize', wPtr, 14);
Screen('TextStyle', wPtr, 1);

timer = GetSecs()-var.time_MRI;
    while timer < var.ref_end
        timer = GetSecs()-var.time_MRI;
    end
    
    time = GetSecs()-startT;

% Print the instruction on the window
DrawFormattedText(wPtr, instructionText, 'center', 'center', 0);
Screen(wPtr, 'Flip');

end