%-----------------------------------------------------------------------
% MODEL VISUALIZATION intended for REWOD HEDONIC
% IMPLEMENTED by David USING MACS by J. Soch
%-----------------------------------------------------------------------
clear all

%define variables
task = 'PIT';


%define paths
cd ~
home = pwd;
homedir = [home '/REWOD/'];


BMSdir   = fullfile(homedir, 'DERIVATIVES/GLM', task, 'BMS');
roi = fullfile(homedir, 'DERIVATIVES/EXTERNALDATA/LABELS/RL_Atlas/striatum.nii'); 

%extract ROI
Y = spm_read_vols(spm_vol(roi),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';

cd(BMSdir)

models       =  {'04'; '03'; '09'; '13'}; %h0 first and they complexify


%loop trhough models
for i = 1:length(models)
    model_files{i,1} = fullfile(BMSdir, ['GLM-' models{i} '_model_EFM.nii,1']); 
    P = spm_vol(model_files{i,1});

    dat = spm_read_vols(P);
    data = reshape(dat,1,[]);

    est = nanmean(data,2);
    sd = nanstd(data);
    df{i,1} = est;
    df{i,2} = sd;

end

models       =  {'between'; 'within'; 'within-control'; 'between-control'};

cHeader = {'mean'; 'sd'};
commaHeader = [cHeader';repmat({','},1,numel(cHeader))]; %insert commas
commaHeader = commaHeader(:)'; df=flip(df); %flip array
df = [df,models];
textHeader = cell2mat(commaHeader); %cHeader in text with commas

writecell(vertcat({'mean' 'sd' 'GLM' }, df),[task '_BMS.csv'])

% %write header to file
% fid = fopen([task '_BMS.csv'],'w'); 
% fprintf(fid,'%s\n',textHeader);
% fclose(fid);
% 
% %write data to end of file
% dlmwrite([task '_BMS.csv'],df,'-append');

display('done');



