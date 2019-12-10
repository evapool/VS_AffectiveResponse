function PavConditioning()%%RIMINDER FOR MRI ROOM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminary stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PsychDefaultSetup(1);% Here we call some default settings for setting up Psychtoolbox
AssertOpenGL;% Check for Opengl compatibility, abort otherwise:
KbName('UnifyKeyNames');% Make sure keyboard mapping is the same on all supported operating systems
KbCheck; WaitSecs(0.1); GetSecs;% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are l

%%%%%%%%%%%% Create the structure of the experiment %%%%%%%%%%%%%%%%%%%%%%%
var.filepath = MakePathStruct();
cd(var.filepath.scripts);

%var.experimentalSetup = str2num(input('Are the pyhsiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
var.experimentalSetup = 1;
%var.instruction = str2num(input('Play the instructions? (1 = French or 2 = English) ','s'));
var.instruction = 1;
%var.training = str2num (input('training ? (0 =  non, 1 = yes)','s'));
var.training = 1;

% Date and time informations
data.SubDate= datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
data.SubHour= datestr(now, 13); % Use datestr to get the time in the format hh:mm:ss

[var.resultFile, participantID] = createResultFile(var); % create results file for the participants

cd(var.filepath.data);
save (var.resultFile);
save(var.resultFile,'data','-append');% We save immediately the session's informations
cd(var.filepath.scripts);

var.list = counterBalanceCS(participantID); % we counterbalance the images order according to the participant ID

%%%%%%%%%%%%%%%%%%%%%%%%%% write instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if var.instruction == 1 %instruction in French
    
    var.TextGeneral = 'Dans cette partie de l''étude, vous verrez des images et sentirez des odeurs.\n\n Lorsque que vous verrez des images et que le signe « * » apparaîtra à l''écran,\n\n appuyez sur la touche «A» le plus rapidement possible.\n\n Ceci vous permettra de découvrir l''odeur associée à l''image.\n\n\n\n L''odeur délivrée ne dépend pas de la vitesse à laquelle vous appuyez sur la touche.\n\n En effet, si après 1 seconde vous n''avez pas appuyé sur la touche,\n\n l''odeur sera délivrée de toute manière. \n\n La vitesse à laquelle vous appuyez sur la touche\n\n permettra d''avoir une mesure de l''attention que vous portez à la tâche.\n\n\n\n Certaines images sont plus souvent associées avec certaines odeurs,\n\n ESSAYEZ DE DECOUVRIR QUELLES SONT CES ASSOCIATIONS ';
    var.TextTraining = 'Nous allons commencer avec un petit rappel de ce que vous avez fait hier.';
    var.WarningStart = 'L''entraînement est fini.\n\n Si vous avez des questions, vous pouvez les poser maintenant.\n\n Autrement appuyer sur la touche « 5 » pour commencer avec l''étude en tant que telle';
    var.InstructionRating = 'Veuillez évaluer l''agréabilité des images, sur une échelle allant de\n\n\n\n  " extrêmement désagréable"\n\n  à \n\n "extrêmement agréable \n\n\n\n utilisez les butons 2 et 4 pour bouger le curseur\n\n et 3 pour confirmer votre réponse'; 
    var.TextEndConditioning = 'La tâche d''association odeur image est terminée.\n\n Attendez l''experimentatrice';
    var.textEnd = 'La tâche d''évaluation est terminée\n\n Attendez l''experimentatrice';
    
elseif var.instruction == 2 %instruction in English (not really here)
    
    var.TextGeneral = 'Dans cette partie de l''étude, vous verrez des images et sentirez des odeurs.\n\n\ Lorsque que vous verrez des images et que le signe « * » apparaîtra à l?écran,\n\n appuyez sur la touche «A» le plus rapidement possible.\n\n\ Ceci vous permettra de découvrir l?odeur associée à l?image.\n\n\n\n\ L?odeur délivrée ne dépend pas de la vitesse à laquelle vous appuyez sur la touche.\n\n En effet, si après 1 seconde vous n?avez pas appuyé sur la touche,\n\n l?odeur sera délivrée de toute manière. \n\nLa vitesse à laquelle vous appuyez sur la touche permettra d?avoir une mesure de l?attention que vous portez à la tâche.\n\n\n\n Certaines images sont plus souvent associées avec certaines odeurs,\n\n ESSAYEZ DE DECOUVRIR QUELLES SONT CES ASSOCIATIONS ';
    var.TextTraining = 'Positionnez votre index gauche sur la touche « A » \n\n\ et pressez la barre « espace » pour démarrer un petit entraînement.';
    var.WarningStart = 'L''entraînement est fini.\n\n\ Si vous avez des questions, vous pouvez les poser maintenant.\n\n\ Attention,l''étude en tant que telle commence (5)';
    var.InstructionRating = 'Veuillez évaluer l''agréabilité des images, sur une échelle allant de\n\n\n\n  " extrêmement désagréable"\n\n  à \n\n "extrêmement agréable \n\n\n\n utilisez les butons 2 et 4 pour bouger le curseur\n\n et 3 pour confirmer votre réponse'; 
    var.TextEndConditioning = 'La tâche d''association odeur image est terminée.\n\n\ Attendez l''experimentatrice';
    var.textEnd = 'La tâche d''évaluation est terminée\n\n\Attendez l''experimentatrice';
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Load list of variable %%%%%%%%%%%%%%%%%%%%%%%%%%
var.trigPhase = 0; % Not conding it here because the file is for the conditionig onla there are no multiple phases

target.side = 1;
target.stim = 2;
target.trig = 2 ;% % chocolate odor is coded on CH2 

empty.side = 1;
empty.stim = 5;
empty.trig = 5;% empty odor is coded on CH4 
var.sideISI = 1; %right or left according to the setting %
var.odorDuration = 1; % for how long the odor is released in seconds

var.triggerStart = 5; % start has the fMRI
var.triggerEnd = 128; % coded on CH 8
var.triggerTrial = 0; % this is computed on the conditioning script (varies according to CS+ (CH6 --> 32) and CS- (CH5 --> 16))
var.triggerBaseline = 64; % coded on CH 7


%%%%%%%%%%%%%%%%%%%%%%%%%%     Create List      %%%%%%%%%%%%%%%%%%%%%%%%%%

var.PavCSs =   {'CSplus.jpg';'CSminu.jpg'};
var.PavSide = {[target.side];[empty.side]};
var.PavStim = {[target.stim];[empty.stim]};
var.PavTrig = {[target.trig];[empty.trig]};

%%%%%%%%%%%% Set the comunication with physiological set up %%%%%%%%%%%%%%%

if var.experimentalSetup
    %var.comport = str2num(input('Enter COMPORT olfactometer ','s'));
    var.comport = 6;
    oInit(var.comport,true); % Open Olfacto library    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%     Open PTB          %%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(1);% Here we call some default settings for setting up PTB
screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen if necessary
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]); %from the left; from the top; up to the right; up to the bottom
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]); %from the left; from the top; up to the right; up to the bottom

% define variables for the grafical interface
var.thermoImage = 'ThermeterOFF.jpg';
wPtrRect = Screen('Rect',wPtr); % referece rect is the total window
width = wPtrRect(3);
var.Twidth = width/7.5;
var.hight = wPtrRect(4);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               PAVLOVIAN CONDITIONING PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off all% Prevents MATLAB from reprinting the source code when the program runs
% Show instructions


%%% INSTRUCTION AND TRAINING
showInstruction(wPtr, var.TextGeneral);
WaitSecs(0.4); 
KbWait(-1);

showInstruction(wPtr, var.WarningStart);% Show warning for the start of the experimenet
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

conditioning_training(var, wPtr, rect);



showInstruction(wPtr, var.textEnd ); % end instructions
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');% Close all the screen
ShowCursor;% Show the mouse cursor

resetCSnames(var); % reset the images names so that the folder is ready for the next participant

if var.experimentalSetup
    oClose(); %close olfacto library
end

end