function [gridlines,params] = set_mri_grid_nolips(data)
%% Function description
% 2018, Christopher Carignan

% User selects morphological locations for setting a semi-polar gride of 28 lines
% Selections are also made for the location of the velum and the creation
% of a threshold for image binarization and vocal tract aperture estimation
% in mri_thresh.m

% The semi-polar grid does not contain the lips, i.e., the grid only
% extends from the glottis to the alveolar ridge

% Input arguments:
%   data:   registered image matrix from register_mri.m

% Output arguments:
%   gridlines:  x,y coordinates of the 28 lines of the semi-polar grid
%   params:     paramaters related the gridlines to be used in later functions

% Example:
% [gridlines,params] = set_mri_grid_nolips(regmatrix);


%% Function starts here
framecheck = 1;

% loop through random selection of images until a suitable image is obtained
while framecheck == 1

clf
rframe = randi([1,size(data,3)]);
imagesc(data(:,:,rframe));
set(gca,'Ydir','normal')

% check to see if image is appropriate for selection (== oral vowel)
action	= input( '   Is the velum up? [y/n]  ', 's') ;
    if strcmpi( action,'n' ) || strcmpi( action,'no' )
        clf
    else
        framecheck = 2;
    end
end

hold on
grid = {};
params = {};
gridlines = zeros(28,4);

% user selection of morphological locations
fprintf( '\n   Select glottis... ' );
grid.glot = ginput(1);
fprintf( '\n   Select top side of velopharyngeal port... ' );
grid.vel = ginput(1);
fprintf( '\n   Select alveolar ridge... ' );
grid.alv = ginput(1);
fprintf( '\n   Select air within oral tract... ' );
grid.air = ginput(1);

% set origin for lingual fan (midpoint between the glottis and aleolar ridge)
grid.org.ling = mean([grid.glot;grid.alv]);

% translate coordinates with reference to lingual origin
grid.pol.alv.cart = grid.alv - grid.org.ling;
grid.pol.vel.cart = grid.vel - grid.org.ling;

% convert Cartesian to polar coordinates
[grid.pol.alv.theta, grid.pol.alv.rho] = cart2pol(grid.pol.alv.cart(1), grid.pol.alv.cart(2));
[grid.pol.vel.theta, grid.pol.vel.rho] = cart2pol(grid.pol.vel.cart(1), grid.pol.vel.cart(2));

% fan rho limit
grid.pol.lim = max([grid.pol.alv.rho, grid.pol.vel.rho]);
grid.pol.min = grid.pol.lim*0.2;


%% polar grid lines extending around tongue
for i = 1:20
    fanseg = grid.pol.alv.theta*i/20;
    [segCart.xmax, segCart.ymax] = pol2cart(fanseg,grid.pol.lim);
    segCart.xmax = segCart.xmax + grid.org.ling(1);
    segCart.ymax = segCart.ymax + grid.org.ling(2);
    
    [segCart.xmin, segCart.ymin] = pol2cart(fanseg,grid.pol.min);
    segCart.xmin = segCart.xmin + grid.org.ling(1);
    segCart.ymin = segCart.ymin + grid.org.ling(2);
    
    line([segCart.xmin segCart.xmax], [segCart.ymin segCart.ymax],'color','w','linewidth',1)
    
    gridlines(i+8,1:2) = [segCart.xmin segCart.xmax];
    gridlines(i+8,3:4) = [segCart.ymin segCart.ymax];
end

%% grid lines extending down to glottis
[segCart.xmax, segCart.ymax] = pol2cart(grid.pol.alv.theta/20,grid.pol.lim);
segCart.xmax = segCart.xmax + grid.org.ling(1);
segCart.ymax = segCart.ymax + grid.org.ling(2);

[segCart.xmin, segCart.ymin] = pol2cart(grid.pol.alv.theta/20,grid.pol.min);
segCart.xmin = segCart.xmin + grid.org.ling(1);
segCart.ymin = segCart.ymin + grid.org.ling(2);

for i = 1:8
    segy = grid.org.ling(2) - (i-1)*(grid.org.ling(2) - grid.glot(2))/7;
    line([segCart.xmin segCart.xmax], [segy segy],'color','w','linewidth',1)
    
    gridlines(9-i,1:2) = [segCart.xmin segCart.xmax];
    gridlines(9-i,3:4) = [segy segy];
end


%% find grid lines closest to velum
dists = {};

for i = 1:size(gridlines,1)
    %distance to velum
    dists.vel(i) = sqrt((gridlines(i,2) - grid.vel(1))^2 + (gridlines(i,4) - grid.vel(2))^2);
end

% grid line closest to velum
[~,params.velum] = min(dists.vel);


%% find grid line closest to air selection
dists = {};

for i = 1:size(gridlines,1)
    %distance to air selection
    dists.air(i) = sqrt((gridlines(i,2) - grid.air(1))^2 + (gridlines(i,4) - grid.air(2))^2);
end

% grid line closest to air selection
[~,params.air] = min(dists.air);

% calculate air threshold
slice = improfile(data(:,:,rframe),...
    [gridlines(params.air,1) gridlines(params.air,2)],... 
    [gridlines(params.air,3) gridlines(params.air,4)]);
params.thresh = 0.25*(max(slice) - min(slice));

% alveolar ridge
params.alv = 28;

% log frame used
params.frame = rframe;

% log grid selections
params.grid = grid;
end