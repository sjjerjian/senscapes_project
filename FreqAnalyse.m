
clear;clc
% requires fieldtrip toolbox
% change folder to match local
folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/Dull, Clarity, Open Presence/';
% folder = '/Users/stevenjerjian/Desktop/Senscapes/Meditation Project/Public Dissemination/20 Minute Open Presence Runs/';

subj   = 'MED_016';
cd([folder subj])
files = dir('*.cnt');

%%
% 180s for sets of 3 meditations, 
% or 20min runs
reclen = 3*60; %180s
reclen = 20*60;

for i=1:length(files)
    [~,fname]=fileparts(files(i).name);
    fname = strsplit(fname,'_');
    ff{i} = fname{3};
end

% DULL
i = strcmp(ff,'Dull'); 
cfg=[];
cfg.dataset = [files(i).folder '/' files(i).name];
[powspcDull,TFRDull,dataDull,data_epochDull] = run_freq_analysis(cfg,reclen);

% CLARITY
i = strcmp(ff,'Clarity');
cfg=[];
cfg.dataset = [files(i).folder '/' files(i).name];
[powspcClarity,TFRClarity,dataClarity,data_epochClarity] = run_freq_analysis(cfg,reclen);

% OPEN PRESENCE
% ft_redefinetrial running into an error here for MED_007...not clear why
i = strcmp(ff,'OpenPresence');
cfg=[];
cfg.dataset = [files(i).folder '/' files(i).name];
[powspcOpenPresence,TFROpenPresence,dataOpenPresence,data_epochOpenPresence] = run_freq_analysis(cfg,reclen);

if 0
%% Power Spectra

powspcClarity_norm = powspcClarity;
powspcClarity_norm.powspctrm = powspcClarity_norm.powspctrm ./ powspcDull.powspctrm;

% powspcOpenPresence_norm = powspcOpenPresence;
% powspcOpenPresence_norm.powspctrm = powspcOpenPresence_norm.powspctrm ./ powspcDull.powspctrm;

cfg = [];

chs = powspcClarity.label;
for ch=1:length(chs)
    if strcmp(chs{ch},'A2'),continue,end
    clf
    cfg.channel = chs{ch};%powspcClarity.label(1:8); %{'FP*','F7','F3','FZ','F4','F8'};
    subplot(211)
%     cfg = ft_singleplotER(cfg,powspcClarity,powspcDull,powspcOpenPresence);
    cfg = ft_singleplotER(cfg,powspcClarity,powspcDull);
    ylabel('Power')
    set(gca,'xtick',0:5:80)
    
    subplot(212)
%     cfg = ft_singleplotER(cfg,powspcClarity_norm,powspcOpenPresence_norm); %ylim([0.5 1.5])
    cfg = ft_singleplotER(cfg,powspcClarity_norm); ylim([0.5 1.5])
    ylabel('Ratio to Dull')
    set(gca,'xtick',0:5:80)
    export_fig -nocrop -append -pdf Med_007_PowerSpectra
end
% %%
% cfg           = [];
% cfg.channel   = {'eeg','-A1','A2','TP7'};
% cfg.method    = 'mtmfft';
% cfg.taper     = 'dpss';
% cfg.output    = 'fourier';
% cfg.tapsmofrq = 3;
% cfg.foi       = [4:80];
% freq          = ft_freqanalysis(cfg, data_epochClarity);

%% Time-Frequency Spectrograms

cfg = [];
cfg.baseline = [0 reclen];
cfg.baselinetype = 'relative';
[TFRDull] = ft_freqbaseline(cfg, TFRDull);

cfg = [];
cfg.zlim     = [0 3];
chs = TFRDull.label;
for ch=1:length(chs)
    cfg.channel = chs{ch};
    ft_singleplotTFR(cfg,TFRDull);
    export_fig -nocrop -append -pdf Med_007_Dull_Spectrograms
end

end 

%% worker function

function [powspc,TFR,data,data_epoch] = run_freq_analysis(cfg,reclen)

cfg.bpfilter = 'yes';
cfg.bsfilter = 'yes';
cfg.bsfreq   = [49.5 50.5];
cfg.bpfreq   = [4 80];
data = ft_preprocessing(cfg);

cfg = [];
cfg.length = 2;
data_epoch = ft_redefinetrial(cfg,data);

cfg.channel = 'eeg';
cfg.artfctdef.reject = 'complete';
cfg    = ft_databrowser(cfg, data_epoch);
data_epoch = ft_rejectartifact(cfg,data_epoch);

cfg = [];
cfg.channel   = 'eeg';
cfg.method    = 'mtmfft';
cfg.output    = 'pow';
cfg.tapsmofrq = 3;
cfg.foi   = [4:80];
cfg.pad='nextpow2';
powspc = ft_freqanalysis(cfg, data_epoch);

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'eeg';
cfg.method       = 'wavelet';
%     cfg.taper        = 'dpss';
cfg.foi          = 4:2:80;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*5;  % window size
cfg.toi          = -2:2:reclen+2;      % stepsize
cfg.pad          = 'nextpow2';
%     cfg.keeptrials   = 'no';
TFR          = ft_freqanalysis(cfg, data);

end
