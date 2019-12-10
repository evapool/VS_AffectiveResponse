
function HedonicPleasure_7()


% odor rating: hedonic pleasure % modified on the 20.02.2015 by Eva
% day 1: 13 odors (11 neutrals 1 empty and 1 chocolate)
% day 2:  3 odors (1 neutral 1 empty and 1 chocolate)

% Each trial takes 12 s but it could be longer (not shoter) if the self
% paced response tooke long

%%% MISSING : STIM AND SIDE OLFACTOMETER

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRELIMINATY STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL; % Check for Opengl compatibility, abort otherwise:
KbName('UnifyKeyNames');% Make sure keyboard mapping is the same on all supported operating systems (% Apple MacOS/X, MS-Windows and GNU/Linux)
KbCheck; WaitSecs(0.1); GetSecs;% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are loaded and ready when we need them - without delays

%%%%%%%%%%%%%%%%%% prepare experiment structure %%%%%%%%%%%%%%%%%%%%%%%%%%%

var.experimentalSetup = str2num(input('Are the pyhsiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
var.instruction = str2num(input('Play the instructions? (1 = French or 2 = English) ','s'));
var.day = str2num(input('What day session ? (1 = first day or 2 = second day) ','s'));

var.filepath = MakePathStruct(var);
cd(var.filepath.scripts);

%%%%%%%%%%%%%%%%   Collect Participant and Day    %%%%%%%%%%%%%%%%%%%%%%%%

% Create the file where storing the results
[resultFile,participantID] = createResultFile(var);
var.participantID = participantID;
resultFile = fullfile (var.filepath.data, resultFile); %to save the the file in the data directory

% Date and time informations
data.SubDate= datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
data.SubHour= datestr(now, 13); % Use datestr to get the time in the format hh:mm:ss

save(resultFile,'data');% We save immediately the session's informations

%%%%%%%%%%%%%%%%%%%    Load and radonimze list     %%%%%%%%%%%%%%%%%%%%%%%%
% Load variables
var.responseTimeWindow = 5.5; % this variable is for the VAS scale (ratingOdor function) if the participant did not reposond after the VAS has appeared, then the scripts keeps going (5.5. is to ensure a trial duration of 18 s)
% triggers coding system

% phase:
trig.trialStart = 2;
trig.vanOpen = 30;
trig.sniffSignal = 60;
trig.trialEnd = 90;
trig.experimentEnd = 128; %CH8

% odors:
trig.target = 2;
trig.empty = 4;

trig.neutral_1 = 6;
trig.neutral_2 = 8;
trig.neutral_3 = 10;
trig.neutral_4 = 12;
trig.neutral_5 = 14;
trig.neutral_6 = 16;
trig.neutral_7 = 18;
trig.neutral_8 = 20;
trig.neutral_9 = 22;
trig.neutral_10 = 24;
trig.neutral_11 = 26;

% trigger vector
trig.odors = [trig.target; trig.neutral_1; trig.neutral_2; trig.neutral_3; trig.neutral_4; trig.neutral_5; trig.neutral_6; trig.neutral_7; trig.neutral_8; trig.neutral_9; trig.neutral_10; trig.neutral_11; trig.empty];

% identify the target and the empthy valve co-ordinate
target.side = 1;
target.stim = 2;
target.trig = trig.target + trig.vanOpen; % van open
target.label = 'chocolate';
target.trigSniff =trig.target + trig.sniffSignal;
target.trigTrialStart = trig.target + trig.trialStart;
target.trigTrialEnd = trig.target + trig.trialEnd;


empty.side = 1;
empty.stim = 5;
empty.trig = trig.empty + trig.vanOpen; % van open;
empty.label = 'empty';
empty.trigSniff = trig.empty + trig.sniffSignal;
empty.trigTrialStart = trig.empty + trig.trialStart;
empty.trigTrialEnd = trig.empty + trig.trialEnd;


var.sideISI = 1; %right or left according to the setting %
var.odorLabel_l = {target.label;'aladinate'; 'cassis'; 'ghee';'leather'; 'indool'; 'paracresol';'pin_abs'; 'pipol'; 'popcorn';'salicylate';'yogurt'; empty.label};
var.side = [target.side;1;1;1;1;1;1;1;1;1;1;1;empty.side]; % here all odors are in the right side of the olfacotmeter
var.stim = [target.stim;1;3;4;6;7;8;9;10;11;12;13;empty.stim];% 2 and 4 van are used for chocolate and empty

var.trig = trig.odors + trig.vanOpen;% trigger for odors
var.trigEnd = trig.odors + trig.trialEnd;% here it depends on the olfactometer settings
var.trigSniff = trig.odors + trig.sniffSignal; % trigger for sniff signal onset
var.trigTrialStart = trig.odors + trig.trialStart;% trigger for trial begining

if var.day == 2% if second day
    
    %%%%%%%%%%%%%%%%%%%%%%% select the neutral odor %%%%%%%%%%%%%%%%%%%%%%%
    % we select odor that is the most neutral and that had a similar
    % intesity as the target odor
    
    [neutralOdor,fileDoesNotExist] = selectNeutralOdor(target.trig,empty.trig,var); % the number refers to the trigger number of chocolate (here = 101) and the empthy odor (here = 111)
    if fileDoesNotExist
        neutralOdor = str2num(input('The Day 1 file for this participant cannot be find, please enter manually the trigger number (trig.odor+trig.van) of neutral odor (e.g., 36, 38, 40, 42..)','s'));
    end
    data.neutralOdor = neutralOdor;
    save(resultFile,'data','-append'); %save the neutral odor
    
    % create the list with neutral odor, chocolate odor and empthy van
    neutralOdorSide = var.side (find(var.trig == data.neutralOdor));
    var.side = [target.side;neutralOdorSide;empty.side];
    neutralOdorStim = var.stim (find(var.trig == data.neutralOdor));
    var.stim = [target.stim;neutralOdorStim;empty.stim];
    neutralOdorLabel = var.odorLabel_l(find(var.trig == data.neutralOdor));
    var.odorLabel_l = {target.label;neutralOdorLabel;empty.label};
    neutralOdorTrigSniff = var.trigSniff(find(var.trig == data.neutralOdor));
    var.trigSniff = [target.trigSniff;neutralOdorTrigSniff;empty.trigSniff];
    neutralOdorTrigTrialStart = var.trigTrialStart(find(var.trig == data.neutralOdor));
    var.trigTrialStart = [target.trigTrialStart;neutralOdorTrigTrialStart;empty.trigTrialStart];
    var.trig = [target.trig;data.neutralOdor;empty.trig];% trigger for odors, here odor is identified by the function itself
end



%%%%%%%%%%%%  Experimental Set Up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if var.experimentalSetup
    
    % Set comunication with olfactometer
    var.comport = str2num(input('Enter COMPORT olfactometer ','s'));
    oInit(var.comport,true); % Open Olfacto library
    
    % Set comunication with paralle port
    if var.day == 1;
        var.ioObj = SetParallelPort();
    elseif var.day == 2;
        config_io;
        outp(57392, 0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PsychDefaultSetup(1);% Here we call some default settings for setting up PTB

screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen when if there is one
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 1000 800]); %from the left; from the top; up to the right; up to the bottom
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);
%%%%%%%%%%%%%%%%%%%%% write the instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%write the text for instructions

if var.instruction == 1 %instruction in French
    instruction1 = 'Dans cette partie de l''exp�rimentation, vous allez accomplir une t�che d''�valuation d''odeurs.\n\n Dans cette t�che, vous sentirez diverses odeurs et vous les jugerez � diff�rents niveaux \n\n sur des �chelles allant de 0 � 100 \n\n\n\n\n\n\n\n appuyez sur un bouton pour continuer';
    instruction2 = 'Attention !!! \n\n La perception de certaines propri�t�s des odeurs peut varier selon le moment\n\n et les conditions dans lesquelles l''odeur est pr�sent�e. Pour cette raison, nous vous \n\n demandons d''�valuer les odeurs en vous focalisant sur la perception\n\n que vous avez de l?odeur ici et maintenant.\n\n\n\n\n\n\n\n appuyez sur un bouton pour continuer';
    wait = 'l''�tude va commencer...';
    asterix = '*';
    cross = '+';
    one = '1';
    two = '2';
    three = '3';
    End = 'l''�tude est termin�, merci !';
    attention = 'attention !!';
    
    % and variables for the VAS scales (see auxiliary function)
    var.howPleasant = '� quel point avez-vous trouv� l''odeur agr�able?';
    var.anchorMinPleasant = 'extr�mement D�sagr�able';
    var.anchorMaxPleasant = 'extr�mement Agr�able';
    var.howIntense = '� quel point avez-vous trouv� l''odeur intense?';
    var.anchorMinIntense = 'pas Per�u';
    var.anchorMaxIntense = 'extr�mement Forte';
    var.pressToContinue = 'Bouton du milieu pour continuer';
    var.tooLong = 'R�ponse trop lente';
    
elseif var.instruction == 2 %instruction in English
    instruction1 = 'In this part of the experiment you will perform an odor evaluation task\n\nIn this task you will smell different kinds of odors and you will evaluate \n\n them on different scales going from 0 to 100.\n\n\n\n\n\n\n\n press a button to continue';
    instruction2 = 'Beware !!!\n\n The perception of the odors can vary across time and the conditions\n\n in which they odors are perceived.\n\n For this reason, we ask you to evaluate the odors, by focusing on\n\nthe perception you have here and now.\n\n\n\n\n\n\n\n press a button to continue';
    wait = 'the experiment is about to begin..';
    asterix = '*';
    cross = '+';
    one = '1';
    two = '2';
    three = '3';
    End = 'The experiment is over, thank you !';
    attention = 'attention !!';
    
    % and variables for the VAS scales (see auxiliary function)
    var.howPleasant = 'how pleasant was the odor?';
    var.anchorMinPleasant = 'extremely pleasant';
    var.anchorMaxPleasant = 'extremely unpleasant';
    var.howIntense = 'how intense was the odor?';
    var.anchorMinIntense = 'not Perceived';
    var.anchorMaxIntense = 'extremely Strong';
    var.pressToContinue = 'Press the middle button to continue';
    var.tooLong = 'Too Slow';
end

showInstructionSimple (wPtr,instruction1);
WaitSecs(0.4);
KbWait(-1);

showInstructionSimple (wPtr, instruction2);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Put up a "Get Ready" screen until the experimenter presses the space button.
showInstructionSimple (wPtr,wait);
triggerscanner = 0;
WaitSecs(0.4);

while ~triggerscanner
    [down secs key d] = KbCheck(-1);
    if (down == 1)
        if strcmp('5%',KbName(key))
            triggerscanner = 1;
        end
    end
    WaitSecs(.01);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%% set timing variables%%%%%%%%%%%%%%%%%%%%%%%%%%
var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
var.ref_end = 0; % ref_end is continually updated as the end time for various functions to compute the drift and adjust the ITI

var.ref_end = var.ref_end + 2.0;
data.attention_duration = showInstruction(wPtr,attention,var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        EXPERIMENTAAL PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if var.day == 1
    var.repetitions = 1;% determine the amount of time a each odor will be repeteated
    var.lengthBlock = 2; %define how many
elseif var.day == 2
    var.repetitions = 5;% determine the amount of time a each odor will be repeteated
    var.lengthBlock = 3; %define how many
end

% initialize variables
nTrial = 0;  % set le compteur to 0

var.lines = (length(var.trig)*var.repetitions*var.lengthBlock); %to initialize the variables

data.liking = NaN (var.lines,1);
data.intensity = NaN (var.lines,1);
data.odorLabel = cell (var.lines,1);
data.tTrialStart = NaN (var.lines,1);
data.tTrialEnd = NaN (var.lines,1);
data.odorTrigger = NaN (var.lines,1);
data.odorSide = NaN (var.lines,1);
data.odorStim = NaN (var.lines,1);
data.Trial = NaN (var.lines,1);

%timing data: onsets
data.tValveOpen = NaN (var.lines,1);
data.tValveClose = NaN (var.lines,1);
data.sniffSignalOnset = NaN (var.lines,1);
data.likingOnset = NaN (var.lines,1);
data.intensityOnset = NaN (var.lines,1);

%timing data: durations
data.duration.SendTriggerStart= NaN (var.lines,1);
data.duration.count3= NaN (var.lines,1);
data.duration.count2= NaN (var.lines,1);
data.duration.oCommitOdor= NaN (var.lines,1);
data.duration.count1= NaN (var.lines,1);
data.duration.asterix1= NaN (var.lines,1);
data.duration.oCommitISI= NaN (var.lines,1);
data.duration.SendTriggerSniff= NaN (var.lines,1);
data.duration.asterix2= NaN (var.lines,1);
data.drift = NaN (var.lines,1);
data.duration.jitter= NaN (var.lines,1);
data.duration.Liking = NaN (var.lines,1);
data.duration.cleanKeyboardMemory1= NaN (var.lines,1);
data.duration.IQCross = NaN (var.lines,1);
data.duration.Intensity = NaN (var.lines,1);
data.duration.cleanKeyboardMemory2= NaN (var.lines,1);
data.duration.ITI = NaN (var.lines,1);% presenting a slide on the graphical interface variable and non-negletable time we will adjust the ITI to recalibrating for this time.


for r = 1: var.repetitions  

    
% We randomize the odor order presentation after every serie repetition
randomIndex = randperm(length(var.trig));

var.stim = var.stim (randomIndex);
var.side = var.side (randomIndex);
var.trig = var.trig (randomIndex);
var.trigEnd = var.trigEnd (randomIndex);
var.odorLabel_l = var.odorLabel_l (randomIndex);
var.trigSniff = var.trigSniff (randomIndex);
var.trigTrialStart = var.trigTrialStart (randomIndex);

    
    for i = 1:length(var.trig);
       
        for mb = 1:var.lengthBlock; % MiniBlock: three repetion of the same odor
            
            nTrial = nTrial + 1;
            data.Trial (nTrial,1) = nTrial;
            [time,SendTrigger_t] = SendTrigger(var.trigTrialStart(i),var); % send trigger and record time
            data.tTrialStart(nTrial,1) = time;
            data.duration.SendTriggerStart(nTrial,1)= SendTrigger_t;
            data.odorLabel (nTrial) = var.odorLabel_l(i); % identify the label of odor that is released
            data.odorTrigger (nTrial) = var.trig (i);% identify the trigger of odor that is released
            data.odorSide (nTrial) = var.side (i);
            data.odorStim (nTrial) = var.stim (i);
            if var.experimentalSetup
                oStimulus(var.side (i),var.stim (i));% select odor
            end
            
            %%%%%%%%%%%%%%%%%% Count Down three two %%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1.0; % count 3 for 1 s
            data.duration.count3(nTrial,1) = showInstruction (wPtr, three,var); %3
            
            var.ref_end = var.ref_end + 1.0; % count 2 for 1 s
            data.duration.count2(nTrial,1) = showInstruction (wPtr, two,var); %2
            
            %%%%%%%%%% Odor Release (anticipated for the scanner) %%%%%%%%%
            if var.day == 2;
            [tValve, oCommit_t] = SendOdor (var.trig (i),var);% Odor Release and record time
            data.tValveOpen (nTrial,1) = tValve;
            data.duration.oCommitOdor(nTrial,1) = oCommit_t; % record how long send odor takes
            var.ref_end = var.ref_end + data.duration.oCommitOdor(nTrial,1);% and update var.ref_end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Count Down one %%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1.0; % count 1 for 1 s
            data.duration.count1(nTrial,1) = showInstruction (wPtr, one,var); %1
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Odor Release (day 1)  %%%%%%%%%%%%
            if var.day == 1;
            [tValve, oCommit_t] = SendOdor (var.trig (i),var);% Odor Release and record time
            data.tValveOpen (nTrial,1) = tValve;
            data.duration.oCommitOdor(nTrial,1) = oCommit_t; % record how long send odor takes
            var.ref_end = var.ref_end + data.duration.oCommitOdor(nTrial,1);% and update var.ref_end
            WaitSecs(0.5);
            end     
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Sniffing signal %%%%%%%%%%%%%%%%%%%
            [time,SendTrigger_t] = SendTrigger (var.trigSniff(i),var);% send trigger and record timing variables
            data.sniffSignalOnset(nTrial,1) = time;
            data.duration.SendTriggerSniff(nTrial,1) = SendTrigger_t; % how long the function takes
            var.ref_end = var.ref_end + data.duration.SendTriggerSniff(nTrial,1);% update var.ref_end because it take 30 ms to send a trigger
            
            if var.day == 2;
            var.ref_end = var.ref_end + 1.5;%% attention this might be change in order to have an effective 2.5 s
            end
            
            if var.day == 1;
            var.ref_end = var.ref_end + 1;%% attention this might be change in order to have an effective 1.5 s
            end
            
            data.duration.asterix1(nTrial,1) = showInstruction (wPtr,asterix,var); % sniff
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close Odor %%%%%%%%%%%%%%%%%%%%%%%
            if var.experimentalSetup
                oInterStimulus(var.sideISI); % select ISI air
            end
            
            [tValve, oCommit_t] = SendOdor(var.trigEnd(i),var);% release ISI air and record time
            data.tValveClose(nTrial,1) = tValve;
            data.duration.oCommitISI(nTrial,1)= oCommit_t;
            var.ref_end = var.ref_end + data.duration.oCommitISI(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%% Sniffing signal continue %%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1.0;
            data.duration.asterix2(nTrial,1)= showInstruction (wPtr,asterix,var); % sniff
            
            data.drift(nTrial,1) = GetSecs()-var.time_MRI - data.tTrialStart(nTrial,1)-5.5; % until here the timing is fixed thus we can cumpute here the drift
            
            %%%%%%%%%%%%%%%%%%% Break before questions %%%%%%%%%%%%%%%%%%%%
            tjietter = randsample([0.8:1,1:1.2],1); % randomize jitter between 0.8 and 1.2
            var.ref_end = var.ref_end + tjietter;
            data.duration.jitter(nTrial,1)=showInstruction (wPtr,cross,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Pleasantness %%%%%%%%%%%%%%%%%%%%%
            l1 = GetSecs;
            data.likingOnset(nTrial,1) = time;
            data.liking (nTrial,1) = ratingOdor(var.howPleasant,var.anchorMinPleasant,var.anchorMaxPleasant,wPtr,rect,var);
            l2 = GetSecs;
            data.duration.cleanKeyboardMemory1(nTrial,1)=cleanKeyboardMemory();
            data.duration.Liking (nTrial,1) = (l2-l1)+ data.duration.cleanKeyboardMemory1(nTrial,1);%+data.duration.SendTriggerPlesantnessQ(nTrial,1); % timing of the liking evaluation
            var.ref_end = var.ref_end + data.duration.Liking (nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.duration.IQCross(nTrial,1)= showInstruction (wPtr, cross,var); % interquestion cross timing
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Intensity %%%%%%%%%%%%%%%%%%%%%%%%
            I1 = GetSecs;
            data.intensityOnset(nTrial,1) = time;
            data.intensity (nTrial,1) = ratingOdor(var.howIntense,var.anchorMinIntense,var.anchorMaxIntense,wPtr,rect,var);
            I2 = GetSecs;
            data.duration.cleanKeyboardMemory2(nTrial,1)= cleanKeyboardMemory();
            data.duration.Intensity(nTrial,1) = (I2 -I1)+ data.duration.cleanKeyboardMemory2(nTrial,1);%+data.duration.SendTriggerIntensityQ (nTrial,1);
            var.ref_end = var.ref_end + data.duration.Intensity(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%% ITI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ITI = 12.5 - data.duration.jitter(nTrial,1) - data.duration.Liking (nTrial)- data.duration.IQCross(nTrial,1) - data.duration.Intensity(nTrial) - data.drift(nTrial);
            
            if ITI < 0
                ITI = 0.5;
            end
            
            var.ref_end = var.ref_end + ITI;
            data.duration.ITI(nTrial,1) = showInstruction (wPtr, cross,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Save Results %%%%%%%%%%%%%%%%%%%%%%
            data.tTrialEnd(nTrial,1) = GetSecs-var.time_MRI;
            save(resultFile,'data','-append')
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           END OF THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstruction (wPtr,End,var);
WaitSecs(0.4);
KbWait(-1);

oClose
Screen('CloseAll');

end