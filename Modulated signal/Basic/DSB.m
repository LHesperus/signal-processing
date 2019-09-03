%Generating DSB signal
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

%FM                                                 
I_DSB=v;
Q_DSB=0;
y_DSB=I_DSB.*xc+Q_DSB.*xs;
figure(1)
plot(y_DSB)
title('DSB');
figure(2)
plotSpectral(y_DSB,fs)
