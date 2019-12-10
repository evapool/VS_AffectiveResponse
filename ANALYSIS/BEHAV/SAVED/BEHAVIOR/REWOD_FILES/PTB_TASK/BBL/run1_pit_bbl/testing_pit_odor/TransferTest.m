cdfunction TransferTest % Script for Transfer test 21.05.2015 for BBL room

% PIT procedure in three phases:
% phase 1: rimider of the instrumental learning
% phase 2: partial extinction
% phase 3: Pavlovian instrumetnal transfer

% trigger coding system
% odor = 2 % coded on Channel 2
% Rimidner = 4 % coded on channel 3
% partial extinction = 8; coded on channel 4
% PIT = 16; coded on channel 5
% CS+ = 32 (+16); coded on channel 6
% CS- = 64 (+16); coded on channel 7
% baseline = 128 (+16); coded on channel 8

% Channel 1 is kept for the MRI (thus no odd number are used in the
% triggers)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRELIMINATY STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL;% Check for Opengl compatibility, abort otherwise:
KbName('UnifyKeyNames');% Make sure keyboard mapping is the same on all supported operating systems
KbCheck; WaitSecs(0.1); GetSecs;% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are loaded and ready

%%%%%%%%%%%%%%%%%% Prepare experiment structure %%%%%%%%%%%%%%%%%%%%%%%%%%%

var.filepath = MakePathStruct();
cd(var.filepath.scripts);
var.experimentalSetup = str2num(input('Are the pyhsiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
%var.instruction = str2num(input('Play the instructions? (1 = French or 2 = English) ','s'));
var.instruction =1;


%%%%%%%%%%%%%%%%% Insert participant's and collection day data%%%%%%%%%%%%%

% Create the file where storing the results
[resultFile, participantID] = createResultFile(var);
resultFile = fullfile (var.filepath.data,resultFile); %to save the the file in the data directory
var.resultFile = resultFile;

% Counterbalance the images order according to the participant ID
var.list = counterBalanceCS(participantID);
data.list = var.list;

% Date and time informations
data.SubDate= datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
data.SubHour= datestr(now, 13); % Use datestr to get the time in the format hh:mm:ss
save(var.resultFile,'data');% We save immediately the session's informations

%%%%%%%%%%%%%%%%%%%%%%%%%% Load list of variable %%%%%%%%%%%%%%%%%%%%%%%%%%
target.side = 1;
target.stim = 2;
var.odorTrigger = 2;
var.odorDuration = 2;
var.sideISI = 1; %right or left according to the setting %
%%%%%%%%%%%%%%%%%%%%%%%%%% Write instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.instruction == 1 %instruction in French
    
    var.instruction1 = 'Dans cette partie de l''?tude, nous vous demanderons ? nouveau de presser le capteur de force\n\n afin de d?clencher la lib?ration d''une odeur de chocolat\n\n\n\n';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression';
    var.instructionB = 'Ensuite, Nous vous demanderons \n\n de presser avec votre force maximale sur le capteur de force';
    var.pressez = ' PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! \n ';
    var.tenez = ' TENEZ LE CAPTEUR DE FORCE SANS EXERCER AUCUNE PRESSION';
    var.calibrationEnd = 'La calibration est termin?e, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''?tude est terminin?e';
    var.wait = 'l''exp?rience va d?marrer...';
    
elseif var.instruction == 2 %instruction in English (here not really)
    
    var.instruction1 = 'Dans cette partie de l''?tude, nous vous demanderons ? nouveau de presser le capteur de force\n\n afin de d???clencher la lib???ration d''une odeur de chocolat\n\n\n\n Appuyez sur la barre ??? espace ??? pour continuer ??? lire les instructions';
    var.instruction2 = 'Cette t?che est compos?e de plusieurs items.\n\nChaque item dure 12 secondes environ. Pendant cette p???riode de temps, vous ???tes libre de\n\npresser le capteur de force quand vous voulez, ne soyez pas pr???occup???(e) par la vitesse avec\n\nlaquelle vous exercez les pressions. Durant ces 12 secondes, il y aura trois fen???tres\n\ntemporelles particuli???res de 1 seconde chacune qui apparaitront de mani???re al???atoire. Aucun \n\nsignal visuel ne vous indiquera la pr???sence de ces fen???tres temporelles, par contre si pendant \n\nces fen???tres temporelles particuli???res vous serez en train d''exercer une pression compl???te sur le\n\ncapteur de force, vous d???clencherez  la lib???ration d''une odeur de chocolat.\n\nEssayez d''utiliser votre intuition pour presser pendant les fen???tres temporelles et d???clencher\n\n l''odeur de chocolat !\n\nEntre deux items, il y aura une pause pendant laquelle une croix de fixation sera affich???e ???\n\nl''???cran. A ce moment, vous devrez fixer la croix et relaxer votre main.\n\n\n\n Appuyez sur la barre ??? espace ??? pour commencer l''exp???rimentation en tant que telle ';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression';
    var.instructionB = 'Ensuite, Nous vous demanderons \n\n de presser  avec votre force maximale sur le capteur de force\n\n\n Appuyez sur la barre ??? espace ??? quand vous ???tes pr???t(e) ??? commencer';
    var.pressez = 'PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! \n ';
    var.tenez = 'Tenez le capteur de force sans exercer aucune pression';
    var.calibrationEnd = 'La calibration est termin?e, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''?tude est termin?e';
    var.wait = 'l''exp?rience va d?marrer...';
end


%%%%%%%%%%%% Set the comunication with physiological set up %%%%%%%%%%%%%%%

if var.experimentalSetup
    
    config_io; % Set parallel port in the BBL room
    outp(57392, 0);
        
    openDevice; %Open device for handgrip
    configureAD(0,1) % configure devie for hand grip
    
    %comport = str2num(input('Enter COMPORT olfactometer','s')); % to insert the right comport each time
    comport = 6;% In the BBL room the COMPORT is 6 not necessary to insert it manually each time
    oInit(comport,true); % Open Olfacto library
    
end
%%%%%%%%%%%%%%%%%%%%%% Open comunication with PTB %%%%%%%%%%%%%%%%%%%%%%%%%

PsychDefaultSetup(1);% Here we call some default settings for setting up PTB
screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen if necessary
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]); %from the left; from the top; up to the right; up to the bottom
black=BlackIndex(wPtr);
white=WhiteIndex(wPtr);

%%%%%%%%%%%%%%% Setting parameters and preparing varibles %%%%%%%%%%%%%%%%%

var.trigTarget  = 2;
% For the geometrical images
var.GeoImage = imread('Image1.jpg');% read the jpg images
CSplus = imread('CSplus.jpg');
Csminu = imread('CSminu.jpg');
Baseli = imread('Baseli.jpg');

wPtrRect = Screen('Rect',wPtr); % referece rect is the total window
ImageRect = [0 0 200 200];% sizes of the images (automatically re-sized later)
var.dstRect = CenterRect(ImageRect,wPtrRect);% put the image at the center of the screen automaticall

% For the theromometer
var.thermometerImage = imread ('TermometroON.jpg');

% Create variable to automatically adapt the images to width and hight of
% the screen
width = wPtrRect(3);
var.hight = wPtrRect(4);

% Create variable to coordinate for the "mercury feedback"
var.fl = width/18.5 ; % from the left
ft = var.hight/3.02; % from the top
var.tr = width/12.5; % up to the right
var.tb = var.hight/1.1477; % up to the buttum
var.Twidth = width/7.5; % for the theromometer

%%% Display the instructions
showInstruction(wPtr, var.instruction1);
WaitSecs(0.4);
KbWait(-1);


echo off all % Prevents MATLAB from reprinting the source code when the program runs

%HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% calibrate handgrip %%%%%%%%%%%%%%%%%%%%%%%%%%
[var] = calibrateHandgrip(var,wPtr);
data.maximalforce = var.maximalforce;
data.minimalforce = var.minimalforce;

save(var.resultFile,'data','-append'); %save minimal and maximal force

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstruction (wPtr,var.wait);
triggerscanner = 0;

while ~triggerscanner
    [down secs key d] = KbCheck(-1);
    if (down == 1)
        if strcmp('5%',KbName(key)); %% 5 is the fMRI message saying it starts...
            triggerscanner = 1;
        end
    end
    WaitSecs(.01);
end

var.time_MRI = GetSecs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           START THE PIT PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Phase 1: INSTRUMENTAL RIMINDER % 1 minute
var.phase = 1;
TriggerRiminder = [1;2;3]; %!keep this as a vector and not a value
ITI = [7.5; 8; 8.5]; % with these values the minimal ITI = 1.5; maximal
%ITI; = 8.5; average ITI = 8 and the trial will always be 20 s long in
%total

%TriggerRiminder = [1];
%ITI = [7.5];
randomIndex = randperm(length(ITI));
var.ITI = ITI (randomIndex);

Nloops = Intrumental_Riminder(TriggerRiminder,var,target,wPtr);

%% Phase 2: PARTIAL EXTINCTION % 2 minutes
var.phase = 2;
Trial = [1;2;3;4;5;6]; % !keep this as a vector and not a value
ITI = [7.5; 7.5; 8; 8; 8.5; 8.5];
%Trial = [1];
%ITI = [7.5];
randomIndex = randperm(length(ITI));
var.ITI = ITI (randomIndex);

Intrumental_PartialExtinction(Trial,var,target,Nloops,wPtr);
%% Phase 3: PIT
var.phase = 3;

%define PIT characteristics
var.blockSize = 3;  %  miniblocks of three repetitions
var.RewardNumber = 0; % administered under extinction

for tt = 1:5
    
    var.CSs = ['CSplus.jpg';'CSminu.jpg';'Baseli.jpg'];
    var.condition = [1; 2; 3]; % 1 = CS+ 2 = CS- 3 = baseline
    var.ordre = randperm (size(var.CSs,1));
    
    ITI = [7.5;8;8.5];
    randomIndex = randperm(length(ITI));
    var.ITI = ITI (randomIndex);
    
    %%% First miniblock: CS1
    %create trigger
    %var.trigger  = []; 5
    [mobilizedforceC1,ItemC1,onsetC1,triggerOnsetC1,onsetITIC1,ItemDurationC1,ITIC1,imageC1] = cycle (12, var, 1, Nloops,wPtr); % repete cycle three time
    C1.itemInfo = [ItemC1,onsetC1,triggerOnsetC1,onsetITIC1,ItemDurationC1,ITIC1,imageC1];
    C1.force = mobilizedforceC1;
    save(var.resultFile, 'C1', '-append'); %save intermediate results immetiatly to avoir data loss
    
    %%% Second miniblock: CS2
    %create trigger
    [mobilizedforceC2,ItemC2,onsetC2,triggerOnsetC2,onsetITIC2,ItemDurationC2,ITIC2,imageC2] = cycle (12, var, 2, Nloops,wPtr); %
    C2.itemInfo = [ItemC2,onsetC2,triggerOnsetC2,onsetITIC2,ItemDurationC2,ITIC2,imageC2];
    C2.force = mobilizedforceC2;
    save(var.resultFile, 'C2', '-append'); %save intermediate results immetiatly to avoid data loss
    
    %%% Third miniblock: CS3
    %create trigger
    [mobilizedforceC3,ItemC3,onsetC3,triggerOnsetC3,onsetITIC3,ItemDurationC3,ITIC3,imageC3] = cycle (12, var, 3, Nloops,wPtr); %
    C3.itemInfo = [ItemC3,onsetC3,triggerOnsetC3,onsetITIC3,ItemDurationC3,ITIC3,imageC3];
    C3.force = mobilizedforceC3;
    save(var.resultFile, 'C3', '-append'); %save intermediate results immetiatly to avoid data loss
    
    % Save Results
    ResultsPIT.Item(:,:,tt) = [ItemC1, ItemC2, ItemC3];
    ResultsPIT.Image (:,:,tt) =[imageC1,imageC2,imageC3];
    ResultsPIT.Onset (:,:,tt) = [onsetC1, onsetC2, onsetC3];
    ResultsPIT.TriggerOnset (:,:,tt) = [triggerOnsetC1, triggerOnsetC2, triggerOnsetC3];
    ResultsPIT.OnsetITI(:,:,tt) = [onsetITIC1, onsetITIC2, onsetITIC3];
    ResultsPIT.ItemDuration(:,:,tt) = [ItemDurationC1,ItemDurationC2,ItemDurationC3];
    ResultsPIT.ITI(:,:,tt) = [ITIC1,ITIC2,ITIC3];
    ResultsPIT.force(:,:,tt) = [mobilizedforceC1,mobilizedforceC2, mobilizedforceC3];
    
    save(var.resultFile, 'ResultsPIT', '-append');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           ENDING THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.TotalDuration = GetSecs - var.time_MRI;
save(var.resultFile,'data', '-append');% Final data

%%% Olfactometer and handgrip
if var.experimentalSetup
    oClose %olfacto
    closeDevice % handgrip
end

resetCSnames(var); % reset the images names so that the folder is ready for the next participant

showInstruction(wPtr, var.InstructionEndExperimentation); % end instructions
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');%Close comunication PTB
ShowCursor;

end