%Generating AM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=10000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%AM
m_a=0.3;                                               %modulation index,|m_a|<1
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(1)
plot(y_AM)
title('m_a=0.3');
figure(2)
plotSpectral(y_AM,fs)

m_a=0.5;                                      
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(3)
plot(y_AM)
title('m_a=0.5');

m_a=0.7;                                            
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(4)
plot(y_AM)
title('m_a=1');

ff=(-L/2:L/2-1)*(fs/L);
f_offset=0.001*fc
[I,Q]=DDC_filter(fs,fc+f_offset,4000,10,y_AM);
figure
subplot(2,1,1)
plot(I)
subplot(2,1,2)
plot(Q)
IQ=I+Q*j;
figure
subplot(2,1,1)
plot(abs(IQ))
subplot(2,1,2)
plot(angle(IQ)./pi*180)
figure
plot(ff,abs(fftshift(fft(IQ))))
IQ_adjust=IQ.*exp(-j*2*pi*f_offset*t);
hold on
plot(ff,abs(fftshift(fft(IQ_adjust))))
legend('IQ','IQ_adjust')
figure
subplot(2,1,1)
plot(real(IQ_adjust))
subplot(2,1,2)
plot(imag(IQ_adjust))

figure
subplot(2,1,1)
plot(abs(IQ_adjust))
subplot(2,1,2)
plot(angle(IQ_adjust)./pi*180)
