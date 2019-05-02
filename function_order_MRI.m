% concatenate images from the segmented sentence of separate recordings
[matrix,mrinfo] = concat_mri('/vnbdata/PHYSIO2/dfg_mrinasals/rec26072017/vol_8261/','dfg_mrinasals_8261_S03');

% register images (translation and rotation)
[regmatrix,tforms] = register_mri(matrix);

% visually inspect results of registration
implay(matrix,100)
implay(regmatrix,100)

% set semi-polar grid (28 lines from glottis to alveolar ridge)
[gridlines,params] = set_mri_grid_nolips(regmatrix);

% manually set outer edge of vocal tract
posterior = set_mri_posterior(regmatrix,gridlines,params);

% automatically set outer edge of vocal tract in entire image set
postfits = get_mri_posterior(regmatrix,posterior,params);

% define the grid lines for the following regions: 
% alveolar, palatal, velar, hyper-pharyngeal, hypo-pharyngeal
% recommended: 1:3, 4:10, 11:15, 16:21, 22:28
[regions,regplot] = set_vt_regions(regmatrix,gridlines,postfits,params);

% analyze gridlines
[velum1,gridsigs] = analyze_mri_grid(regmatrix,gridlines,postfits,params);

% analyze gridlines (v 2.0)
gridsigs2 = analyze_mri_grid2(regmatrix,gridlines,postfits,params);

% create PCA-based velum signal
[velum2,PCdata] = velum_PCA(regmatrix,mrinfo);

% create PCA-based labial signal
labial = labial_signal(regmatrix,mrinfo);

% create articulatory signals (v 2.0)
artsigs = art_sigs2(regions,velum1,velum2,labial,gridsigs,gridsigs2);

% plot articulatory signals
plot_mri_sigs(1,artsigs,2,mrinfo)

% create VT aperture functions (based on thresholding technique)
apertures = mri_thresh(regmatrix,gridlines,postfits,params);

% create VT aperture function table for entire vowel interval
vttablevowel = vt_table_vowel(apertures,mrinfo);

% convert cell array to table
vttablevowel = cell2table(vttablevowel);

% write out table
eval(strcat('writetable(vttablevowel,''/homes/c.carignan/Dokumente/DFG/results/',mrinfo.speaker,'_vt_table.txt'');'))

% create table of articulatory signals
nasaltracks = nasal_tracks(artsigs,mrinfo);

% convert cell array to table
nasaltracks = cell2table(nasaltracks);

% write out table
eval(strcat('writetable(nasaltracks,''/homes/c.carignan/Dokumente/DFG/results/',mrinfo.speaker,'_sigs_table.txt'');'))


%% Misc. functions

% create VT aperture function table for specific (normalized) time point
timepoint = 0.2;

eval(strcat('vttable',num2str(timepoint*100),' = vt_table_point(apertures,mrinfo,',num2str(timepoint),');'))

% convert cell array to table
eval(strcat('vttable',num2str(timepoint*100),' = cell2table(vttable',num2str(timepoint*100),');'))

% write out table
eval(strcat('writetable(vttable',num2str(timepoint*100),',''/homes/c.carignan/Dokumente/DFG/results/',mrinfo.speaker,'_vt_',num2str(timepoint*100),'.txt'');'))
