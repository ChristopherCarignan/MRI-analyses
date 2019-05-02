function [lips] = labial_signal(mrdata,mrinfo)
%% Function description
% 2018, Christopher Carignan

% Create velum opening signal based on principal components analysis (PCA):
%   -user selects a region of interest (ROI) around the bounds of velum
%       movement
%   -the pixels that are located within the ROI are used as the dimensions
%       in the PCA model
%   -a subset of the images, restricted to only words containing nasal
%       consonants, is used as the observations in the PCA model
%   -the eigenvectors (i.e., PCA coefficients) are used to project PC1
%       scores for all of the images
%   -the user confirms the polarity of the PC1 coefficients, ensuring that
%       the projected PC1 score will always relate to velum opening for
%       positive PC1 scores

% Input arguments:
%   mrdata:     registered image matrix from register_mri.m
%   mrinfo:     the MR info file from concat_mri.m

% Output arguments:
%   velum:              projected PC1 scores (scaled and oriented to correspond to velum opening for positive scores)
%   PCdata
%       .matrix:        the matrix of pixel values used as input to PCA model
%       .ROI:           x,y coordinates of polygonal region of interest
%       .PCimg:         reference image with overlay of PC1 coefficients
%       .coeffmap:      PC1 coefficients (i.e., PC1 eigenvectors)
%       .eigenvectors:  complete eigenvector matrix
%       .mus:           dimension-wise means of matrix used as input to PCA model
%       .frames:        frame numbers used in the nasal subset image matrix

% Example:
% [velum2,PCdata] = velum_PCA(regmatrix,mrinfo);


%% Function starts here
rframe = randi([1,size(mrdata,3)]);
my_img = mrdata(:,:,rframe);

waitfor(msgbox({'1. Click to create a polygon.';'';...
    '2. Make your final click line up with your first click (cursor = circle).';'';...
    '3. When finished, double-click inside selection.'},'ROI selection directions'))

validate = 'No'; %predefine 'validate' variable for while loop

while strcmp(validate,'No')==1 %loop will continue to run until user clicks 'Yes'
    [poly_mask,poly_x,poly_y] = roipoly(my_img);
    
    poly_x = round(poly_x);
    poly_y = round(poly_y);
    
    set(gcf,'NumberTitle','off');
    imshow(immultiply(my_img,poly_mask)) %overlays polynomial selection mask on image
    
    title('Region of interest selection')
    
    validate = questdlg('Is this selection correct?','Region of interest') ;
end

if strcmp(validate,'Cancel')==1 %if user cancels selection, all output variables are set to zero
    poly_mask=0;
    poly_x=0;
    poly_y=0;
end


% get boundaries of polygonal selection mask
poly_coords = bwboundaries(poly_mask);
[~, maxidx] = max(cellfun('length', poly_coords));

% find coordinates of polygonal selection mask
min_x = min(poly_coords{maxidx}(:,2));
max_x = max(poly_coords{maxidx}(:,2));

min_y = min(poly_coords{maxidx}(:,1));
max_y = max(poly_coords{maxidx}(:,1));

dims = zeros(size(mrdata,3),(max_x-min_x+1)*(max_y-min_y+1));
lips = zeros(size(mrdata,3),1);

% crop all images to ROI, sum pixels in ROI
for i = 1:size(mrdata,3)
    my_img = mrdata(:,:,i);
    this_img = immultiply(my_img, poly_mask);
    this_img = this_img(min_y:max_y,min_x:max_x); % create cropped image
    
    lips(i) = sum(this_img(:));
end

% rescale gridline signals
lips = rescale(lips,0,1);
end