% Spectrograms

clear;clc
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
% folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/20 Minute Open Presence Runs/';

subj   = 'MED_007';
cd([folder subj])
files = dir('*.cnt');

%%
close all
for i=1%:length(files)
    clf
    [~,fname]=fileparts(files(i).name);
    fname = strsplit(fname,'_');
    
    cfg=[];
    cfg.dataset = [files(i).folder '/' files(i).name];
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bpfreq   = [4 120];
    cfg.bsfreq   = [49.5 50.5; 99.5 100.5];
    ftdata = ft_preprocessing(cfg);
       
    cfg = [];
    cfg.length = 180;
    ftdata_epoch = ft_redefinetrial(cfg,ftdata);
    
    % artefact rejection
%     cfg = [];
%     ftdata_epoch = ft_rejectvisual(cfg, ftdata_epoch);
%     cfg.artfctdef.zvalue.channel = 'eeg';
%     cfg.artfctdef.zvalue.cutoff  = 3;
%     cfg.artfctdef.reject = 'complete';
%     ftdata_epoch = ft_rejectartifact(cfg,ftdata_epoch);
%     cfg = ft_databrowser(cfg, ftdata);

    % power spectra
%     cfg = [];
%     cfg.channel = 'eeg';
%     cfg.method = 'mtmfft';
%     cfg.output = 'pow';
%     cfg.tapsmofrq = 3;
%     cfg.foi   = [4:120];
%     cfg.pad='nextpow2';
%     [freq] = ft_freqanalysis(cfg, ftdata_epoch);
    
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'eeg';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = 4:120;                         
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % window size
    cfg.toi          = -0.5:0.05:180.5;      % stepsize              
    cfg.pad          = 'nextpow2';
%     cfg.keeptrials   = 'no';
    TFRhann          = ft_freqanalysis(cfg, ftdata_epoch);
    
%     if strcmp(cfg.keeptrials,'yes')
%         ps = permute(TFRhann.powspctrm(:,:,:,pos(1):pos(2)),[2 3 4 1]);
%         [~,pos(1)]=min(abs(TFRhann.time-0));
%         [~,pos(2)]=min(abs(TFRhann.time-180));
%         ps = reshape(ps,size(ps,1),size(ps,2),size(ps,3)*size(ps,4));
%         TFRhann.powspctrm = ps;
%         TFRhann.dimord = 'chan_freq_time';
%         begs = ftdata_epoch.sampleinfo(:,1);
%         ends = ftdata_epoch.sampleinfo(:,2);
%         
%         time = bsxfun(@plus,TFRhann.time(pos(1):pos(2)),begs/ftdata_epoch.fsample)';
%         time = reshape(time,size(time,1)*size(time,2),[]);
%         TFRhann.time = time;
%     end
    
    cfg = [];
    cfg.baseline = [0 180];
    cfg.baselinetype = 'relative';
    [TFRhann] = ft_freqbaseline(cfg, TFRhann);

    cd('/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/senscapes_project/figs')
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim     = [0 5];
    
%     for l=1:length(TFRhann.label)
%         cfg.channel = TFRhann.label{l};
%         ft_singleplotTFR(cfg, TFRhann);      
%     end
    cfg.layout  = 'biosemi32.lay';
    ft_multiplotTFR(cfg, TFRhann);     
    
end
