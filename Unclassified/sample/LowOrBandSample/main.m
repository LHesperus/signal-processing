clc
close all
clear all

fc1=2.5e3;                                                 %carrier frequency
fc2=7.5e3;
%fc2=0;
fc=20e6;
fc=60e3;
M=626;
%M=0;
fs=4*fc/(2*M+1)
fs=64e3;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=3000000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
B=0.3;
f=(-L/2:L/2-1)*(fs/L);
%y=A*sin(2*pi*fc1*t)+B*sin(2*pi*fc2*t);
y=A*cos(2*pi*(fc-fc1)*t)+B*cos(2*pi*(fc+fc2)*t);
%y=awgn(y,-20,'measured');
figure
plot(y);title('signal')
Y=fftshift(fft(y));
figure
plot(f,abs(Y))
grid on

y_IF=cos(2*pi*fc*t).*y;
figure
plot(y_IF)
figure
Y_IF=fftshift(fft(y_IF));
plot(f,abs(Y_IF))

%% Bandpass sampling
D=2;
f_bs=f(1:D:end)/D;
y_bs=y_IF(1:D:end);
figure
plot(y_bs)
figure
Y_bs=fftshift(fft(y_bs));
plot(f_bs,abs(Y_bs))

fL=20e6-15e3/2;
fH=20e6+15e3/2;
fs=64e3;
fL-fs*313
fH-fs*313