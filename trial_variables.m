function [mrinfo] = trial_variables(mrinfo)
%% Function description
% 2018, Christopher Carignan

% Add additional trial variables to mrinfo struct
% This information excludes dummy items, so the number of trials will be
% different than the number of trials used in the concatenation from
% concat_mri.m

% Input arguments:
%   mrinfo:     the MR info file from concat_mri.m

% Output arguments:
%   mrinfo:     the MR info file, with addtional information added

% Example:
% mrinfo = trial_variables(mrinfo);


%% Function starts here

% get some variables
mypath = mrinfo.path;
filename = mrinfo.filename;

% load the Praat TextGrid code table for SAMPA info
eval(strcat('load(''',mypath,filename,'_cut_tg_code_table.mat'')'));
sampa = label;
sampanums = data(:,1);

% load Praat TextGrid information
eval(strcat('load(''',mypath,filename,'_cut_tg.mat'')'));

for i = 1:length(sampanums)
    % item info
    item = sampanums(i);
    mrinfo.trial2(i) = item;
    
    % get the SAMPA characters for this item
    sampastr = sampa(i,:);
    
    % onset context
    prev = sampastr(1:3);
    mrinfo.prev{i} = erase(prev,'_');
    
    % vowel context
    vowel = sampastr(4:5);
    mrinfo.vowel{i} = erase(vowel,'_');
    
    % coda context
    post = sampastr(6:8);
    mrinfo.post{i} = erase(post,'_');
    
    % is it oral or nasal coda context?
    if contains(post,'n') || contains(post,'m') || contains(post,'N')
        mrinfo.nasality{i} = 'nasal';
    else
        mrinfo.nasality{i} = 'oral';
    end
    
    strdat = label(data(:,4)==item,:);
    
    mystr = strdat(1,:);
    mystr = strsplit(mystr,'_');
    
    % get the stress context (based on the assumption that the stress
    % variable will be the only element in this string that has a single character
    sizes = cellfun('length', mystr);
    [~,stress] = min(sizes);
    if sizes(stress) == 1
            mrinfo.stress{i} = mystr{stress};
        else
            mrinfo.stress{i} = '?';
    end
end
end

