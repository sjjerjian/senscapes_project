
% requires fieldtrip toolbox
% change folder to match local
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
subj   = 'MED_007';
cd([folder subj])
files = dir('*.cnt');

close all
for i=1:length(files)

    cfg=[];
    cfg.dataset = [files(i).folder '/' files(i).name];
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq   = [49.5 50.5; 99.5 100.5];
    cfg.bpfreq   = [4 120];
    ftdata = ft_preprocessing(cfg);
    
    if i==3,keyboard,end
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
    freqdata(i) = ft_freqanalysis(cfg, ftdata_epoch);
    
end

%% Plot Sensor Distributions 
figure;
banddef  = [4 8;9 13;14 30;30 60;60 120]; 
bandname = {'theta','alpha','beta','low gamma','high gamma'};
for i=1:length(files)
    [~,fname]=fileparts(files(i).name);
    fname = strsplit(fname,'_');
    for band = 1:5
        subplot(length(files),5,band+5*(i-1))
        title(sprintf('%s: Sensor Dist\n %s power',fname{end},bandname{band}))
        cfg        = [];
        cfg.layout = 'biosemi32.lay';
        cfg.xlim   = banddef(band,:);
        cfg.parameter = 'powspctrm';
        % cfg.interactive = 'yes'; %% select this and you can choose the channels!
        ft_topoplotER(cfg, freqdata(i));
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
