function [ regions, regplot ] = set_vt_regions(data,gridlines,postfits,params)
%% Function description
% 2018, Christopher Carignan

% User defines the grid line boundaries for the following regions: 
% alveolar, palatal, velar, hyper-pharyngeal, hypo-pharyngeal

% These regions will be used to create time-varying articulatory signals
% associated with the average pixel values within these grid line limits 
% (analyze_mri_grid.m)

% Input arguments:
%   data:       registered image matrix from register_mri.m
%   gridlines:  x,y coordinates of semi-polar grid from set_mri_grid_nolips.m
%   postfits:   automatically fitted vocal tract contours from get_mri_posterior.m
%   params:     grid line parameters and info from set_mri_grid_nolips.m

% Output arguments:
%   regions:    grid line numbers for the different regions
%   regplot:    figure with grid line regions (for reference only)

% Example:
% [regions,regplot] = set_vt_regions(regmatrix,gridlines,postfits,params);


%% Function starts here

% get the frame number that was used in grid line placement (set_mri_grid_nolips.m)
frame = params.frame;
regions = {};

% show image and plot the (fitted) semi-polar grid
figure
imagesc(data(:,:,frame));
set(gca,'Ydir','normal')
hold on

for i = 1:params.alv
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','w','linewidth',1)
end

%% alveolar region
fprintf( '\n   Select alveolar region...' );
selection = ginput(2);

% grid line closest to first alveolar selection
region = [];
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(1,1))^2 + (gridlines(i,4) - selection(1,2))^2);
end
[~,region(1)] = min(dists);

% grid line closest to second alveolar selection
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(2,1))^2 + (gridlines(i,4) - selection(2,2))^2);
end
[~,region(2)] = min(dists);

regions.alv(1) = min(region);
regions.alv(2) = max(region);

for i = regions.alv(1):regions.alv(2)
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','r','linewidth',1)
end


%% palatal region
fprintf( '\n   Select palatal region...' );
selection = ginput(2);

% grid line closest to first palatal selection
region = [];
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(1,1))^2 + (gridlines(i,4) - selection(1,2))^2);
end
[~,region(1)] = min(dists);

% grid line closest to second palatal selection
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(2,1))^2 + (gridlines(i,4) - selection(2,2))^2);
end
[~,region(2)] = min(dists);

regions.pal(1) = min(region);
regions.pal(2) = max(region);

for i = regions.pal(1):regions.pal(2)
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','y','linewidth',1)
end


%% velar region
fprintf( '\n   Select velar region...' );
selection = ginput(2);

% grid line closest to first palatal selection
region = [];
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(1,1))^2 + (gridlines(i,4) - selection(1,2))^2);
end
[~,region(1)] = min(dists);

% grid line closest to second palatal selection
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(2,1))^2 + (gridlines(i,4) - selection(2,2))^2);
end
[~,region(2)] = min(dists);

regions.velar(1) = min(region);
regions.velar(2) = max(region);

for i = regions.velar(1):regions.velar(2)
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','g','linewidth',1)
end


%% hyper-pharyngeal region
fprintf( '\n   Select hyper-pharyngeal region...' );
selection = ginput(2);

% grid line closest to first velar selection
region = [];
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(1,1))^2 + (gridlines(i,4) - selection(1,2))^2);
end
[~,region(1)] = min(dists);

% grid line closest to second velar selection
dists = [];
for i = 1:size(gridlines,1)
    dists(i) = sqrt((gridlines(i,2) - selection(2,1))^2 + (gridlines(i,4) - selection(2,2))^2);
end
[~,region(2)] = min(dists);

regions.hyper(1) = min(region);
regions.hyper(2) = max(region);

for i = regions.hyper(1):regions.hyper(2)
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','m','linewidth',1)
end


%% hypo-pharyngeal region
regions.hypo(1) = 1;
regions.hypo(2) = regions.hyper(1)-1;

for i = regions.hypo(1):regions.hypo(2)
    line([gridlines(i,1) postfits{frame}(i,1)], [gridlines(i,3) postfits{frame}(i,2)],'color','c','linewidth',1)
end

% save figure for reference
regplot = getframe(gcf);
end

