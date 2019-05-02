function [contfits] = get_mri_posterior(mrdata,contdata,params)
%% Function description
% 2018, Christopher Carignan

% Automatic selection of the posterior contour of the vocal tract for all
% MR images in image matrix

% Selection proceeds in an iterative fashion, from the glottis to the 
% alveolar ridge, through each of the 28 gridlines

% The pixel values along each grid line are used to create a differential
% signal, and the positive peaks in the differential (corresponding to a
% transtion from AIR to FLESH) are used to determine the boundary

% At each grid line, the posterior edge of the vocal tract is automatically 
% chosen by a weighting of the following parameters:
%   -proximity to base user selection (it must be close to the user's original selection from set_mri_posterior.m)
%   -proximity to selection at previous gridline (the vocal tract boundary must be contiguous)
%   -prominance of differential peak (the peak must be strong/prominent)
%   -value of the differential peak (the pixel intensities must change quickly)

% Input arguments:
%   mrdata:     registered image matrix from register_mri.m
%   contdata:   posterior contour of vocal tract from set_mri_posterior.m
%   params:     grid line parameters and info from set_mri_grid_nolips.m

% Output arguments:
%   contfits:   automatically fitted vocal tract contours for each image

% Example:
% postfits = get_mri_posterior(regmatrix,posterior,params);


%% Function starts here
alv = params.alv;
vel = params.velum;

contfits = cell(size(mrdata,3),1);

for i = 1:size(mrdata,3)
    eval(['fprintf( ''\n   Setting contour for frame ',num2str(i),' of ',num2str(size(mrdata,3)),' ... '' );'])
    
    coords = [];
    % glottis
    [coords(:,1), coords(:,2), slice] =...
        improfile(mrdata(:,:,i),[contdata.gridlines(1,1) contdata.gridlines(1,2)],...
        [contdata.gridlines(1,3) contdata.gridlines(1,4)]);
    
    % find POSITIVE velocity peaks (i.e., transition from OUTER boundary to air)
    [pks,locs,~,p] = findpeaks(diff(slice));
    
    % scale peaks
    pks = rescale(pks);
    p = rescale(p);
    
    % euclidean distance of peaks from base OUTER selection
    dists = [];
    dists(:,1) = (coords(:,1) - contdata.outer(1,1)).^2;
    dists(:,2) = (coords(:,2) - contdata.outer(1,2)).^2;
    dists(:,3) = sqrt(dists(:,1) + dists(:,2));
    dists(:,4) = rescale(dists(:,3));
    
    % distance factor (distance from base selection)
    dist = dists(locs,4);
    
    % weighting factor = peak prominance / (distance from prior assumption)
    % penalties for:
    %   small peak prominence
    %   small peak value
    %   large distance from base selection
    weights = ( p + pks) - dist.^2;
    [~,posterior] = max(weights);
    prev(1,:) = coords(locs(posterior),:);
    
    % automatically fit contours for all grid lines except for the hard palate
    for j = 2:(vel+2)
        coords = [];
        % pixel values from image slice along grid line
        [coords(:,1), coords(:,2), slice] =...
            improfile(mrdata(:,:,i),[contdata.gridlines(j,1) contdata.gridlines(j,2)],...
            [contdata.gridlines(j,3) contdata.gridlines(j,4)]);
        
        % make sure the slice exists and also isn't just air
        if ~isnan(slice) & mean(slice) > params.thresh/2
            % find POSITIVE velocity peaks (i.e., transition from AIR to FLESH)
            [pks,locs,~,p] = findpeaks(diff(slice));
            
            % scale peaks
            pks = rescale(pks);
            p = rescale(p);
            
            % euclidean distance of peaks from base user posterior fit
            dists = [];
            dists(:,1) = (coords(:,1) - contdata.outer(j,1)).^2;
            dists(:,2) = (coords(:,2) - contdata.outer(j,2)).^2;
            dists(:,3) = sqrt(dists(:,1) + dists(:,2));
            dists(:,4) = rescale(dists(:,3));
            
            % distance factor #1 (distance from base selection)
            dist = dists(locs,4);
            
            % weighting factor = peak prominance / (distance from prior assumption)
            % penalties for:
            %   small peak value and prominence
            %   large distance from base selection
            
            weights = ( p + pks ) - dist;
            
            [~,posterior] = max(weights);
            prev(j,:) = coords(locs(posterior),:);
        end
    end
    
    % hard palate coordinates do not change
    for j = (vel+3):alv
        prev(j,:) = contdata.outer(j,:);
    end
    
    
    % Smooth with a Savitzky-Golay sliding polynomial filter
    windowWidth = 5;
    polynomialOrder = 2;
    
    prev(:,1) = sgolayfilt(prev(:,1), polynomialOrder, windowWidth);
    prev(:,2) = sgolayfilt(prev(:,2), polynomialOrder, windowWidth);
    
    % log contour x,y values
    contfits{i} = prev;
end
end

