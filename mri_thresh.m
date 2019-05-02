function [apertures] = mri_thresh(mrdata,gridlines,postfits,params)
%% Function description
% 2018, Christopher Carignan

% Estimates vocal tract area functions via binarization of images based on
% a threshold of air from set_mri_grid_nolips.m, defined as:
%       0.25*(max(slice) - min(slice))
% from the gridline extending across an air cavity in the vocal tract

% Input arguments:
%   mrdata:     registered image matrix from register_mri.m
%   gridlines:  x,y coordinates of semi-polar grid from set_mri_grid_nolips.m
%   postfits:   automatically fitted vocal tract contours from get_mri_posterior.m
%   params:     grid line parameters and info from set_mri_grid_nolips.m

% Output arguments:
%   apertures:  vocal tract area functions (number of pixels in each gridline that meet threshold)

% Example:
% apertures = mri_thresh(regmatrix,gridlines,postfits,params);


%% Function starts here

% get some info and preallocate array
thresh = params.thresh;
apertures = zeros(size(mrdata,3),params.alv);

% loop through the images
for i = 1:size(mrdata,3)
    % binarize the image based on threshold
    thrimg = imbinarize(mrdata(:,:,i),thresh/256);
    
    % loop through the fitted grid lines
    for j = 1:params.alv
        % create slice of pixels along grid line, invert to count pixels
        slice = 1 - improfile(thrimg,[gridlines(j,1) postfits{i}(j,1)], [gridlines(j,3) postfits{i}(j,2)]);
        
        % count pixels in slice that are at or below air threshold
        apertures(i,j) = sum(slice);
    end
    
    % apply moving median filter to VT aperture function, in order to
    % correct single grid lines that have errors
    apertures(i,:) = smoothdata(apertures(i,:),'movmedian');
end

% since the filtering can result in both non-integer and negative values,
% the matrix must be rounded and then adjusted so that the min = 0
apertures = round(apertures) - min(apertures(:));
end

