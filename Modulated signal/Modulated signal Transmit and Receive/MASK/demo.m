% MASK signal Transmit and Receive 
% author£º LCG
% date: 2019.09.06
clc
clear all
close all

%% parameter Init
% baseband parameter
signal.fs=64e3;                    % Sample frequency of baseband
signal.fb=10e3;                    % Symbol rate
% IF parameter
signal.IFfs=10e6;                  % Sample frequency of Intermediate frequency 
signal.fc=1e6;                     % Carrier frequency
signal.f_offset=1e2;                
% IF2Base parameter
signal.lpf_lowf_stop=4*signal.fb/(signal.IFfs/2);
% Modulate parameter
signal.M = 2;                      % MASK  
signal.symlen = 300;               % Number of symbol
% shape filter
signal.rolloff=0.5;
signal.span=10;
signal.sps=4;
%
signal.gen_method="Baseband";
signal.gen_method="IF";
signal.gen_method="IF2Base";
signal.noiseType="Gauss";
signal.noisePowType="SNR"';
signal.encodeType="bin";
signal.bindataType="Random";
% orther parameter Init
signal.f_offset=0;                          % Carrier offset
signal.p_offset=2*pi*0;
signal.noise=100;
% buffer
signal.LOphaseTemp=0;
signal.LOphaseTemp_ddc=0;
signal.baseconvbuf=[];
signal.ddcconvbuf=[];
signal.baserebuf=[];
signal.Ifrebuf=[];
signal.ddcrebuf=[];
signal.Ifrebuf=zeros(1,32);

%% gen signal
packageN=2;
rxSignal=[];
for ii=1:packageN
    [rxSignalTemp,signal]= gen_MASK(signal);
    rxSignal=[rxSignal,rxSignalTemp];
end


%% demod
rxSignal=resample(rxSignal,4*signal.fb,signal.fs);
rccfilter=rcosdesign(0.5, 6, 4,'sqrt');
rxSignal=conv(rxSignal,rccfilter);
figure;
subplot(2,1,1)
plot(real(rxSignal))
subplot(2,1,2)
plot(imag(rxSignal))
figure
plot(rxSignal(1+101:4:end-100),'x')
figure
plot(rxSignal(1+102:4:end-100),'x')
figure
plot(rxSignal(1+103:4:end-100),'x')
figure
plot(rxSignal(1+104:4:end-100),'x')