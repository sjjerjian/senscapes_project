
close all
for i=1:2
    
    cfg=[];
    if i==1
        cfg.dataset='/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/MED_007/Run_007_OpenPresence.cnt';
    else
        cfg.dataset='/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/MED_007/Run_005_Dull.cnt';
    end
    
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49.5 50.5; 99.5 100.5];
    cfg.bpfreq = [4 120];
    ftdata=ft_preprocessing(cfg);
    
    % figure
    % pwelch(data.trial{1}(10,:),[],[],[],data.fsample)
    % hold on
    % pwelch(data2.trial{1}(10,:),[],[],[],data.fsample)
    
    
    cfg = [];
    cfg.length = 2;
    ftdata_epoch = ft_redefinetrial(cfg,ftdata);
    
    cfg = [];
    cfg.channel = 'eeg';
    cfg.method    = 'mtmfft';
    cfg.output    = 'pow';
    cfg.tapsmofrq = 3;
    cfg.foi   = [4:128];
    cfg.pad='nextpow2';
    freqdata = ft_freqanalysis(cfg, ftdata_epoch);
    
    
    figure(1)
    plot(freqdata.freq,squeeze(mean(freqdata.powspctrm,1)))
    %
    %
    
    figure(2)
    banddef = [4 8;9 13;14 30;30 60;60 120]; bandname = {'theta','alpha','beta','low gamma','high gamma'};
    for band = 1:5
        subplot(2,5,band+5*(i-1))
        title({'Sensor Distribution of ' bandname{band} ' power'})
        cfg        = [];
        cfg.layout = 'biosemi32.lay';
        cfg.xlim   = banddef(band,:);
        cfg.parameter = 'powspctrm';
        % cfg.interactive = 'yes'; %% select this and you can choose the channels!
        ft_topoplotER(cfg, freqdata);
        %     savefigure_v2([R.projectfold 'images\sensorspace\'],['sensorDist_' bandname{band}],[],[],[]); close all
    end
end

%%
cfg.dataset='/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/MED_007/Run_005_Dull.cnt';

cfg.bpfilter = 'yes';
cfg.bpfreq = [60 120];
ftdata=ft_preprocessing(cfg);

cfg=[];
y=ftdata.trial{1}(10:12,:)';
y=scalesignal(y);
makeWAV(cfg,y,44100)
