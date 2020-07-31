clc
clear all
close all
%
fs=8e3;
fc=1004;
len=1000;
t=(0:len-1)/fs;
x=sin(2*pi*fc*t);
n=len;
ff=(-n/2:n/2-1)*(fs/n);
disp(['fs分辨率:',num2str(fs/n)])
figure
plot(x)
figure
plot(ff,abs(fftshift(fft(x))))

n=4096;
ff=(-n/2:n/2-1)*(fs/n);
disp(['fs分辨率:',num2str(fs/n)])
figure
plot(ff,abs(fftshift(fft(x,n))))