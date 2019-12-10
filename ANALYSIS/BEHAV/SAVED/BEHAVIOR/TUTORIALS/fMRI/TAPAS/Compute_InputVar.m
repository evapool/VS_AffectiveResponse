% Plot physiology
%diplayplot = 1;
participantID = '_1_test';

filename = [num2str(participantID) '.acq'];
%load and transform acknoledge file
physio = load ('test_pulse 2.mat');

% ENTER VARIABLES PARAMETERS
sampling_rate = 100; % number of measures per sec
num_EPI = 755;
TR = 1;

%Sycronize the physiological data to the MRI session
%scanner_start = min (find((physio.data (:,6)) == 5)); % First MRI volume trigger 
%time_Physio = (length(physio.data (scanner_start:length(physio.data))))/sampling_rate; % The last image is acquired
%&&scanner_end = (num_EPI * TR) * sampling_rate;
scanner_end = length(physio.data) ; %%% HERE INSERT THE LENGHT OF THE PHYSIO FILE: Physiotoolbox will calculate the exact length !!

% Variable for Figure1
%num_channel = 10;
%Start = scanner_start;
%End = scanner_end;

respEPI = physio.data (:,2); %SpO wave form
heartEPI = physio.data (:,1); % respiratory effort

save (['respEPI' num2str(participantID) '.mat'], 'respEPI');
save (['heartEPI' num2str(participantID) '.mat'], 'heartEPI');


