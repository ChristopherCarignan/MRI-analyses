function [contour] = set_mri_posterior(data,gridlines,params)
%% Function description
% 2018, Christopher Carignan

% User manually guides a semi-automatic selection of the posterior contour 
% of the vocal tract (i.e., posterior in relation to the lingual origin)

% Selection proceeds in an iterative fashion, from the glottis to the 
% alveolar ridge, through each of the 28 gridlines

% The pixel values along each grid line are used to create a differential
% signal, and the positive peaks in the differential (corresponding to a
% transtion from AIR to FLESH) are used to determine the boundary

% At each grid line, the posterior edge of the vocal tract is automatically 
% chosen by a weighting of the following parameters:
%   -proximity to user selection (it must be close to the user's selection)
%   -proximity to selection at previous gridline (the vocal tract boundary must be contiguous)
%   -prominance of differential peak (the peak must be strong/prominent)
%   -value of the differential peak (the pixel intensities must change quickly)

% Input arguments:
%   data:       registered image matrix from register_mri.m
%   gridlines:  x,y coordinates of semi-polar grid from set_mri_grid_nolips.m
%   params:     grid line parameters and info from set_mri_grid_nolips.m

% Output arguments:
%   contour:    structure of x,y coordinates of the posterior contour of the vocal tract

% Example:
% posterior = set_mri_posterior(regmatrix,gridlines,params);


%% Function starts here

% get the frame number that was used in grid line placement (set_mri_grid_nolips.m)
frame = params.frame;

% display image and plot grid line at glottis
imagesc(data(:,:,frame));
set(gca,'Ydir','normal')
hold on
l = line([gridlines(1,1) gridlines(1,2)], [gridlines(1,3) gridlines(1,4)],'color','r','linewidth',1);

% user selection of posterior edge of vocal tract at the glottis
fprintf( '\n   Select posterior boundary of vocal tract at grid line 1... ' );
selection = ginput(1);

coords = [];
% pixel values from glottis slice (== slice 1)
[coords(:,1), coords(:,2), slice] =...
    improfile(data(:,:,frame),[gridlines(1,1) gridlines(1,2)], [gridlines(1,3) gridlines(1,4)]);

% find POSITIVE velocity peaks
[pks,locs] = findpeaks(diff(slice));

% euclidean distance of peaks from user selection
dists = [];
dists(:,1) = (coords(:,1) - selection(1)).^2;
dists(:,2) = (coords(:,2) - selection(2)).^2;
dists(:,3) = sqrt(dists(:,1) + dists(:,2));
dists(:,4) = rescale(dists(:,3));

% weighting factor = peak amplitude / distance from prior assumption
pks = rescale(pks);
weights = pks./dists(locs,4);
[~,posterior] = max(weights);
posterior = coords(locs(posterior),:);

prev = zeros(size(gridlines,1)+1,2);

prev(1,:) = posterior;

% delete grid line and draw fit
delete(l)
line([gridlines(1,1) posterior(1)], [gridlines(1,3) gridlines(1,4)],'color','w','linewidth',2);

% iterate through the rest of the 28 grid lines
for i = 2:params.alv
    coords = [];
    % pixel values from image slice along grid line
    [coords(:,1), coords(:,2), slice] =...
        improfile(data(:,:,frame),[gridlines(i,1) gridlines(i,2)], [gridlines(i,3) gridlines(i,4)]);
    
    % make sure the slice exists and also isn't just air
    if ~isnan(slice) & mean(slice) > params.thresh/2
        l = line([gridlines(i,1) gridlines(i,2)], [gridlines(i,3) gridlines(i,4)],'color','r','linewidth',1);
        
        % user selection of posterior edge of vocal tract at grid line
        eval(['fprintf( ''\n   Select posterior boundary of vocal tract at grid line' ' ' num2str(i) '... '' );'])
        selection = ginput(1);
        
        % find POSITIVE velocity peaks (i.e., transition from AIR to FLESH)
        [pks,locs,~,p] = findpeaks(diff(slice));
        
        % euclidean distance of peaks from current selection
        dists = [];
        dists(:,1) = (coords(:,1) - selection(1)).^2;
        dists(:,2) = (coords(:,2) - selection(2)).^2;
        dists(:,3) = sqrt(dists(:,1) + dists(:,2));
        dists(:,4) = rescale(dists(:,3));
        
        % distance factor #1 (distance from current user selection)
        dist1 = dists(locs,4);
        
        % euclidean distance of peaks from previous grid line selection
        dists = [];
        dists(:,1) = (coords(:,1) - prev(i-1,1)).^2;
        dists(:,2) = (coords(:,2) - prev(i-1,2)).^2;
        dists(:,3) = sqrt(dists(:,1) + dists(:,2));
        dists(:,4) = rescale(dists(:,3));
        
        % distance factor #2 (distance from previous selection)
        dist2 = dists(locs,4);
        
        
        % weighting factor = peak prominance / (distance from prior assumptions)
        % penalties for:
        %   small peak prominence
        %   small peak value
        %   large distance from current selection (large penalty)
        %   large distance from previous selection
        weights = ( p .* pks )./( (dist1.^2) .* dist2  );
        [~,posterior] = max(weights);
        prev(i,:) = coords(locs(posterior),:); 
        
        % delete grid line and draw fit
        delete(l)
        line([prev(i-1,1) prev(i,1)],[prev(i-1,2) prev(i,2)],'color','w','linewidth',2);
    end
end

% get rid of any empty selections
prev( ~any(prev,2), : ) = [];

% Smooth contour with a Savitzky-Golay sliding polynomial filter
windowWidth = 5;
polynomialOrder = 2;
prev(:,1) = sgolayfilt(prev(:,1), polynomialOrder, windowWidth);
prev(:,2) = sgolayfilt(prev(:,2), polynomialOrder, windowWidth);

% clear and re-draw image
clf
imagesc(data(:,:,frame));
set(gca,'Ydir','normal')
hold on

% plot smoothed posterior contour on original image
for i = 2:size(prev,1)
    line([prev(i-1,1) prev(i,1)],[prev(i-1,2) prev(i,2)],'color','w','linewidth',2);
end

% log contour x,y values
contour = {};
contour.outer = prev;

% get rid of empty grid lines; log fitted grid lines
gridlines( ~any(gridlines,2), : ) = [];
contour.gridlines = gridlines;

end

