function [velum,gridsigs] = analyze_mri_grid(data,gridlines,postfits,params)
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
velum = zeros(size(data,3),1);
gridsigs = zeros(size(data,3),params.alv);

% loop through the images
for i = 1:size(data,3)
    
    % loop through the grid lines for each image
    for j = 1:params.alv
        
        % pixel values from image slice along grid line
        if j <= params.alv
            slice = improfile(data(:,:,i),[gridlines(j,1) postfits{i}(j,1)], [gridlines(j,3) postfits{i}(j,2)]);
        else
            slice = improfile(data(:,:,i),[gridlines(j,1) gridlines(j,2)], [gridlines(j,3) gridlines(j,4)]);
        end
        
        % signal = average of pixel values along grid line
        gridsigs(i,j) = mean(slice);
        
        % if the grid line is the velum gride line, then estimate the velum
        % opening instead of simply taking the average of the pixels
        if j == params.velum
            % pixel values from line extending from soft palate, apprx. 45 degrees to posterior pharyngeal wall
            slice = improfile(data(:,:,i),...
                [postfits{i}(j,1) max(postfits{i}(:,1))],...
                [postfits{i}(j,2) gridlines(j,4)]);
            
            % find peaks in the inverse of the pixels along the slice
            [~,~,w,p] = findpeaks(0 - slice);
            [~,index] = max(p);
            
            % if there is a peak, log the width of the peak
            % if there is no peak, the value is 0
            if ~isempty(w)
                velum(i) = w(index);
            else
                velum(i) = 0;
            end
        end
    end
end

% smooth velum signal
velum = smoothdata(velum,'sgolay');

% rescale velum signal
velum = rescale(velum,0,1);

% rescale gridline signals
for i = 1:size(gridsigs,2)
    gridsigs(:,i) = rescale(gridsigs(:,i),0,1);
end
end

