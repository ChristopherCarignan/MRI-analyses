function [signals] = art_sigs2(regions,velum1,velum2,labial,gridsigs,gridsigs2)
%% Function description
% 2018, Christopher Carignan

% Creates time-varying articulatory signals from MRI grid lines

% The oral articulatory signals are created by averaging the grid line 
% signals (from analyze_mri_grid.m) across the grid line groups defined by
% the user (from set_vt_regions.m)

% Input arguments:
%   regions:    grid line numbers for the different regions (from set_vt_regions.m)
%   velum1:     peak-based velum opening signal created from analyze_mri_grid.m
%   velum2:     PCA-based velum opening signal created from velum_PCA.m
%   gridsigs:   a matrix of time-varying signals from the 28 grid lines (from analyze_mri_grid.m)

% Output arguments:
%   signals:    the time-varying articulatory signals

% Example:
% artsigs = art_sigs(regions,velum1,velum2,gridsigs);


%% Function starts here
signals = {};
signals.velum1 = velum1;
signals.velum2 = velum2;
signals.lab = labial;

% average the gridline signals for each region
signals.alv = mean(gridsigs(:,regions.alv(1):regions.alv(2)),2);
signals.pal  = mean(gridsigs(:,regions.pal(1):regions.pal(2)),2);
signals.velar  = mean(gridsigs(:,regions.velar(1):regions.velar(2)),2);
signals.hyperph = mean(gridsigs(:,regions.hyper(1):regions.hyper(2)),2);
signals.hypoph = mean(gridsigs(:,regions.hypo(1):regions.hypo(2)),2);

% average the constriction degree for each region (signal 2.0)
signals.alv2 = mean(gridsigs2(:,regions.alv(1):regions.alv(2)),2);
signals.pal2  = mean(gridsigs2(:,regions.pal(1):regions.pal(2)),2);
signals.velar2  = mean(gridsigs2(:,regions.velar(1):regions.velar(2)),2);
signals.hyperph2 = mean(gridsigs2(:,regions.hyper(1):regions.hyper(2)),2);
signals.hypoph2 = mean(gridsigs2(:,regions.hypo(1):regions.hypo(2)),2);

% scale oral articulatory signals
signals.alv     = rescale(signals.alv,0,1);
signals.pal     = rescale(signals.pal,0,1);
signals.velar   = rescale(signals.velar,0,1);
signals.hyperph = rescale(signals.hyperph,0,1);
signals.hypoph  = rescale(signals.hypoph,0,1);

signals.alv2     = rescale(signals.alv2,0,1);
signals.pal2     = rescale(signals.pal2,0,1);
signals.velar2   = rescale(signals.velar2,0,1);
signals.hyperph2 = rescale(signals.hyperph2,0,1);
signals.hypoph2  = rescale(signals.hypoph2,0,1);
end

