clc
clear all
close all
% para

%signal.fm.m_a=0.3;                          %modulation index,|m_a|<1
signal.fm.fs=64e3;                          %baseband fs
signal.fm.IFfs=200e3;                        % IF fs
signal.fm.fc=4e3;
signal.fm.fDev=1e3;
signal.fm.f_offset=0;
% baseband para (x=Asin(w1t+p1)+Bsin(w2t+p2)+Csin(w3+p3))
signal.fm.in_sig_amp=[1,1,0];
signal.fm.in_sig_f0=[2e2,1e2,0];
signal.fm.in_sig_phase=[0,0,0];
%ddc para
signal.fm.lpf_lowf_stop=4*max(signal.fm.in_sig_f0)/signal.fm.IFfs;
signal.fm.len=1000;                         % baseband len of one package
%channel para
signal.noise=30;                            %SNR
%buffer
signal.fm.LOphaseTemp=0;                    %IF Local Oscillator Phase
signal.fm.LOphaseTemp_ddc=0;                %DDC Local Oscillator Phase
signal.fm.ddcrebuffer=[];                   %DDC resfmple Buffer
signal.fm.Ifrebuffer=[];                    %IF resfmple Buffer
signal.fm.ddcconvbuffer=[];                 %DDC CONV Buffer
% three gen signal type
signal.gen_method="Baseband";
signal.gen_method="IF";
signal.gen_method="IF2Base";
% len=10000;
% t=(0:len-1)/signal.fm.fs;
% f0=1e1;
% x=sin(2*pi*f0*t);
% px=2*pi*1000*sum(x)*t(2)
% px=2*pi*1000*trapz(t,x)
% % x=x*0+1;
% y = fmmod(x,signal.fm.fc,signal.fm.fs,1000,0);
% phase=2*pi*signal.fm.fc/signal.fm.fs*(len)+px;
% %y = fmmod(x,Fc,Fs,freqdev,ini_phase)
% figure;
% plot(x)
% figure;
% plot(y)
% x1=sin(2*pi*f0*(t+t(end)+t(2)));
% % x1=x1*0+1;
% mod(phase,2*pi)
% y2 = fmmod(x1,signal.fm.fc,signal.fm.fs,1000,phase);
% figure;
% plot([x,x1],'x')
% figure;
% yy=[y,y2];
% plot(yy(len-20:len+20),'x')
%% gen signal
packageN=10;
rxSignal=[];
for ii=1:packageN
    [rxSignalTemp,signal] = gen_FM(signal);
    rxSignal=[rxSignal,rxSignalTemp];
end
figure;
subplot(2,1,1)
plot(real(rxSignal))
subplot(2,1,2)
plot(imag(rxSignal))
suptitle('receive IQ')
%% demod
I=real(rxSignal);
Q=imag(rxSignal);
f=I(2:end).*Q(1:end-1)-I(1:end-1).*Q(2:end);
figure
plot(f);title('demod')


figure;
Y=abs(fftshift(fft(rxSignal)));
plot(Y);title('receive Spetrum')
