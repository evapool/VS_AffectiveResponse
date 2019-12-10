function [ResultsLiking, ResultsIntensity] = odorsDay1()


matfilePath = fullfile(pwd,'matfiles'); % eventually change the
matfiles = dir(fullfile(matfilePath, '*.mat'));
workingdir = pwd;

for i = 1:size(matfiles,1)
    
    cd matfiles
    name = matfiles(i).name;
    load(name);
    disp(['file ' num2str(i) ' ' name ]); %that allows to see which file does
    %not work
    
    cd (workingdir);
    
    [aladinanteLiking,aladinanteIntesity] = odorRating('aladinate',data);
    [cassisLiking,cassisIntesity] = odorRating('cassis',data);
    [chocolateLiking,chocolateIntesity] = odorRating('chocolate',data);
    [emptyLiking,emptyIntesity] = odorRating('empty',data);
    [gheeLiking,gheeIntesity] = odorRating('ghee',data);
    [indoolLiking,indoolIntesity] = odorRating('indool',data);
    [leatherLiking,leatherIntesity] = odorRating('leather',data);
    [paracresolLiking,paracresolIntesity] = odorRating('paracresol',data);
    [pin_absLiking,pin_absIntesity] = odorRating('pin_abs',data);
    [pipolLiking,pipolIntesity] = odorRating('pipol',data);
    [popcornLiking,popcornIntesity] = odorRating('popcorn',data);
    [salicylateLiking,salicylateIntesity] = odorRating('salicylate',data);
    [yogurtLiking,yogurtIntesity] = odorRating('yogurt',data);
    
    ResultsLiking (i,:)= [aladinanteLiking,cassisLiking,chocolateLiking,emptyLiking,gheeLiking,indoolLiking,leatherLiking,paracresolLiking,pin_absLiking,pipolLiking,popcornLiking,salicylateLiking,yogurtLiking];
    ResultsIntensity(i,:)= [aladinanteIntesity,cassisIntesity,chocolateIntesity,emptyIntesity,gheeIntesity,indoolIntesity,leatherIntesity,paracresolIntesity,pin_absIntesity,pipolIntesity,popcornIntesity,salicylateIntesity,yogurtIntesity];
end
end
