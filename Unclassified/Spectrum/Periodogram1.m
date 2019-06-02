clc;
clear all;
close all;

fc1=2.5e3;                                                 %carrier frequency
fc2=7.5e3;
%fc2=0;
fc=1.5e3;

fs=30e3;                                               %sample frequency
T=1/fs;                                                 %sample time
L=30000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
B=0.3;
f=(-L/2:L/2-1)*(fs/L);
%y=A*sin(2*pi*fc1*t)+B*sin(2*pi*fc2*t);
y=A*cos(2*pi*(fc-fc1)*t)+B*cos(2*pi*(fc+fc2)*t);
y=A*cos(2*pi*(fc)*t);
y=A*exp(j*2*pi*(fc)*t);
figure
Y=fftshift(fft(y));
plot(abs(Y))


figure
plot(abs(Y.^2))

periodogram(y)