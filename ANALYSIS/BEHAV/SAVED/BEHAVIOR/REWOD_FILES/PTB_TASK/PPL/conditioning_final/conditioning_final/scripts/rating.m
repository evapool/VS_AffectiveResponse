function [ratingResult, imagesName] = rating(images, wPtr, rect)
    % Randomize the image list
    randomIndex = randperm(length(images)); 
    images = images(randomIndex);
    
    % Initialize the rating results array
    resultArraysLength = length(images);
    ratingResult = zeros(1, resultArraysLength).';
    imagesName = cell(1, resultArraysLength).';
    
    for i = 1:length(images)
        ratingResult(i) = ratingImage(images{i}, wPtr, rect);
        imagesName{i} = images{i};
        showCross(wPtr);
    end

end



function showCross(wPtr)

    cross = '+';
    Screen('TextStyle', wPtr, 1);
    DrawFormattedText(wPtr, cross, 'center', 'center', [0 0 0]);
    Screen('Flip', wPtr);
    % Wait a random time between 1 and 2 secs.
    csPresentationTime = 1+rand(1,1);
    WaitSecs(csPresentationTime);
 
end