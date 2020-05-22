% Extracts values from an image data file based on regions/clusters of
% voxels in mask marsbar or image file(s) or voxel.
%
% If mask or data not defined, GUI asks to select files.
%
% Example usage:
% extract_voxel_values('L_Fusiform_roi.mat','beta_0005.img')
%
% Dependencies: Marsbar (if *_roi.mat ROI mask files used).
% 
% Modified from extract_voxel_values_old.m by Josh Goh 24 May 2013.
 
function [Ym R info] = extract_voxel_values(mask,data)
 
% Check input
if nargin<1
    mask = spm_select(Inf,'any','Select mask ROI files',[],pwd);
    data = spm_select(Inf,'image','Select data file (*.img or *.nii)',[],pwd);
end
 
info.regions = mask;
info.images  = data;
 
% Loop image
for i = 1:size(data,1)
    
    % Read image header
    V = spm_vol(deblank(data(i,:)));
    
    % Loop regions
    for r = 1:size(mask,1)
        
        % Get voxels from mask
        [~,~,e] = fileparts(deblank(mask(r,:)));
        switch e
            case {'.mat'}
                roi = maroi(deblank(mask(r,:)));
                xyz = voxpts(roi,deblank(data(i,:)));
            case {'.nii','.img'}
                maskdata = spm_read_vols(spm_vol(deblank(mask(r,:))));
                [x,y,z] = ind2sub(size(maskdata),find(maskdata));
                xyz = [x y z]';
        end
        
        % Extract data
        Ya = spm_sample_vol(V,xyz(1,:),xyz(2,:),xyz(3,:),0);
        R(r).I(i).Ya = Ya;
        
        % Compute mean across voxels
        Ym(i,r) = mean(Ya(~isnan(Ya)));
        
        % Compute MNI coordinates
        R(r).I(i).mni = vox2mni(V.mat,xyz);
        R(r).I(i).xyz = xyz;
        
    end
end