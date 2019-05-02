function [gridsigs] = analyze_mri_grid2(data,gridlines,postfits,params)
%% Function description
% 2018, Christopher Carignan

% Create time-varying articulatory signals from MR images:
%   - Grid line signals are created by average the pixel intensities along
%       each grid line
%   - Velum signal is created by calculating the width of the peak in the
%       inverse of the pixels along the velum grid line, i.e., a peak in
%       the grid line signal will be created with the velum opens; the
%       wider the peak, the larger the opening)

% Input arguments:
%   data:       registered image matrix from register_mri.m
%   gridlines:  x,y coordinates of semi-polar grid from set_mri_grid_nolips.m
%   postfits:   automatically fitted vocal tract contours from get_mri_posterior.m
%   params:     grid line parameters and info from set_mri_grid_nolips.m

% Output arguments:
%   velum:      a time-varying, smoothed signal representing velum opening
%   gridsigs:   a matrix of time-varying signals from the 28 grid lines

% Example:
% [factors,scores,velum1,gridsigs] = analyze_mri_grid(regmatrix,gridlines,postfits,params);


%% Function starts here

% preallocate matrices
gridsigs = zeros(size(data,3),params.alv);

% loop through the images
for i = 1:size(data,3)
    
    % loop through the grid lines for each image
    for j = 1:params.alv
        
        % scale the image (i.e., decrease dynamic range)
        I = imadjust(data(:,:,i),[params.thresh/256 params.thresh*3/256],[]);
        
        % pixel values from image slice along grid line
        if j <= params.alv
            slice = improfile(I,[gridlines(j,1) postfits{i}(j,1)], [gridlines(j,3) postfits{i}(j,2)]);
        else
            slice = improfile(I,[gridlines(j,1) gridlines(j,2)], [gridlines(j,3) gridlines(j,4)]);
        end
        
        % signal = sum the pixel values along grid line in scaled image
        gridsigs(i,j) = sum(slice);
        
    end
end

% rescale gridline signals
for i = 1:size(gridsigs,2)
    gridsigs(:,i) = rescale(gridsigs(:,i),0,1);
end
end

