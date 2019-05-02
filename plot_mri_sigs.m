function [ ] = plot_mri_sigs(item,artsigs,veltype,info)
%% Function description
% 2018, Christopher Carignan

% Plots audio and articulatory signals for individual MRI trials

% Input arguments:
%   item:       the item number the user wants to plot
%   artsigs:    the time-varying articulatory signals (from art_sigs.m)
%   veltype:    which velum signal the user wants to plot:
%               1: peak-based velum opening signal created from analyze_mri_grid.m
%               2: PCA-based velum opening signal created from velum_PCA.m
%   info:       the MR info file from concat_mri.m

% Example:
% plot_mri_sigs(1,artsigs,2,mrinfo)


%% Function starts here

% grab the audio file
if item < 10
    eval(strcat('load(''',info.path,'mat/',info.filename,'_audio_000',num2str(item),'.mat'')'));
elseif item>9 && item<100
    eval(strcat('load(''',info.path,'mat/',info.filename,'_audio_00',num2str(item),'.mat'')'));
elseif item>99 && item<1000
    eval(strcat('load(''',info.path,'mat/',info.filename,'_audio_0',num2str(item),'.mat'')'));
elseif item>999 && item<10000
    eval(strcat('load(''',info.path,'mat/',info.filename,'_audio_',num2str(item),'.mat'')'));
end

% get MR frames for item (word segmentation)
mystart = info.start(item).wframe;
myend = info.end(item).wframe;

% articulatory signals
eval(['velum = artsigs.velum',num2str(veltype),'(mystart:myend);'])
alv = artsigs.alv(mystart:myend);
pal  = artsigs.pal(mystart:myend);
velar  = artsigs.velar(mystart:myend);
hyperph = artsigs.hyperph(mystart:myend);
hypoph = artsigs.hypoph(mystart:myend);

% time points for plotting MRI signals
mritime = 1000*linspace(1,length(alv),length(alv))/info.sr; 
mritime = [0 mritime(1:(end-1))];

% time points for plotting vowel boundary lines
line1 = 1000*(info.start(item).vtime-info.start(item).wtime);
line2 = 1000*(info.end(item).vtime-info.start(item).wtime);

% time points for plotting audio
audioseg = data(round(info.start(item).wtime*samplerate):round(info.end(item).wtime*samplerate));
audiotime = 1000*linspace(1,length(audioseg),length(audioseg))/samplerate;
audiotime = [0 audiotime(1:(end-1))];


%% plot the plots!
figure

% plot audio
subplot(7,1,1)
plot(audiotime,audioseg)
itemstr = strrep(info.item{item},'_','-');
title(itemstr)
xlim([min([audiotime mritime]) max([audiotime mritime])])
ylim([min(audioseg) max(audioseg)])
line([line1 line1], [min(audioseg) max(audioseg)],'color','r')
line([line2 line2], [min(audioseg) max(audioseg)],'color','r')
ylabel('Audio')

% plot velum opening signal
subplot(7,1,2)
plot(mritime,velum)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Velum opening')

% plot alveolar signal
subplot(7,1,3)
plot(mritime,alv)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Alveolar')

% plot palatal signal
subplot(7,1,4)
plot(mritime,pal)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Palatal')

% plot velar signal
subplot(7,1,5)
plot(mritime,velar)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Velar')

% plot hyper-pharyngeal signal
subplot(7,1,6)
plot(mritime,hyperph)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Hyper-phx')

% plot hypo-pharyngeal signal
subplot(7,1,7)
plot(mritime,hypoph)
xlim([min([audiotime mritime]) max([audiotime mritime])])
line([line1 line1], [-0.1 1.1],'color','r')
line([line2 line2], [-0.1 1.1],'color','r')
ylim([-0.1 1.1])
ylabel('Hypo-phx')

end

