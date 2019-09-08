clc
clear all
close all

%
%% parameter Init
% Modulate parameter
signal.M = 2;                      % MFSK  
signal.symlen = 300;               % Number of symbol
% baseband parameter
signal.fs=64e3;                    % Sample frequency of baseband
signal.fb=10e3;                    % Symbol rate
% IF parameter
signal.IFfs=64e3;                  % Sample frequency of Intermediate frequency 
signal.fc=10e3;                     % Carrier frequency             
signal.freq_sep=10e3;
% IF2Base parameter
signal.lpf_lowf_stop=(signal.fc+(signal.M-1)*signal.freq_sep)/(signal.IFfs/2);
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
signal.state="Init";
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


%
%% gen signal
packageN=10;
rxSignal=[];
for ii=1:packageN
    [rxSignalTemp,signal]= gen_MFSK(signal);
    rxSignal=[rxSignal,rxSignalTemp];
end
rxSignal=rxSignal(size(rxSignalTemp,2):end-size(rxSignalTemp,2));
figure;
plot(abs(fftshift(fft(rxSignal(1000:10000)))))
%% demod
% figure;plot(rxSignal(1,100:end))
% figure;plot(abs(fftshift(fft(rxSignal(1000:10000)))))
% figure;plot(real(rxSignal(1,100:end)))
% figure;plot(imag(rxSignal(1,100:end)))
% figure;plot(abs(fftshift(fft(rxSignal(1000:10000)))))

% hold on ;plot(rxSignal(2,:))
% hold on ;plot(rxSignal(3,:))
% hold on ;plot(rxSignal(4,:))
rxSignal=resample(rxSignal,4*signal.fb,signal.fs);
rccfilter=rcosdesign(0.5, 6, 4,'sqrt');
rxSignal=conv(rxSignal,rccfilter);
rxSignal=rxSignal(2*length(rccfilter):end-2*length(rccfilter));
figure;
subplot(2,1,1)
plot(real(rxSignal))
subplot(2,1,2)
plot(imag(rxSignal))

figure;
plot(abs(fftshift(fft(rxSignal(1000:10000)))))
% I=real(rxSignal);
% Q=imag(rxSignal);
ang=unwrap(angle(rxSignal));
% f=angle(rxSignal(2:end))-angle(rxSignal(1:end-1));
f=(ang(2:end))-(ang(1:end-1));
figure
plot(f)
I=real(rxSignal);
Q=imag(rxSignal);
f=I(2:end).*Q(1:end-1)-I(1:end-1).*Q(2:end);
figure
plot(f)