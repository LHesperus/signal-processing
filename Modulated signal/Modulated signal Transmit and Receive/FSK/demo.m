clc
clear all
close all

%
j=sqrt(-1);
%% parameter Init
% Modulate parameter
signal.M =2;                      % MFSK  
signal.symlen = 300;               % Number of symbol
% baseband parameter
signal.fs=200e3;                    % Sample frequency of baseband
signal.fb=10e3;                    % Symbol rate
% IF parameter
signal.IFfs=200e3;                  % Sample frequency of Intermediate frequency 
signal.fc=20e3;                     % Carrier frequency             
signal.freq_sep=10e3;
% IF2Base parameter
% signal.lpf_lowf_stop=(signal.fc+(signal.M-1)*signal.freq_sep)/(signal.IFfs/2);
signal.lpf_lowf_stop=signal.M*2*signal.freq_sep/signal.fs;
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
signal.noise=30;
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

rxSignal=rxSignal(:,size(rxSignalTemp,2):end-size(rxSignalTemp,2));

%% demod
if signal.gen_method=="Baseband"
figure;plot(rxSignal(1,100:end))
figure;plot(abs(fftshift(fft(rxSignal(1,1000:10000)))))
figure;plot(real(rxSignal(1,100:end)))
figure;plot(imag(rxSignal(1,100:end)))
figure;plot(abs(fftshift(fft(rxSignal(1,1000:10000)))))

hold on ;plot(rxSignal(2,:))
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

end

if signal.gen_method=="IF"

% rxSignal=resample(rxSignal,4*signal.fb,signal.IFfs);
% rccfilter=rcosdesign(0.5, 6, 4,'sqrt');
% rxSignal=conv(rxSignal,rccfilter);
% rxSignal=rxSignal(2*length(rccfilter):end-2*length(rccfilter));
    figure;plot(rxSignal)
    len=length(rxSignal);
    ff=(-len/2:len/2-1)*(signal.IFfs/len);
    figure;plot(ff,fftshift(abs(fft(rxSignal))))
    %% ddc
    f_ddc=sum(signal.fc+cumsum(ones(1,signal.M)*signal.freq_sep)-signal.freq_sep);
    f_ddc=f_ddc/signal.M;
    t=(0:len-1)/(signal.IFfs);
    xc=cos(2*pi*f_ddc*t);
    xs=-sin(2*pi*f_ddc*t);
    ddcI=rxSignal.*xc;
    ddcQ=rxSignal.*xs;
    % lpf
    lpf_ddc = fir1(64,f_ddc/signal.IFfs,'low');
%     lpf_ddc=1;
    rxI=conv(lpf_ddc,ddcI);
    rxQ=conv(lpf_ddc,ddcQ);
    figure;subplot(211);plot(rxI);subplot(212);plot(rxQ);
    len=length(rxI);
    ff=(-len/2:len/2-1)*(signal.IFfs/len);
    figure;plot(ff,fftshift(abs(fft(rxI+rxQ*j))))
end

if signal.gen_method=="IF2Base"
    figure;subplot(211);plot(real(rxSignal));title('I');subplot(212);plot(imag(rxSignal));title('Q')
    len=length(rxSignal);
    ff=(-len/2:len/2-1)*(signal.fs/len);
    figure;plot(ff,fftshift(abs(fft(rxSignal))));title('Baseband Spectrum')
    % rrc
%     rxSignal=resample(rxSignal,8*signal.fb,signal.fs);
%     rccfilter=rcosdesign(0.5, 6, 8,'sqrt');
%     rxSignal=conv(rxSignal,rccfilter);
%     rxSignal=rxSignal(2*length(rccfilter):end-2*length(rccfilter));
%     figure;subplot(211);plot(real(rxSignal));subplot(212);plot(imag(rxSignal));suptitle('by rcc filter')
    
    I=real(rxSignal);
    Q=imag(rxSignal);
    f=I(2:end).*Q(1:end-1)-I(1:end-1).*Q(2:end);
    
%     f=resample(f,8*signal.fb,signal.fs);
%     rccfilter=rcosdesign(0.5, 6, 8,'sqrt');
%     f=conv(f,rccfilter);
%     f=f(2*length(rccfilter):end-2*length(rccfilter));
%     figure;subplot(211);plot(real(f));subplot(212);plot(imag(f));suptitle('by rcc filter')
    
    figure;plot(f);title('demod')
    ang=unwrap(angle(rxSignal));
    f=(ang(2:end))-(ang(1:end-1));
    figure;subplot(211);plot(ang);title('instantaneous freq')
    subplot(212);plot(f);title('demod')
end
