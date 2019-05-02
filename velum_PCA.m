function [velum,PCdata] = velum_PCA(mrdata,mrinfo)
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

% crop all images to ROI
for i = 1:size(mrdata,3)
    my_img = mrdata(:,:,i);
    this_img = immultiply(my_img, poly_mask);
    this_img = this_img(min_y:max_y,min_x:max_x); % create cropped image
    
    dims(i,:) = reshape(this_img, 1, size(this_img,1)*size(this_img,2));
end

% limit cropped image set to only nasal items
nasalcheck = find(strcmp(mrinfo.nasality,'nasal'));
nasals = mrinfo.trial2(nasalcheck);
nasalframes(:,1) = [mrinfo.start(nasals).wframe]; % get start frames
nasalframes(:,2) = [mrinfo.end(nasals).wframe]; % get end frames

% concatenate new image matrix from only nasal frames
dims2 = [];
for i = 1:size(nasalframes,1)
    dims2 = vertcat(dims2,dims(nasalframes(i,1):nasalframes(i,2),:));
end

% do the PCA stuff
mus = mean(dims2,1);
[coeffs,~] = pca(dims2,'centered',true);
newscores = (dims-mus)*coeffs; % use eigenvectors to project PC1 scores
velum = newscores(:,1);
velum = rescale(velum,0,1); % scale values

% reshape PC coefficients back to original spatial orientation
map1 = reshape(coeffs(:,1), size(this_img,1), size(this_img,2));
new_img = rescale(my_img);
new_img(min_y:max_y,min_x:max_x) = rescale(map1);

% save PC data
PCdata.matrix = dims2;
PCdata.ROI = cell2mat(poly_coords);
PCdata.PCimg = new_img;
PCdata.coeffmap = map1;
PCdata.eigenvectors = coeffs;
PCdata.mus = mus;
PCdata.frames = nasalframes;

% verify orientation of PC coefficients, which can be arbitrary
clf
imagesc(new_img)
set(gca,'Ydir','normal')

pcans = questdlg('Is the velum moving UP or DOWN relative to positive PC loadings?',...
    'PC orientation confirmation','UP','DOWN','UP') ;

if strcmp(pcans,'UP')==1
    % flip PC scores if + PC coefficients = velum opening instead of closing
    velum = 1-velum;
end
    
end

 