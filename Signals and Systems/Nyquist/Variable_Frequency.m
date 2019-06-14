clc
clear
close all

%% 
L=100000;
%fc=2e3*(0.5:1/L:1.5-1/L);
%fc=1.5e3*(1:1/L:2-1/L);
fc1=10e3;
fs=50e3;
t=(0:L-1)/fs;
fc=4e3*ones(1,L);
fc(round(1/4*L):round(3/4*L))=3e2*t(round(1):round(2/4*L+1))+4e3;
%fc(round(3/4*L):round(4/4*L))=4300;
%x=exp(j*2*pi*fc.*t+j*2*pi*fc1*t);
x=sin(2*pi*fc.*t);
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))

figure
plot(fc)

