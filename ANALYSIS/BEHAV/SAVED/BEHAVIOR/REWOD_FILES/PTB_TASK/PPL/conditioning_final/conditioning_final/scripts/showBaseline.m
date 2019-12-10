    function showBaseline(wPtr, rect,var)
    
        % Import the bas image and create texture
        basImage = imread('Baseli.jpg');
        thermoImage = imread('ThermeterOFF.jpg');
        basTexture = Screen('MakeTexture', wPtr, basImage);
        thermoTexture = Screen('MakeTexture', wPtr, thermoImage);
        
        % Show the baseline
        Screen('DrawTexture', wPtr, basTexture, [], CenterRect([0 0 200 200], rect));
        Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
        Screen('Flip', wPtr);    
        WaitSecs(12);
        
        % Close the no longer needed texture
        Screen('Close', basTexture);
        Screen ('Close',thermoTexture);
    end