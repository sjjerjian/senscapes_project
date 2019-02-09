% Spectrograms

clear;clc
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';

subj   = 'MED_011';
cd([folder subj])
files = dir('*.cnt');

close all
for i=1%:length(files)

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

    cfg = [];
    cfg.channel = 'eeg';
    cfg.method = 'mtmfft';
    cfg.output = 'pow';
    cfg.tapsmofrq = 3;
    cfg.foi   = [4:120];
    cfg.pad='nextpow2';
    [freq] = ft_freqanalysis(cfg, ftdata_epoch);
    
%     cfg = [];
%     ft_singleplotER(cfg, freq)

%     [spectrum,ntaper,freqoi] = ft_specest_mtmfft(ftdata.trial{1},ftdata.time{1},'taper','hanning');

    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'eeg';
    cfg.method       = 'wavelet';
    cfg.taper        = 'dpss';
    cfg.foi          = 4:2:120;                         
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*5;  
    cfg.toi          = 0:0.5:180;                    
    cfg.pad          = 'nextpow2';
    TFRhann          = ft_freqanalysis(cfg, ftdata);
    
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
