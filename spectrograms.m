% Spectrograms

% requires fieldtrip and export_fig toolboxes

clear;clc
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
% folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/20 Minute Open Presence Runs/';

subj   = 'MED_016';
cd([folder subj])
files = dir('*.cnt');

reclen = 3*60;
% reclen = 20*60; 

%%
close all
for i=1%:length(files)
    [~,fname]=fileparts(files(i).name);
    fname = strsplit(fname,'_');
    
    cfg=[];
    cfg.dataset = [files(i).folder '/' files(i).name];
    cfg.bpfilter = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bpfreq   = [4 120];
    cfg.bsfreq   = [49.5 50.5; 99.5 100.5];
    ftdata = ft_preprocessing(cfg);
    
    % artefact rejection
    cfg = ft_databrowser(cfg, ftdata);
    cfg.artfctdef.reject = 'partial';
    ftdata = ft_rejectartifact(cfg,ftdata);

    % power spectra, epoched
%     cfg = [];
%     cfg.length = reclen;
%     ftdata_epoch = ft_redefinetrial(cfg,ftdata);

%     cfg = [];
%     ftdata_epoch = ft_rejectvisual(cfg, ftdata_epoch);

%     cfg = [];
%     cfg.channel = 'eeg';
%     cfg.method = 'mtmfft';
%     cfg.output = 'pow';
%     cfg.tapsmofrq = 3;
%     cfg.foi   = [4:120];
%     cfg.pad='nextpow2';
%     [freq] = ft_freqanalysis(cfg, ftdata_epoch);
    

    % time-frequency spectrograms
    % 
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'eeg';
    cfg.method       = 'wavelet';
%     cfg.taper        = 'dpss';
    cfg.foi          = 4:2:120;                         
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*5;  % window size
    cfg.toi          = -2:2:(reclen+2);      % stepsize              
    cfg.pad          = 'nextpow2';
%     cfg.keeptrials   = 'no';
    TFR          = ft_freqanalysis(cfg, ftdata);
    
    % if time series was cut into short trials, then want to reformat them into long series    
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
    

    % normalize
    cfg = [];
    cfg.baseline = [0 180];
    cfg.baselinetype = 'relative';
    [TFR] = ft_freqbaseline(cfg, TFR);

    cd('/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/senscapes_project/figs')
    cfg = [];
    cfg.zlim     = [0 3];
    pdfname = sprintf('%s_%s_%s_%s.pdf',subj,fname{1},fname{2},fname{3});

    for lab=1:length(TFR.label)
        clf
        cfg.channel = TFR.label{lab};
        ft_singleplotTFR(cfg, TFR); 
        export_fig -nocrop -append -pdf
    end
    

end
