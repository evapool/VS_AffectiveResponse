function runTask()
% play Full Bang You're Dead movie
% the patient has seen the short movie 4 times (2 x fMRI, 2 x hospital)
% some frames from the full movie have been shown to the patient during the
% new/old task (hospital runs)
% here
% Julien Dubois
% 08/12/2016 from BangYoureDead (short movie experiment)
dbstop if error

%% Get info %%
addpath(fullfile(pwd,'..','helpers','Bob_utils'));
h.subject   = ptb_get_input_string('\nEnter subject ID: ');
msg = '';
while isempty(msg),
    [~,msg] = system('hostname');
end
switch msg(1:(end-1))
    case 'DWA644104' % Julien's desktop Cedars (Windows 7)
        h.mode = 0; % debug mode
    case 'DWLA6600JK' % new stimulus laptop Cedars
        h.mode = 2; % cedars mode w/ Cedrus & Eyetracking
    case 'machine' % Julien's laptop (Ubuntu)
        h.mode = 0; % debug mode
    case 'Stim-PC' % MRI stimulus PC
        h.mode = 1; % debug mode
    otherwise
        h.mode      = ptb_get_input_numeric('\nEnter mode (0:debug, with movie; 1:MRI; 2:Cedars): ', [0 1 2]);
end
h.playMovie = 1;
h = initTask(h);

% sending TTL / write info to log file
sendTTLsJD(h.TTL.startExp,0,h);

if h.playMovie
    
    %% instructions for movie watching
    h = displayInstructions(h,1);
    if h.endSignal,endTask(h);return;end
    
%     if h.mode == 1
%         %% show waiting for experimenter screen
%         DrawFormattedText(h.window,'Waiting for experimenter...','center','center',[255 255 255],42);
%         Screen('Flip',h.window);
%     
%         %% WAIT FOR TRIGGER
%         [key,RT] = waitAndCheckKeys(h,inf,[h.escKey h.triggerKey],0);
%         sendTTLsJD(h.TTL.keypress,[key,RT],h)
%         if key == h.escKey,h.endSignal = 1;endTask(h);return;end
%     end
    h.startTime = GetSecs;
    
    prepare_fixationCross(h.window, [255 255 255],h.crossSize, h.W, h.H);
    Screen('Flip',h.window,0);
    sendTTLsJD(h.TTL.startFix,0,h);
    %% wait for h.initFixDur
    keys = waitAndCheckKeys(h,h.initFixDur - (GetSecs-h.startTime),h.escKey,1);
    if ~isempty(keys),h.endSignal = 1;endTask(h);return;end
    
    %% play movie!
    h = playmovie(h);
    if h.endSignal
        return
    end
    
    %% wait for h.endFixDur
    prepare_fixationCross(h.window, [255 255 255],h.crossSize, h.W, h.H);
    [~,startFIX] = Screen('Flip',h.window,0);
    sendTTLsJD(h.TTL.endFix,0,h);
    keys = waitAndCheckKeys(h,h.endFixDur - (GetSecs-startFIX),h.escKey,1);
    if ~isempty(keys),h.endSignal = 1;endTask(h);return;end
end

endTask(h);
