function h = initTask(h)

Screen('Preference', 'VisualDebuglevel', 3);
h.verbose = 0;
KbName('UnifyKeyNames');

% add path to helper functions
addpath(fullfile(pwd,'..','helpers'));
addpath(fullfile(pwd,'..','helpers','3rdparty'));
addpath(fullfile(pwd,'..','..','..','3rdParty','io64'));

% set up the various devices to be used
switch h.mode
    case 2 % SU at Cedars
        h.useCedrus       = 2;
        h.useEyelink      = 1;
    case 1
        h.useCedrus       = 0;
        h.useEyelink      = 0;
    case 0 % debug
        h.useCedrus       = 0;
        h.useEyelink      = 0;
end

% are there any stuck keys on the keyboard that should be disabled?
if ~h.useCedrus
    h.disableKeys = [];
    % on some laptops, keys need to be disabled for proper KbCheck functioning
    if ~isempty(h.disableKeys)
        DisableKeysForKbCheck(h.disableKeys);
    end
end

% configure io
if h.mode==2
    config_io;
end

% set up the key mapping
if h.useCedrus == 1 % 6 in a row
    h.escKey     = 8;
    h.key1       = 2;
elseif h.useCedrus == 2
    h.escKey     = 6;
    h.key1       = 4;
elseif h.useCedrus == 0
    h.escKey     = KbName('ESCAPE');
    h.triggerKey = KbName('5%');
    h.key1       = KbName('1!');
end

%% parameters
h.initFixDur = 5;
h.endFixDur  = 5;

% display parameters
h.crossSize     = 15;  % size of fixation cross
h.frameSize     = 500; % size of frame
h.bgColor       = [0 0 0];
h.fgColor       = [255 255 255];
h.textSize      = 60;

h.filePrefix    = [h.subject,'_BangYoureDeadFull_',num2str(h.mode),'_'];
logDir = fullfile(pwd,'..','logs');
if ~exist(logDir,'dir'),
    mkdir(logDir);
end
[h.fidLog,h.fname,h.timestampStr] = openLogfile(h.filePrefix,fullfile(pwd,'..','logs'));
h.saveFile        = fullfile([h.fname,'.mat']);

%% LOAD THE MOVIE PRIOR TO STARTING THE PTB SCREEN
h.usePsychAudio = 1;

h = getStimDir(h);
h.stimDir = fullfile(h.stimDir,'BangYoureDead');
if h.playMovie
    h.movieFile  = fullfile(h.stimDir,'movie','full.mov');
    fprintf('Loading movie!...\n');
    fprintf('\t video... \t');
    tic
    % the PTB3 Video functions do not work on Windows
    % h.mov = Screen('OpenMovie', h.window, h.movieFile);
    % instead, we'll need to read the movie frame by frame with Matlab's VideoReader and make textures on the fly
    % open video object and read total number of frames
    vidObj        = VideoReader(h.movieFile);
    h.movieWidth  = vidObj.Width;
    h.movieHeight = vidObj.Height;
    h.frameRate   = vidObj.FrameRate;
    
    h.startFrame = 422;
    h.startTime  = h.startFrame/h.frameRate;
    
    % shortScenes: two rows, [start;end]
    h.startShort = [474,2319,4062,4575, 9283,10717,11670,16635,17904,18120];
    h.endShort   = [883,2473,4490,7395,10423,11606,12331,16694,17973,18668];
    % isOld and isNew: frames used for the new/old experiment
    h.isOld = [658,741,784,2337,4318,4648,4826,4938,4988,5184,...
        5250,5421,5521,5694,6126,6496,6621,6910,7195,7385,...
        9297,9459,9485,9599,9759,9824,10104,10385,10788,10869,...
        11159,11454,11967,12086,16647,17934,18146,18178,18338,18553];
    h.isNew = [1022,1165,1258,1470,1638,1654,2135,3042,3586,3756,...
        3800,3900,3980,7451,7626,7723,8337,8535,8578,8624,...
        8701,8741,8803,8874,8983,9064,9183,10489,12385,12508,...
        12606,12678,13104,13195,14298,15130,16823,16888,17413,17441];
    
    nFrames  = 18813;
    h.mov    = struct('tex',cell(1,nFrames-h.startFrame+1),'cdata',cell(1,nFrames-h.startFrame+1));
    k = 1;
    while hasFrame(vidObj)
        tmp = readFrame(vidObj);
        if k>=h.startFrame
            if mod(k,floor(nFrames/10))==1
                fprintf('%d%%',round(k/floor(nFrames/100)));
            elseif mod(k,floor(nFrames/100))==1
                fprintf('.');
                %    DrawFormattedText(h.window,sprintf('LOADING VIDEO\n\n%d%% complete', ceil(100*k/nFrames)),'center','center',[255 255 255],42);
                %                 Screen('Flip',h.window);
            end
            % memory saving trick: since grayscale, only put 1 frame in memory
            h.mov(k-h.startFrame+1).cdata = tmp(:,:,1);
        end
        k = k+1;
    end
    % correct nFrames if it was wrong
    h.nFrames = length(h.mov);
    h.mov = h.mov(1:h.nFrames);
    elapsed = toc;
    fprintf('done in %.3fs\n',elapsed);
    
    %% loading audio
    if ~h.usePsychAudio
    fprintf('\t audio... \t');
    %     DrawFormattedText(h.window,'LOADING AUDIO','center','center',[255 255 255],42);
    %     Screen('Flip',h.window);
    tic
    % open audio object
    %     switch h.mode
    %         case 1
    %             if exist(strrep(h.movieFile,'.avi','_filt.wav'),'file'),
    %                 [y, fs] = audioread(strrep(h.movieFile,'.avi','_filt.wav'));
    %             else
    %                 [y, fs] = audioread(h.movieFile);
    %                 y = filter_audio(strrep(h.movieFile,'.avi','_filt.wav'),y,fs);
    %             end
    %         otherwise
    if exist(strrep(h.movieFile,'.avi','.wav'),'file'),
        [y, fs] = audioread(strrep(h.movieFile,'.avi','.wav'));
    else
        [y, fs] = audioread(h.movieFile);
        audiowrite(strrep(h.movieFile,'.avi','.wav'),y,fs);
    end
    %     end
    h.fs = fs;
    % need to add ~100ms of sound to the beginning of the audio file
    % to compensate for intractable delay...
    h.audioPrefixLength = ceil(fs*0.116);%ceil(fs*0.116);
    if h.audioPrefixLength>0
    y = [zeros(h.audioPrefixLength,2);y];
    end
    % crop beginning according to h.startTime
    y = y(round(h.startTime*fs):end,:);
    % remove second channel (which contains ticks)
    y(:,1) = y(:,2);
    
    h.audObj = audioplayer(y,fs);
    clear y fs
    elapsed = toc;
    fprintf('done in %.3fs\n',elapsed);
    
    % initialize sound
    % may take 0.5s or so to start
    play(h.audObj);
    pause(h.audObj);
    else
        % Read WAV file from filesystem:
        [y, fs] = psychwavread(strrep(h.movieFile,'.avi','.wav'));
        h.fs = fs;
        % crop beginning according to h.startTime
        y = y(round(h.startTime*fs):end,:);
        % remove second channel (which contains ticks)
        y(:,1) = y(:,2);
        nrchannels = size(y,2); % Number of rows == number of channels.
        % Perform basic initialization of the sound driver:
        InitializePsychSound;
        % This returns a handle to the audio device:
        try
            % Try with the 'freq'uency we wanted:
            h.audObj = PsychPortAudio('Open', [], [], 0, fs, nrchannels);
        catch
            % Failed. Retry with default frequency as suggested by device:
            fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', fs);
            fprintf('Sound may sound a bit out of tune, ...\n\n');
            psychlasterror('reset');
            h.audObj = PsychPortAudio('Open', [], [], 0, [], nrchannels);
        end
        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', h.audObj, y');
    end
else
    h.movieWidth  = 640;
    h.movieHeight = 480;
end



%%
% open a PTB window
switch h.mode
    case 0
        Screen('Preference', 'ConserveVRAM', 64);
        Screen('Preference','SkipSyncTests',1);
    otherwise
        [a,b,c,d]=Screen('Preference','SyncTestSettings', 0.005,50,0.3,5);
end

screenNumber = max(Screen('Screens'));
if screenNumber<0 % does this ever happen??
    screenNumber = 0;
end

if h.mode>0
    h.window = Screen('OpenWindow',screenNumber,0);
else
    h.window = Screen('OpenWindow',screenNumber,0,[0 0 800 600]);
end
Screen('TextSize',h.window,h.textSize);
Screen('TextFont',h.window,'Arial');
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAlphaBlending', 0);

[h.w,h.h] = WindowSize(h.window);
h.W       = h.w/2;
h.H       = h.h/2;

HideCursor;

if h.useCedrus
    h.handle=[];
    while isempty(h.handle)
        try
            h.handle=initCEDRUS;
        catch
            CedrusResponseBox('CloseAll');
            h.handle=initCEDRUS;
        end
    end
end

if h.playMovie
    fprintf('\t buffering movie...');
    tic
    % how many frames to buffer
    h.nBuffered = 30;
    h.frameTime = (0:(h.nFrames-1))/h.frameRate;
    % load first 1s
    h.loaded = zeros(1,h.nFrames);
    for iFrame = 1:h.nFrames,
        if iFrame <= h.nBuffered,
            h.mov(iFrame).tex    = Screen('MakeTexture', h.window, repmat(h.mov(iFrame).cdata,[1 1 3]));
            h.loaded(iFrame) = 1;
        else
            h.mov(iFrame).tex = 0;
            h.loaded(iFrame) = 0;
        end
    end
    elapsed = toc;
    fprintf('done in %.1fs\n',elapsed);
end

h.displayWidth  = 8/10 * h.w;
h.displayHeight = h.displayWidth / h.movieWidth * h.movieHeight;
if h.displayHeight > h.h, % accomodates different aspect ratio for the presentation screen
    h.displayHeight = 8/10 * h.h;
    h.displayWidth  = h.displayHeight / h.movieHeight * h.movieWidth;
end
h.rect    = [h.W-ceil(h.displayWidth/2) h.H-ceil(h.displayHeight/2) h.W+ceil(h.displayWidth/2) h.H+ceil(h.displayHeight/2)];

%% instructions
% movie watching
img = imread(fullfile(h.stimDir,'instructions','instructionsFull_SU2.png'));
[h.instrH,h.instrW,~] = size(img);
h.instrDispW  = 8/10 * h.w;
h.instrDispH = h.instrDispW / h.instrW * h.instrH;
if h.instrDispH > h.h, % accomodates different aspect ratio for the presentation screen
    h.instrDispH = 8/10 * h.h;
    h.instrDispW  = h.instrDispH / h.instrH * h.instrW;
end
h.instrRect = [h.W-ceil(h.instrDispW/2) h.H-ceil(h.instrDispH/2) h.W+ceil(h.instrDispW/2) h.H+ceil(h.instrDispH/2)];
h.instr(1)  = Screen('MakeTexture', h.window, img);

h.eyeLinkMode  = h.useEyelink;

%% triggers
h.TTL.startExp     = 61;
h.TTL.endExp       = 66;
h.TTL.startInstr   = 51:59;
h.TTL.keypress     = 33;

h.TTL.startFix     = 1;
h.TTL.endFix       = 10;

h.TTL.video        = 4;

% mark beginng and end of scenes included in short version
h.TTL.startShort   = 5;
h.TTL.endShort     = 6;

% mark frames shown during the new/old experiment
h.TTL.isOld     = 7;
h.TTL.isNew     = 8;

if h.eyeLinkMode
    dummymode = 0;
    %eyeLink_setup_PTB3(h.window, dummymode, ['ST' h.timestampStr(end-5:end)]);
    el = EyelinkInitDefaults(h.window);
    if ~EyelinkInit(dummymode,1),
        fprintf('Eyelink Init aborted.\n');
        cleanup;
        return
    end
    [~,vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n',vs);
    h.edfFile = ['ST',strrep(h.timestampStr(end-7:end),'-','')];
    Eyelink('Openfile',h.edfFile);
    EyelinkDoTrackerSetup(el);
    success=EyelinkDoDriftCorrection(el);
    eye_used = Eyelink('EyeAvailable');
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE;
    end
    Eyelink('StartRecording');
    Eyelink('Message', h.fname);
end

h.endSignal = 0;
h.curFrame  = 1;

priorityLevel=MaxPriority(h.window);
Priority(priorityLevel);

sendTTLsJD(h.TTL.startExp,0,h);


