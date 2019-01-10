function makeWAV(cfg,y,Fs)

if nargin < 3, Fs = 44100; end
assert(ismatrix(y),'Input data must be a 2-D matrix')

if ~isfield(cfg,'dir') 
    cfg.dir = pwd; 
end
if ~isfield(cfg,'title')
    cfg.title = 'sound';
end
if ~isfield(cfg,'bps') % bits per sample
    cfg.bps = 24;
end 
if ~isfield(cfg,'artist')
    cfg.artist= 'unknown';
end
if ~isfield(cfg,'comment')
    cfg.comment = '';
end

cd(cfg.dir)
audiowrite(sprintf('%s.wav',cfg.title), y, Fs,...
    'BitsPerSample', cfg.bps, 'Title',cfg.title ,...
    'Artist',cfg.artist, 'Comment', cfg.comment)

% p = audioplayer(y,Fs);
% play(p); pause(10); stop(p)