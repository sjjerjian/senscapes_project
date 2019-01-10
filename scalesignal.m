function X = scalesignal(X)
% X = SCALESIGNAL(X)
%
% assume X is samples x channels x freqs, or samples x channels
%
% subtract mean for each channel / frequency separately
% then divide by absolute maximum

mu = mean(X,1);
X  = bsxfun(@minus, X, mu);

ma = max(abs(X),[],1);
X  = bsxfun(@rdivide, X, ma);
