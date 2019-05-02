function [regmatrix,tforms] = register_mri(matrix)
%% Function description
% 2018, Christopher Carignan

% Rigid transformation (translation and rotation) of the MR image matrix from
% concat_mri.m

% Image registration is based on:
%   1) pick first frame as reference image
%   2) manually identifying the region of the speaker's head above which point
%       there will be no movement related to the vocal tract, i.e., make
%       sure it is above the velum
%   3) compare all images to the first image in the matrix, and transform
%       translation and rotation accordingly

% Input arguments:
%   matrix:     concatenated image matrix from concat_mri.m

% Output arguments:
%   regmatrix:  registered image matrix
%   tforms:     transformation matrices

% Example:
% [regmatrix,tforms] = register_mri(matrix);


%% Function starts here

% preallocate image matrix
regmatrix = uint8(zeros(size(matrix)));

% show image and get user selection
imshow(matrix(:,:,1));
set(gca,'Ydir','normal')
x = ginput(1);
close(gcf)

% get y value of user selection for image masking
cutoff = round(x(2));

% mask out image below y value of user selection
frames = matrix;
frames(1:cutoff,:,:) = 0;

% initialize image registration
[optimizer,metric] = imregconfig('monomodal');

% first frame used as fixed comparison
fixed = frames(:,:,1);
tic

% preallocate cell array for transformation matrices
tforms = cell(size(frames,3),1);

for i = 1:size(frames,3)
    % create the transformation matrix
    tforms{i} = imregtform(frames(:,:,i),fixed,'rigid',optimizer,metric);
    
    % transform the image
    regmatrix(:,:,i) = imwarp(matrix(:,:,i),tforms{i},'OutputView',imref2d(size(fixed)));
    eval(['fprintf( ''\n   Registering frame ',num2str(i),' of ',num2str(size(frames,3)),' ... '' );'])
end
toc
end

