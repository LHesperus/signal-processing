%Generating FM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=200;                                                  %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

I_SSB=v;
Q_SSB=imag(hilbert(v));                               %LSB
y_SSB=I_SSB.*xc+Q_SSB.*xs;

figure(1)
plot(y_SSB)
title('LSB');
figure(2)
plotSpectral(y_SSB,fs)

I_SSB=v;

Q_SSB=-imag(hilbert(v));                              %USB
y_SSB=I_SSB.*xc+Q_SSB.*xs;
figure(3)
plot(y_SSB)
title('USB');
figure(4)
plotSpectral(y_SSB,fs)