clear all
banddef = [4 8;9 13;14 30;30 60;60 120]; bandname = {'theta','alpha','beta','low gamma','high gamma'};
for band = 1 :numel(bandname)

load(['C:\Users\Tim\Documents\psilocybin_analysis\data\virtual_channels_' bandname{band} '.mat'])

vchan.label = {'left','right'};
vchan.fsample = 2048;
vchan.time{1} = time(:,1)';
vchan.trial{1} = vchandata';

 cfg = [];
 cfg.bpfilter = 'yes';
 cfg.bpfreq = banddef(band,:);
 thetadata = ft_preprocessing(cfg,vchan);
 

 thetadata = thetadata.trial{1};
 thetaenv = abs(hilbert(thetadata));
 thetaphase = angle(hilbert(thetadata));
 
 thetaenv = (thetaenv-mean(thetaenv,2))./std(thetaenv,[],2);
 thetaenv = thetaenv - min(thetaenv,[],2);
windowSize = 256*10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
thetaenv_slow = abs(hilbert(filter(b,a,thetaenv)));
thetaenv = thetaenv.^2;
delay = 10;
 tvec = linspace(0,size(thetaenv_slow,2)/vchan.fsample,size(thetaenv_slow,2));

 x1 = repmat(pi/2,1,delay); x2 = repmat(-pi,1,delay); A = [0.8 0.8]; x3 = repmat(-1,1,delay); x4 = repmat(-1,1,delay);
 for i = delay+1:numel(tvec);
 x1(i) = thetaenv(1,i).*sin(2^2*pi*mean(banddef(band,:)).*x3(i-1).*tvec(i) + sin(A(1)*x2(i-10)))...
     + thetaenv(1,i).*sin(2^6*pi*mean(banddef(band,:)).*x3(i-1).*tvec(i)+pi)...
     ; %+ 0.5*thetaenv(1,i).*sin(2^8*pi*mean(banddef(band,:)).*x3(i-1).*tvec(i)+2*pi/3);
 x2(i) = thetaenv(2,i).*sin(2^2*pi*mean(banddef(band,:)).*x4(i-1).*tvec(i) + sin(A(2)*x1(i-10)))...
     + thetaenv(2,i).*sin(2^6*pi*mean(banddef(band,:)).*x4(i-1).*tvec(i)+pi)...
     ; %+ thetaenv(2,i).*sin(2^8*pi*mean(banddef(band,:)).*x4(i-1).*tvec(i)+pi/6);
 x3(i) = 0.05*sin(thetaenv_slow(1,i-1))+1;
 x4(i) = 0.05*sin(thetaenv_slow(2,i-1))+1;
 end
 x1 = x1(delay+1:end);  x2 = x2(delay+1:end); x3 = x3(delay+1:end);
 
 figure
  tvec = linspace(0,size(x1,2)/vchan.fsample,size(x1,2));
 plot(tvec,x1,tvec,x2); hold on
 
 
refsamp = 44100; tarleng = 256;
 fsamp_fake = 400;
 y1 = resample(x1,refsamp,fsamp_fake);
 y1 = (y1-mean(y1))/(5*std(y1));
 y1(y1>0.95) = 0.95;  y1(y1<-0.95) = -0.95;
y2 = resample(x2,refsamp,fsamp_fake);
 y2 = (y2-mean(y2))/(5*std(y2));
 y2(y2>0.95) = 0.95;  y2(y2<-0.95) = -0.95;
figure
 tvec = linspace(0,size(y1,2)/refsamp,size(y1,2));
plot(tvec,y1,tvec,y2)


% audiowrite(['C:\Users\Tim\Documents\psilocybin_analysis\sounds\' bandname{band} '_doubleoscillators_sync.wav'],[y1;y2]',refsamp)
player = audioplayer([y1;y2]',refsamp);
play(player); pause(10); stop(player)
close all
end
