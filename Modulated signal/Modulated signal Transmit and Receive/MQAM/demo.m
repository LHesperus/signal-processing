% MQAM signal Transmit and Receive 
% author£º LCG
% date: 2019.09.03
clc
clear all
close all

%% parameter
% baseband parameter
signal.fs=64e3;                    % Sample frequency of baseband
signal.fb=10e3;                    % Symbol rate
% IF parameter
signal.IFfs=10e6;                  % Sample frequency of Intermediate frequency 
signal.fc=1e6;                     % Carrier frequency
signal.f_offset=0;
% Modulate parameter
signal.type='MQAM';
signal.M = 16;                     % Size of signal constellation
signal.k = log2(M);                % Number of bits per symbol
signal.n = 30000;                  % Number of bits to process
% shape filter
signal.rolloff=0.5;
signal.span=10;
signal.sps=4;
%
signal.gen_method='BaseBand';
signal.noiseType='Gauss';
signal.noisePowType='SNR';
signal.encodeType='bin';
%% gen IQ 
dataIn=gen_bindata(n);      % Generate vector of binary data
dataInMatrix = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers

dataMod = qammod(dataSymbolsIn,M,'bin');             % Binary coding, phase offset = 0
dataModG = qammod(dataSymbolsIn,M);                  % Gray coding, phase offset = 0

dataIQ=dataMod;
%% BaseBand mod
%% filter and resample (gen baseband signal)
txSignal=zeros(1,length(dataIQ)*sps);
txSignal(1:sps:end)=dataIQ;
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
txSignal=conv(txSignal,rrcFilter);
rclen=length(rrcFilter);
txSignal=txSignal(round((rclen+1)/2:end-round((rclen-1)/2)));


figure;plot(txSignal,'x')
rxSignal=conv(txSignal,rrcFilter);
figure;plot(rxSignal)
figure;plot(rxSignal(1:sps:end),'x') 
%% gen IF signal
txSignalIF=resample(rxSignal,IFfs,fs);
txlen=length(txSignalIF);
t=(0:txlen-1)/IFfs;
xc=cos(2*pi*fc*t);
xs=-sin(2*pi*fc*t);

txSignalIF=real(txSignalIF).*xc+imag(txSignalIF).*xs;

%% Channel
txSignalIF=awgn(txSignalIF,signal.noise,'measured');

%% DDC
txlen=length(txSignalIF);
t=(0:txlen-1)/IFfs;
xc_ddc=cos(2*pi*(fc+f_offset)*t);
xs_ddc=-sin(2*pi*(fc+f_offset)*t);
IfToBaseI=xc_ddc.*txSignalIF;
IfToBaseQ=xs_ddc.*txSignalIF;
figure;
plot(abs(fftshift(fft(IfToBaseI))))
figure;
plot(abs(fftshift(fft(IfToBaseQ))))

lpf_ddc = fir1(64,4*fb/(IFfs/2),'low');
freqz(lpf_ddc)
IfToBaseI=conv(lpf_ddc,IfToBaseI);
IfToBaseQ=conv(lpf_ddc,IfToBaseQ);


IfToBaseI=resample(IfToBaseI,fs,IFfs);
IfToBaseQ=resample(IfToBaseQ,fs,IFfs);

if signal.gen_method=='BaseBand'
    
end


