clear;clc
% requires fieldtrip toolbox
% change folder to match local
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
% folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/20 Minute Open Presence Runs/';

subj   = 'MED_007';
cd([folder subj])
files = dir('*.cnt');

%%
close all
for i=1:2%length(files)

    cfg=[];
    cfg.dataset = [files(i).folder '/' files(i).name];
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq   = [49.5 50.5; 99.5 100.5];
    cfg.bpfreq   = [4 120];
    ftdata = ft_preprocessing(cfg);
    
    cfg = [];
    cfg.length = 2;
    ftdata_epoch = ft_redefinetrial(cfg,ftdata);
    
%     % muscle artefacts
%     cfg = [];
%     cfg.preproc.bpfilter    = 'yes';
%     cfg.preproc.bpfreq      = [110 140];
%     cfg.preproc.bpfiltord   =  8;
%     cfg.preproc.bpfilttype  = 'but';
%     cfg.preproc.rectify     = 'yes';
%     cfg.preproc.boxcar      = 0.2;
%     cfg.method = 'channel';
%     ftdata = ft_rejectvisual(cfg, ftdata);
    
%    cfg = [];
%    cfg.interactive = 'yes';
%    cfg.trl = ftdata_epoch.cfg.trl;
%    
%    cfg.artfctdef.zvalue.channel = 'eeg';
%    cfg.artfctdef.zvalue.cutoff  = 3;
%    [cfg, artifact] = ft_artifact_zvalue(cfg, ftdata);
   
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
        subplot(length(files),size(banddef,1),band+size(banddef,1)*(i-1))
        
        title(sprintf('%s: Sensor Dist\n %s power',fname{end},bandname{band}))
        cfg        = [];
        cfg.layout = 'biosemi32.lay';
        cfg.xlim   = banddef(band,:);
        cfg.parameter = 'powspctrm';
        % cfg.interactive = 'yes'; %% to choose channels
        ft_topoplotER(cfg, freqdata(i));
        
%         ft_singleplotER(cfg,freqdata(i));
    end
end

%% 
% sample sound

cfg.dataset='/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/MED_007/Run_005_Dull.cnt';

folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
subj   = 'MED_016';
cd([folder subj])

cfg.dataset = [folder '/' subj '/Run006_Clarity.cnt'];
cfg.bpfilter = 'yes';
cfg.bpfreq = [60 120];
ftdata=ft_preprocessing(cfg);

cfg=[];
y=ftdata.trial{1}(10:12,:)';
y=scalesignal(y);
makeWAV(cfg,y,44100)
