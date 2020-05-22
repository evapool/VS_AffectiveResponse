%-----------------------------------------------------------------------
% WRAPPER FUNCTION intended for REWOD
% IMPLEMENTED USING MACS by J. Soch
%-----------------------------------------------------------------------

addpath /usr/local/external_toolboxes/spm12/toolbox/MACS/


task = 'hedonic';
model       =  {'04'; '15'};
subj       =  {'01'; '02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;

orig = pwd;

%loop trhough subjects
for i = 1:length(subj)
    
    %loop trhough models
    for j = 1:length(model)
        disp([' Doing sub-' subj{i} 'for GLM-' model{j}]);
        
        cd (orig)
        
        Get_model_R2(subj{i}, model{j}, task) %change here the function you want to loop through
    end
    
end