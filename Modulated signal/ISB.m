%Generating ISB signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=500;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

                                            
%ISB(LSB and USB have different information)
v_L=cos(2*pi*200*t);
I_ISB=v+v_L;
Q_ISB=imag(hilbert(v))-imag(hilbert(v_L));
y_ISB=I_ISB.*xc+Q_ISB.*xs;

figure(1)
plot(y_ISB)

figure(2)
plotSpectral(y_ISB,fs)
