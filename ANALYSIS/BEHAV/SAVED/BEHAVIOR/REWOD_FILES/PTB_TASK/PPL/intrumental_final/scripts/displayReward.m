function displayReward(var,ft,wPtr)
        reward = ('*');
        tex1=Screen('MakeTexture', wPtr, var.GeoImage);
        tex2=Screen('MakeTexture', wPtr, var.thermometerImage);
        Screen('DrawTexture', wPtr, tex1,[],var.dstRect);
        Screen('DrawTexture', wPtr, tex2,[],[0 0 var.Twidth  var.hight]);
        Screen('FillRect', wPtr, [225 0 0], [var.fl,ft,var.tr,var.tb]);
        DrawFormattedText(wPtr, reward, 'center', 'center', 0);
        Screen(wPtr, 'Flip');
        Screen('Close', tex1);
        Screen('Close', tex2);
    end