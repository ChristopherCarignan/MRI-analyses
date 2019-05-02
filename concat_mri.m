function [matrix,info] = concat_mri(mypath,filename)
%% Function description
% 2018, Christopher Carignan

% Concatenate MRI images from DFG project for further analysis
% Images are downsized and converted to 8-bit, in order to save space
% Concatenation is based on sentence segmentation time points from Praat

% Input argments:
%   mypath:     path to folder containing Matlab info files
%   filename:   speaker-specific file name

% Output arguments:
%   matrix:     matrix of concatenated MR images
%   info:       info about recording (other functions will add to this variable)

% Example:
% [matrix,mrinfo] = concat_mri('/vnbdata/PHYSIO2/dfg_mrinasals/rec26072017/vol_8261/','dfg_mrinasals_8261_S03');


%% Function starts here

% load Praat TextGrid information
eval(strcat('load(''',mypath,filename,'_cut_tg.mat'')'));
matpath = strcat(mypath,'mat/');
seginfo = data;
trials = max(data(:,4));

% preallocate image matrix
eval(strcat('load(''',matpath,filename,'_rtmri_0001.mat'')'));
matrix = zeros(round(size(data,1)/2),round(size(data,2)/2));

% get some info
mystr = strsplit(filename,'_');
speaker = mystr(length(mystr));
speaker = speaker{1,1};

% get some more info
info = {};
info.path = mypath;
info.filename = filename;
info.speaker = speaker;
info.sr = samplerate;

% initiate dummy variable for frame concatenation
x = 1;

for i = 1:trials
    
    % load the image file
    if i < 10
        eval(strcat('load(''',matpath,filename,'_rtmri_000',num2str(i),'.mat'')'));
    elseif i>9 && i<100
        eval(strcat('load(''',matpath,filename,'_rtmri_00',num2str(i),'.mat'')'));
    elseif i>99 && i<1000
        eval(strcat('load(''',matpath,filename,'_rtmri_0',num2str(i),'.mat'')'));
    elseif i>999 && i<10000
        eval(strcat('load(''',matpath,filename,'_rtmri_',num2str(i),'.mat'')'));
    end
    
    % get segmentation time points for this trial
    trialseg                = seginfo(seginfo(:,4)==i,:);
    
    % log segmentation time points (1 = sentence, 2 = word, 3 = vowel)
    info.start(i).stime     = trialseg(trialseg(:,3)==1,1);
    info.end(i).stime       = trialseg(trialseg(:,3)==1,2);
    info.start(i).wtime     = trialseg(trialseg(:,3)==2,1);
    info.end(i).wtime       = trialseg(trialseg(:,3)==2,2);
    info.start(i).vtime     = trialseg(trialseg(:,3)==3,1);
    info.end(i).vtime       = trialseg(trialseg(:,3)==3,2);
    
    % convert time points to MRI frame numbers for this specific image file
    frame1 = round(info.start(i).stime*samplerate);
    frame2 = round(info.end(i).stime*samplerate);
    
    % downsample images (1/2 resolution) from sentence and add to matrix
    matrix(:,:,x:(x + frame2 - frame1)) = imresize(data(:,:,frame1:frame2),0.5);
    
    % log sentence frame numbers in sequential matrix order,
    % update dummy variable
    info.start(i).sframe = x;
    x = x + frame2 - frame1 + 1;
    info.end(i).sframe = x - 1;
    
    % word frames
    info.start(i).wframe    = info.start(i).sframe + round((info.start(i).wtime - info.start(i).stime)*samplerate);
    info.end(i).wframe      = info.start(i).sframe + round((info.end(i).wtime - info.start(i).stime)*samplerate);
    
    % vowel frames
    info.start(i).vframe    = info.start(i).sframe + round((info.start(i).vtime - info.start(i).stime)*samplerate);
    info.end(i).vframe      = info.start(i).sframe + round((info.end(i).vtime - info.start(i).stime)*samplerate);
    
    % trial info
    info.item{i} = item_id;
    info.trial1(i) = i;
end

% convert image matrix to 8-bit and maximize dynamic range
matrix = uint8(rescale(matrix,0,255));


%% Add additional trial variables
info = trial_variables(info);
end