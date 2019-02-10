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

    cfg=[];
    cfg.dataset = [files(i).folder '/' files(i).name];
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bpfreq   = [4 120];
    cfg.bsfreq   = [49.5 50.5; 99.5 100.5];
    ftdata = ft_preprocessing(cfg);
       
    cfg = [];
    cfg.length = 2;
    cfg.overlap = 0;
    ftdata_epoch = ft_redefinetrial(cfg,ftdata);
    
    % artefact rejection
    ftdata_epoch = ft_rejectvisual(cfg, ftdata_epoch);
    
%     cfg=[];
%     cfg.artfctdef.zvalue.channel = 'eeg';
%     cfg.artfctdef.zvalue.cutoff  = 3;
%     cfg.artfctdef.reject = 'complete';
%     ftdata_epoch = ft_rejectartifact(cfg,ftdata_epoch);
%     cfg = ft_databrowser(cfg, ftdata);

    % power spectra
    cfg = [];
    cfg.channel = 'eeg';
    cfg.method = 'mtmfft';
    cfg.output = 'pow';
    cfg.tapsmofrq = 3;
    cfg.foi   = [4:120];
    cfg.pad='nextpow2';
    [freq] = ft_freqanalysis(cfg, ftdata_epoch);
    
  
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'eeg';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = 4:2:120;                         
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  
    cfg.toi          = 0:0.05:2;      % 50ms stepsize              
    cfg.pad          = 'nextpow2';
    cfg.keeptrials   = 'yes';
    TFRhann          = ft_freqanalysis(cfg, ftdata_epoch);
    
    begs = ftdata_epoch.sampleinfo(:,1);
    ends = ftdata_epoch.sampleinfo(:,2);
    time = bsxfun(@plus,TFRhann.time,begs/ftdata_epoch.fsample)';
    
    TFRt = TFRhann;
    TFRt.powspctrm = permute(TFRt.powspctrm, [2 3 4 1]);
    TFRt.powspctrm = reshape(TFRt.powspctrm,size(TFRt.powspctrm,1),size(TFRt.powspctrm,2),size(TFRt.powspctrm,3)*size(TFRt.powspctrm,4));
    TFRt.dimord    = 'chan_freq_time';
    TFRt.time      = reshape(time,size(time,1)*size(time,2),[]);
    
    cfg = [];
    cfg.channel = 'C3';
    ft_singleplotTFR(cfg, TFRhann)
    
    for l=1:length(TFRhann.label)
        cfg = [];
        cfg.baseline     = [0 10];
        cfg.baselinetype = 'relative';
        cfg.maskstyle    = 'saturation';
        %     cfg.masknans     = 'yes';
        cfg.zlim         = [0 3];
        cfg.channel      = TFRhann.label{l};
        figure
        ft_singleplotTFR(cfg, TFRhann);
        
    end
end
